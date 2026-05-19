#!/usr/bin/env python3
"""Block until PostgreSQL accepts connections (used by Docker entrypoint)."""

from __future__ import annotations

import os
import sys
import time
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

DATABASE_URL = os.environ.get("DATABASE_URL")
if not DATABASE_URL:
    print("DATABASE_URL is not set", file=sys.stderr)
    sys.exit(1)

# Allow import when run from /app/scripts in Docker
sys.path.insert(0, "/app/backend")
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "backend"))
try:
    from app.db.url_normalize import normalize_database_url

    DATABASE_URL = normalize_database_url(DATABASE_URL)
except ImportError:
    pass

MAX_ATTEMPTS = int(os.environ.get("DB_WAIT_ATTEMPTS", "60"))
SLEEP_SECONDS = float(os.environ.get("DB_WAIT_INTERVAL", "2"))


def main() -> None:
    engine = create_engine(DATABASE_URL, pool_pre_ping=True)
    for attempt in range(1, MAX_ATTEMPTS + 1):
        try:
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            print(f"Database ready (attempt {attempt}/{MAX_ATTEMPTS})")
            return
        except Exception as exc:  # noqa: BLE001
            print(f"Waiting for database... ({attempt}/{MAX_ATTEMPTS}) {exc}")
            time.sleep(SLEEP_SECONDS)
    print("Database did not become ready in time", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
