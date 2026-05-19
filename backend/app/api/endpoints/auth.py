from __future__ import annotations

from fastapi import APIRouter

from app.core.security import create_access_token
from app.schemas import TokenRequest, TokenResponse

router = APIRouter(tags=["auth"])


@router.post("/auth/token", response_model=TokenResponse)
def login(payload: TokenRequest):
    # Demo: any username with password "sme2026"
    if payload.password != "sme2026":
        return TokenResponse(access_token="", token_type="bearer", note="Invalid password (demo: sme2026)")
    token = create_access_token(payload.username)
    return TokenResponse(access_token=token, token_type="bearer")
