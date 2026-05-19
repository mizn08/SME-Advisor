from __future__ import annotations

import json
from pathlib import Path

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.security import require_auth
from app.db.session import get_db
from app.services import audit_service, gov_aid_refresh

router = APIRouter(tags=["catalog"])

PLAYBOOKS = Path(__file__).resolve().parents[2] / "data" / "sector_playbooks.json"


@router.post("/gov-aid/refresh")
def refresh_gov_aid(db: Session = Depends(get_db), actor: str = Depends(require_auth)):
    result = gov_aid_refresh.refresh_from_json(db)
    audit_service.log_action(db, "gov_aid_refresh", detail=str(result), actor=actor)
    return result


@router.get("/sector-playbooks")
def sector_playbooks():
    if PLAYBOOKS.is_file():
        return json.loads(PLAYBOOKS.read_text(encoding="utf-8"))
    return {}
