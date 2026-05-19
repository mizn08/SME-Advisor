"""Tabular RL policy (Q-learning) + RLHF-style preference logging — post-APC layer."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.services import bandit_service, unsupervised_service
from app.services.bandit_service import ARMS, normalize_arm

ACTIONS = list(ARMS)
ALPHA = 0.15
GAMMA = 0.9


def _q_path() -> Path:
    p = Path(get_settings().RL_Q_TABLE_PATH)
    p.parent.mkdir(parents=True, exist_ok=True)
    return p


def _load_q() -> dict[str, dict[str, float]]:
    path = _q_path()
    if not path.is_file():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def _save_q(table: dict[str, dict[str, float]]) -> None:
    _q_path().write_text(json.dumps(table, indent=2), encoding="utf-8")


def _state_key(db: Session, sme_id: int, purchase_amount: float) -> str:
    cluster = unsupervised_service.get_sme_cluster(db, sme_id)
    cid = cluster["cluster_id"] if cluster else 0
    bucket = "low" if purchase_amount < 3000 else "mid" if purchase_amount < 15000 else "high"
    return f"c{cid}_{bucket}"


def select_action(db: Session, sme_id: int, purchase_amount: float) -> dict[str, Any]:
    state = _state_key(db, sme_id, purchase_amount)
    q = _load_q()
    state_q = q.get(state, {a: 0.0 for a in ACTIONS})
    best = max(ACTIONS, key=lambda a: state_q.get(a, 0.0))
    bandit = bandit_service.select_arm_ucb(db)
    # Blend: prefer higher Q, fall back to bandit exploration
    action = best if state_q.get(best, 0) > 0.1 else bandit["suggested_arm"]
    return {
        "state": state,
        "action": action,
        "q_values": state_q,
        "bandit_suggestion": bandit["suggested_arm"],
        "policy": "q_learning_tabular",
    }


def update_policy(
    db: Session,
    *,
    sme_id: int,
    purchase_amount: float,
    action: str,
    reward: float,
) -> dict[str, Any]:
    state = _state_key(db, sme_id, purchase_amount)
    action = normalize_arm(action)
    q = _load_q()
    state_q = q.setdefault(state, {a: 0.0 for a in ACTIONS})
    old = state_q.get(action, 0.0)
    state_q[action] = old + ALPHA * (reward + GAMMA * max(state_q.values()) - old)
    _save_q(q)
    bandit_service.record_feedback(db, sme_id=sme_id, arm=action, accepted=reward > 0.5, reward=reward)
    return {"status": "updated", "state": state, "action": action, "new_q": state_q[action]}


def rlhf_log_preference(
    db: Session,
    *,
    sme_id: int,
    chosen: str,
    rejected: str,
) -> dict[str, Any]:
    """RLHF-style human preference — boosts chosen arm, penalises rejected."""
    chosen_arm = normalize_arm(chosen)
    rejected_arm = normalize_arm(rejected)
    bandit_service.record_feedback(db, sme_id=sme_id, arm=chosen_arm, accepted=True, reward=1.0)
    bandit_service.record_feedback(db, sme_id=sme_id, arm=rejected_arm, accepted=False, reward=0.0)
    return {"status": "logged", "chosen": chosen_arm, "rejected": rejected_arm, "method": "rlhf_preference"}
