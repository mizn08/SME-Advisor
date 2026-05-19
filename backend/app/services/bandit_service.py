"""Multi-armed bandit (UCB1) for recommendation-type exploration."""

from __future__ import annotations

import math
from typing import Any

from sqlalchemy.orm import Session

from app.models.bandit import BanditArmStat, BanditFeedback

ARMS = ("bnpl", "grant", "micro_credit", "preserve_cash")

ARM_ALIASES = {
    "bnpl": "bnpl",
    "grant": "grant",
    "government": "grant",
    "gov": "grant",
    "micro_credit": "micro_credit",
    "credit": "micro_credit",
    "micro-credit": "micro_credit",
    "preserve_cash": "preserve_cash",
    "cash": "preserve_cash",
}


def _ensure_arms(db: Session) -> None:
    existing = {r.arm for r in db.query(BanditArmStat).all()}
    for arm in ARMS:
        if arm not in existing:
            db.add(BanditArmStat(arm=arm, pulls=0, total_reward=0.0))
    db.commit()


def normalize_arm(recommendation_type: str) -> str:
    key = recommendation_type.lower().replace(" ", "_")
    return ARM_ALIASES.get(key, "preserve_cash")


def select_arm_ucb(db: Session, c: float = 1.4) -> dict[str, Any]:
    _ensure_arms(db)
    stats = db.query(BanditArmStat).filter(BanditArmStat.arm.in_(ARMS)).all()
    total_pulls = sum(s.pulls for s in stats) or 1

    best_arm = ARMS[0]
    best_score = -1.0
    for s in stats:
        if s.pulls == 0:
            score = float("inf")
        else:
            avg = s.total_reward / s.pulls
            score = avg + c * math.sqrt(math.log(total_pulls) / s.pulls)
        if score > best_score:
            best_score = score
            best_arm = s.arm

    return {
        "suggested_arm": best_arm,
        "exploration": "ucb1",
        "arm_stats": [
            {
                "arm": s.arm,
                "pulls": s.pulls,
                "avg_reward": (s.total_reward / s.pulls) if s.pulls else 0.0,
            }
            for s in stats
        ],
    }


def record_feedback(
    db: Session,
    *,
    sme_id: int,
    arm: str,
    accepted: bool,
    prediction_id: int | None = None,
    reward: float | None = None,
) -> dict[str, Any]:
    _ensure_arms(db)
    arm = normalize_arm(arm)
    if arm not in ARMS:
        arm = "preserve_cash"

    r = reward if reward is not None else (1.0 if accepted else 0.0)
    db.add(
        BanditFeedback(
            sme_id=sme_id,
            prediction_id=prediction_id,
            arm=arm,
            reward=r,
            accepted=accepted,
        )
    )
    stat = db.query(BanditArmStat).filter(BanditArmStat.arm == arm).first()
    if stat:
        stat.pulls += 1
        stat.total_reward += r
    db.commit()
    return {"status": "ok", "arm": arm, "reward": r}


def bandit_stats(db: Session) -> dict[str, Any]:
    _ensure_arms(db)
    stats = db.query(BanditArmStat).order_by(BanditArmStat.arm).all()
    return {
        "arms": [
            {
                "arm": s.arm,
                "pulls": s.pulls,
                "total_reward": s.total_reward,
                "avg_reward": (s.total_reward / s.pulls) if s.pulls else 0.0,
            }
            for s in stats
        ],
        "suggestion": select_arm_ucb(db),
    }
