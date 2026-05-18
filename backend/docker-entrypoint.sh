#!/usr/bin/env bash
set -euo pipefail

echo "==> Waiting for PostgreSQL..."
python /app/scripts/wait_for_db.py

echo "==> Initialising database schema and seed data..."
python /app/scripts/init_db.py

echo "==> Starting FastAPI (uvicorn)..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
