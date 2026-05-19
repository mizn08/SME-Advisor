#!/usr/bin/env bash
set -euo pipefail

mkdir -p /app/backend/data

if [ -z "${DATABASE_URL:-}" ]; then
  export DATABASE_URL="sqlite:////app/backend/data/bnpl_local.db"
  echo "==> DATABASE_URL not set — using SQLite fallback"
else
  export DATABASE_URL="$(python /app/scripts/normalize_db_url.py)"
  echo "==> DATABASE_URL normalized for SQLAlchemy + SSL"
fi

echo "==> Waiting for database..."
python /app/scripts/wait_for_db.py

echo "==> Starting FastAPI (uvicorn)..."
PORT="${PORT:-8000}"
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT}"
