# Local API without Docker — uses SQLite (bnpl_local.db in backend folder)
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$env:DATABASE_URL = "sqlite:///./bnpl_local.db"
$env:PYTHONPATH = "."
$env:ML_MODELS_DIR = "app/ml_models"

Write-Host "Starting BNPL Advisor API on http://127.0.0.1:8000 (SQLite)" -ForegroundColor Cyan
Write-Host "For PostgreSQL stack use: cd .. && docker compose up --build" -ForegroundColor DarkGray
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
