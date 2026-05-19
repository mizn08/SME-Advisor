#!/usr/bin/env python3
"""Print normalized DATABASE_URL for shell entrypoint (Render Postgres SSL)."""
import os
import sys

sys.path.insert(0, "/app/backend")
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "backend"))

from app.db.url_normalize import normalize_database_url  # noqa: E402

url = os.environ.get("DATABASE_URL", "").strip()
if not url:
    print("sqlite:////app/backend/data/bnpl_local.db")
else:
    print(normalize_database_url(url))
