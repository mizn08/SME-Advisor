#!/usr/bin/env bash
set -euo pipefail

if [ -n "${DATABASE_URL:-}" ]; then
  export DATABASE_URL="$(python /app/scripts/normalize_db_url.py)"
  echo "==> DATABASE_URL normalized for SQLAlchemy + SSL"
fi

echo "==> Waiting for PostgreSQL..."
python /app/scripts/wait_for_db.py

# DB schema + seed runs in FastAPI lifespan (app/main.py) — faster Render deploys

echo "==> Starting FastAPI (uvicorn)..."
PORT="${PORT:-8000}"
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT}"
