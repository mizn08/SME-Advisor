from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.gov_aid import GovFinancialAid
from app.models.prediction import PredictionLog
from app.models.sme import SMEProfile
from app.schemas import GovAidOut, PredictRequest, PredictResponse, ShapItem
from app.services import data_processor, decision_engine

router = APIRouter(tags=["predict"])


@router.post("/predict", response_model=PredictResponse)
def predict(payload: PredictRequest, db: Session = Depends(get_db)):
    sme = db.query(SMEProfile).filter(SMEProfile.id == payload.sme_id).first()
    if not sme:
        raise HTTPException(404, "SME not found")
    df = data_processor.load_transactions_df(db, payload.sme_id)
    kpis = data_processor.compute_kpis_from_transactions(df)

    result = decision_engine.decide(
        db,
        sme,
        kpis,
        payload.purchase_amount,
        payload.purchase_category,
        payload.selected_bnpl_plan,
    )

    log = PredictionLog(
        sme_id=payload.sme_id,
        request_payload=payload.model_dump(),
        recommendation_type=result.recommendation_type,
        product_name=result.product_name,
        explanation=result.explanation,
        cash_preserved_rm=result.cash_preserved_rm,
        additional_cost_rm=result.additional_cost_rm,
        confidence=result.confidence,
        shap_values=result.shap_values,
        ml_probability=result.ml_probability,
    )
    db.add(log)
    db.commit()

    return PredictResponse(
        recommendation_type=result.recommendation_type,
        product_name=result.product_name,
        explanation=result.explanation,
        cash_preserved_rm=result.cash_preserved_rm,
        additional_cost_rm=result.additional_cost_rm,
        confidence=result.confidence,
        shap_values=[ShapItem(**s) for s in result.shap_values],
        ml_probability=result.ml_probability,
    )


@router.get("/gov-aid", response_model=list[GovAidOut])
def list_gov_aid(db: Session = Depends(get_db)):
    rows = db.query(GovFinancialAid).order_by(GovFinancialAid.id).all()
    return [GovAidOut.model_validate(r, from_attributes=True) for r in rows]
