from __future__ import annotations

from sqlalchemy.orm import Session

from app.models.audit import AuditLog


def log_action(db: Session, action: str, resource: str = "", detail: str | None = None, actor: str = "api") -> None:
    db.add(AuditLog(action=action, resource=resource, detail=detail, actor=actor))
    db.commit()
