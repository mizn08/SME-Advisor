"""Optional JWT / API-key auth for production."""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import Depends, HTTPException, Security
from fastapi.security import APIKeyHeader, HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.db.session import get_db

bearer = HTTPBearer(auto_error=False)
api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)


def create_access_token(subject: str) -> str:
    s = get_settings()
    expire = datetime.now(timezone.utc) + timedelta(minutes=s.JWT_EXPIRE_MINUTES)
    return jwt.encode({"sub": subject, "exp": expire}, s.JWT_SECRET, algorithm=s.JWT_ALGORITHM)


def optional_auth(
    creds: Annotated[HTTPAuthorizationCredentials | None, Security(bearer)] = None,
    api_key: Annotated[str | None, Security(api_key_header)] = None,
) -> str:
    s = get_settings()
    if not s.AUTH_REQUIRED:
        return "demo"
    if api_key and s.API_KEY and api_key == s.API_KEY:
        return "api_key"
    if creds and creds.credentials:
        try:
            payload = jwt.decode(creds.credentials, s.JWT_SECRET, algorithms=[s.JWT_ALGORITHM])
            return str(payload.get("sub", "user"))
        except JWTError as exc:
            raise HTTPException(401, "Invalid token") from exc
    raise HTTPException(401, "Authentication required")


def require_auth(actor: str = Depends(optional_auth)) -> str:
    return actor
