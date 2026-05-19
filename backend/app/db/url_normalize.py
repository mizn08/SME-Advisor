"""Normalize DATABASE_URL for SQLAlchemy + Render Postgres (SSL)."""

from __future__ import annotations


def normalize_database_url(url: str) -> str:
    u = (url or "").strip()
    if not u:
        return u

    if u.startswith("postgres://"):
        u = "postgresql+psycopg2://" + u[len("postgres://") :]
    elif u.startswith("postgresql://") and "+psycopg2" not in u.split("://", 1)[0]:
        u = "postgresql+psycopg2://" + u[len("postgresql://") :]

    lower = u.lower()
    needs_ssl = any(
        hint in lower
        for hint in ("render.com", "oregon-postgres", "frankfurt-postgres", "virginia-postgres")
    )
    if needs_ssl and "sslmode=" not in lower:
        sep = "&" if "?" in u else "?"
        u = f"{u}{sep}sslmode=require"

    return u
