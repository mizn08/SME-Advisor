from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas import BanditFeedbackRequest, BanditStatsResponse, RlhfPreferenceRequest
from app.services import bandit_service, rl_policy_service

router = APIRouter(tags=["v3-bandit"])


@router.get("/bandit/stats", response_model=BanditStatsResponse)
def stats(db: Session = Depends(get_db)):
    return BanditStatsResponse(**bandit_service.bandit_stats(db))


@router.post("/bandit/feedback")
def feedback(payload: BanditFeedbackRequest, db: Session = Depends(get_db)):
    return bandit_service.record_feedback(
        db,
        sme_id=payload.sme_id,
        arm=payload.arm,
        accepted=payload.accepted,
        prediction_id=payload.prediction_id,
        reward=payload.reward,
    )


@router.post("/rlhf/preference")
def rlhf_preference(payload: RlhfPreferenceRequest, db: Session = Depends(get_db)):
    return rl_policy_service.rlhf_log_preference(
        db,
        sme_id=payload.sme_id,
        chosen=payload.chosen,
        rejected=payload.rejected,
    )
