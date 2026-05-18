#!/usr/bin/env python3
"""Create tables and seed SMEs, 6 months of transactions, BNPL & government schemes."""

from __future__ import annotations

import os
import sys
from pathlib import Path

from dotenv import load_dotenv

# Project layout: scripts/ at repo root, backend app mounted at /app in Docker
ROOT = Path(__file__).resolve().parents[1]
BACKEND = ROOT / "backend"
sys.path.insert(0, str(BACKEND if (BACKEND / "app").is_dir() else Path("/app")))

load_dotenv(ROOT / ".env")
load_dotenv(BACKEND / ".env")

from app.db.session import SessionLocal  # noqa: E402
from app.services.database_init import init_database  # noqa: E402


def main() -> None:
    if not os.environ.get("DATABASE_URL"):
        print("DATABASE_URL is not set", file=sys.stderr)
        sys.exit(1)

    db = SessionLocal()
    try:
        result = init_database(db)
        print("Database initialised:", result)
    except Exception as exc:  # noqa: BLE001
        print(f"init_db failed: {exc}", file=sys.stderr)
        sys.exit(1)
    finally:
        db.close()


if __name__ == "__main__":
    main()
