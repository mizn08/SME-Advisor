from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.sme import SMEProfile
from app.schemas import (
    DashboardKPIs,
    DashboardResponse,
    MonthlySeriesPoint,
)
from app.services import data_processor

router = APIRouter(tags=["dashboard"])


@router.get("/sme/{sme_id}/dashboard", response_model=DashboardResponse)
def get_dashboard(sme_id: int, db: Session = Depends(get_db)):
    sme = db.query(SMEProfile).filter(SMEProfile.id == sme_id).first()
    if not sme:
        raise HTTPException(404, "SME not found")
    df = data_processor.load_transactions_df(db, sme_id)
    kpis = data_processor.compute_kpis_from_transactions(df)
    series = [MonthlySeriesPoint(**p) for p in data_processor.monthly_series(df)]
    return DashboardResponse(
        sme_id=sme_id,
        business_name=sme.business_name,
        industry=sme.industry,
        kpis=DashboardKPIs(**kpis),
        monthly_series=series,
    )
