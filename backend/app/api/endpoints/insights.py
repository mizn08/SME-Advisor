from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.sme import SMEProfile
from app.schemas import AnomaliesBlock, ClusterInfo, ClusterResponse, SmeInsightsResponse
from app.services import unsupervised_service

router = APIRouter(tags=["v3-insights"])


@router.get("/sme/{sme_id}/insights", response_model=SmeInsightsResponse)
def sme_insights(sme_id: int, db: Session = Depends(get_db)):
    sme = db.query(SMEProfile).filter(SMEProfile.id == sme_id).first()
    if not sme:
        raise HTTPException(404, "SME not found")
    data = unsupervised_service.sme_insights(db, sme_id)
    cluster = data.get("cluster")
    return SmeInsightsResponse(
        sme_id=sme_id,
        cluster=ClusterInfo(**cluster) if cluster else None,
        anomalies=AnomaliesBlock(**data["anomalies"]),
    )


@router.get("/clusters", response_model=ClusterResponse)
def list_clusters(db: Session = Depends(get_db)):
    data = unsupervised_service.compute_clusters(db)
    return ClusterResponse(
        clusters=[ClusterInfo(**c) for c in data["clusters"]],
        method=data["method"],
        n_clusters=data["n_clusters"],
    )
