from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.sme import SMEProfile
from app.services import (
    data_processor,
    forecast_service,
    grant_eligibility_service,
    health_score_service,
    unsupervised_service,
)

router = APIRouter(tags=["report"])


@router.get("/sme/{sme_id}/report")
def sme_report(sme_id: int, db: Session = Depends(get_db)):
    sme = db.query(SMEProfile).filter(SMEProfile.id == sme_id).first()
    if not sme:
        raise HTTPException(404, "SME not found")
    df = data_processor.load_transactions_df(db, sme_id)
    kpis = data_processor.compute_kpis_from_transactions(df)
    fc = forecast_service.forecast_runway(db, sme_id)
    anomalies = unsupervised_service.detect_anomalies(db, sme_id)
    alerts: list[str] = []
    if fc.get("alert"):
        alerts.append(fc["alert"])
    if anomalies.get("total_flagged", 0) > 0:
        alerts.append(f"{anomalies['total_flagged']} unusual transactions detected.")
    health = health_score_service.compute_health_score(
        kpis, fc.get("runway_days_est"), int(anomalies.get("total_flagged") or 0)
    )
    grants = grant_eligibility_service.match_grants(db, sme_id=sme_id)
    return {
        "sme_id": sme_id,
        "business_name": sme.business_name,
        "industry": sme.industry,
        "health": health,
        "kpis": kpis,
        "runway_days_est": fc.get("runway_days_est"),
        "alerts": alerts,
        "grant_matches": grants[:8],
        "compliance": [
            {"item": "e-Invoice Phase 4 (RM1M–RM5M)", "due": "2026-01-01", "status": "due"},
            {"item": "e-Invoice Phase 5 (<RM1M)", "due": "2026-07-01", "status": "upcoming"},
            {"item": "Minimum wage RM1,700", "due": "2025-02-01", "status": "active"},
        ],
        "generated_for": "bank_grant_application",
    }
