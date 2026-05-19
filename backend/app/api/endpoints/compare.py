from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.security import require_auth
from app.db.session import get_db
from app.models.sme import SMEProfile
from app.schemas import CompareRequest, CompareResponse
from app.services import audit_service, compare_service

router = APIRouter(tags=["apc-compare"])


@router.post("/compare", response_model=CompareResponse)
def compare_options(
    payload: CompareRequest,
    db: Session = Depends(get_db),
    actor: str = Depends(require_auth),
):
    sme = db.query(SMEProfile).filter(SMEProfile.id == payload.sme_id).first()
    if not sme:
        raise HTTPException(404, "SME not found")
    data = compare_service.compare_financing(
        db,
        sme,
        payload.purchase_amount,
        payload.purchase_category,
        include_sst=payload.include_sst,
        islamic_only=payload.islamic_only,
    )
    audit_service.log_action(
        db,
        "compare",
        resource=f"sme/{payload.sme_id}",
        detail=f"amount={payload.purchase_amount}",
        actor=actor,
    )
    return CompareResponse(**data)
