# BNPL Advisor for SMEs (Malaysia) — APC2026

End-to-end prototype: **FastAPI + PostgreSQL + scikit-learn / XGBoost** backend and **Flutter** mobile client for Malaysian SME financing decisions (BNPL vs micro-credit vs grants).

## Quick start (no Docker — SQLite)

If Docker/PostgreSQL are not installed:

```powershell
cd bnpl_advisor_mobile\backend
.\run_local.ps1
```

Uses `bnpl_local.db` in the backend folder. API: `http://127.0.0.1:8000/docs`

## Running with Docker (backend + PostgreSQL)

**Prerequisites:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) with Compose v2.

```powershell
cd bnpl_advisor_mobile
copy .env.example .env
docker compose up --build
# or: make up
```

| Service | URL |
|---------|-----|
| **API / Swagger** | http://localhost:8000/docs |
| **Health** | http://localhost:8000/health |
| **PostgreSQL** | `localhost:5432` (user/pass/db from `.env`) |
| **pgAdmin** (optional) | `docker compose --profile tools up -d` → http://localhost:5050 |

**What happens on startup**

1. `db` starts and passes a healthcheck.
2. `backend` waits for Postgres (`scripts/wait_for_db.py`).
3. `scripts/init_db.py` creates tables and seeds 3 SMEs, **~6 months of transactions**, BNPL offers, micro-credit lines, and government schemes.
4. Uvicorn serves the API on port **8000**.

**Flutter connection**

| Target | API base URL |
|--------|----------------|
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator / desktop | `http://127.0.0.1:8000` |
| Physical phone (same Wi‑Fi) | `http://<your-PC-LAN-IP>:8000` |

```powershell
flutter run --dart-define=API_BASE=http://10.0.2.2:8000
```

**Makefile shortcuts:** `make up`, `make down`, `make logs`, `make health`, `make tools` (pgAdmin).

ML `.pkl` files are baked into the image at `backend/app/ml_models/` (also kept under `backend/ml_pipeline/models/` for training).

### Backend environment

| Variable | Default (`.env.example`) |
|----------|--------------------------|
| `DATABASE_URL` | `postgresql+psycopg2://postgres:postgres@db:5432/bnpl_db` (in Compose) |
| `POSTGRES_USER` / `POSTGRES_PASSWORD` / `POSTGRES_DB` | `postgres` / `postgres` / `bnpl_db` |
| `ML_MODELS_DIR` | `/app/backend/app/ml_models` (container) |

## API overview

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/upload-csv` | Multipart: `sme_id`, `file` (CSV) |
| `GET` | `/sme/{id}/dashboard` | KPIs + monthly revenue/expense series |
| `POST` | `/predict` | Purchase simulation + ML/rule recommendation + SHAP-style factors |
| `GET` | `/gov-aid` | Government / agency schemes |
| `GET` | `/sme/{id}/predictions` | Prediction history |
| `GET` | `/predictions/{id}` | Single prediction detail |
| `GET` | `/model-metrics` | Demo transparency metrics for the Performance screen |
| `GET` | `/health` | Liveness |

## Machine learning

```powershell
cd bnpl_advisor_mobile\backend
python ml_pipeline\scripts\generate_synthetic_data.py
python ml_pipeline\scripts\train_models.py
```

- Training data: `ml_pipeline/data/ml_training.csv` (synthetic scenarios + labels).
- Transactions sample: `ml_pipeline/data/sample_sme_transactions.csv` (640 rows across 3 SMEs).
- Saved models: `ml_pipeline/models/*.pkl` (used automatically by `/predict` when present).

**SHAP:** Optional. Core `requirements.txt` omits `shap` so Windows installs without C++ build tools. Docker installs `requirements-shap.txt`. The API falls back to heuristic attributions if SHAP is unavailable.

Notebook: `backend/ml_pipeline/notebooks/train_models.ipynb`.

## Flutter app

```powershell
cd bnpl_advisor_mobile\mobile_app
flutter create .   # generates android/ ios/ web/ if missing
flutter pub get
flutter run
```

- **Android emulator:** backend base URL defaults to `http://10.0.2.2:8000`.
- **iOS simulator / desktop:** defaults to `http://127.0.0.1:8000`.
- **Physical device:** `flutter run --dart-define=API_BASE=http://<your-LAN-IP>:8000`

See `mobile_app/README.md` for UI map (Health / Simulate / AI Advisor / Grants / Performance) and CSV format.

## Scripts

- `start.ps1` — Docker Compose for backend from repo root.
- `start.sh` — Same for Unix shells.

## Seeded SMEs

After first API boot, the database contains SMEs **1–3** (Kopi Maju, Harapan Agro, Urban Digital), BNPL offers, micro-credit lines, and government schemes. Upload CSV for an SME ID, then open the **Health** tab.

## Project layout

```
bnpl_advisor_mobile/
├── backend/              # FastAPI, SQLAlchemy, ML pipeline, Dockerfile
│   ├── app/ml_models/    # Bundled .pkl models (copied into Docker image)
│   └── docker-entrypoint.sh
├── mobile_app/           # Flutter client (not containerised)
├── scripts/              # wait_for_db.py, init_db.py
├── docker-compose.yml    # backend + db (+ optional pgAdmin)
├── .env.example
├── Makefile
├── start.ps1
└── README.md
```


