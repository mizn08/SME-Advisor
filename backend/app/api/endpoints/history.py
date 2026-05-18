from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.prediction import PredictionLog
from app.schemas import PredictionDetailResponse, PredictionHistoryItem, ShapItem

router = APIRouter(tags=["history"])


@router.get("/sme/{sme_id}/predictions", response_model=list[PredictionHistoryItem])
def list_predictions(sme_id: int, db: Session = Depends(get_db)):
    rows = (
        db.query(PredictionLog)
        .filter(PredictionLog.sme_id == sme_id)
        .order_by(PredictionLog.created_at.desc())
        .limit(100)
        .all()
    )
    out: list[PredictionHistoryItem] = []
    for r in rows:
        req = r.request_payload or {}
        amt = float(req.get("purchase_amount", 0))
        out.append(
            PredictionHistoryItem(
                id=r.id,
                sme_id=r.sme_id,
                created_at=r.created_at.date(),
                recommendation_type=r.recommendation_type,
                product_name=r.product_name,
                confidence=r.confidence,
                purchase_amount=amt,
            )
        )
    return out


@router.get("/predictions/{prediction_id}", response_model=PredictionDetailResponse)
def prediction_detail(prediction_id: int, db: Session = Depends(get_db)):
    r = db.query(PredictionLog).filter(PredictionLog.id == prediction_id).first()
    if not r:
        raise HTTPException(404, "Prediction not found")
    shap_list = r.shap_values or []
    return PredictionDetailResponse(
        id=r.id,
        sme_id=r.sme_id,
        created_at=r.created_at.isoformat(),
        recommendation_type=r.recommendation_type,
        product_name=r.product_name,
        explanation=r.explanation,
        cash_preserved_rm=r.cash_preserved_rm,
        additional_cost_rm=r.additional_cost_rm,
        confidence=r.confidence,
        shap_values=[ShapItem(**s) for s in shap_list],
        request_payload=r.request_payload,
    )
