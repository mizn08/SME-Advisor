from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.sme import SMEProfile
from app.schemas import ChatRequest, ChatResponse, ChatSource
from app.services import rag_service

router = APIRouter(tags=["v2-rag"])


@router.post("/chat", response_model=ChatResponse)
def chat(payload: ChatRequest, db: Session = Depends(get_db)):
    sme = db.query(SMEProfile).filter(SMEProfile.id == payload.sme_id).first()
    if not sme:
        raise HTTPException(404, "SME not found")
    result = rag_service.rag_query(db, payload.sme_id, payload.message, payload.persona)
    return ChatResponse(
        sme_id=payload.sme_id,
        message=payload.message,
        answer=result["answer"],
        mode=result["mode"],
        sources=[ChatSource(**s) for s in result["sources"]],
    )


@router.post("/chat/reindex")
def reindex_rag(sme_id: int, db: Session = Depends(get_db)):
    sme = db.query(SMEProfile).filter(SMEProfile.id == sme_id).first()
    if not sme:
        raise HTTPException(404, "SME not found")
    rag_service.invalidate_rag_cache(sme_id)
    rag_service.rag_query(db, sme_id, "reindex")
    return {"status": "ok", "sme_id": sme_id}
