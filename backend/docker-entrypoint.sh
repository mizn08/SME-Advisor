#!/usr/bin/env bash
set -euo pipefail

if [ -n "${DATABASE_URL:-}" ] && [[ "${DATABASE_URL}" == postgres://* ]]; then
  export DATABASE_URL="${DATABASE_URL/postgres:\/\//postgresql+psycopg2:\/\/}"
  echo "==> Adjusted DATABASE_URL for SQLAlchemy"
fi

echo "==> Waiting for PostgreSQL..."
python /app/scripts/wait_for_db.py

echo "==> Initialising database schema and seed data..."
python /app/scripts/init_db.py

echo "==> Starting FastAPI (uvicorn)..."
PORT="${PORT:-8000}"
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT}"
