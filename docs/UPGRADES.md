# APC+ sensible upgrades (v4)

## High impact (demo & judges)

| Feature | API / app |
|---------|-----------|
| Side-by-side compare | `POST /compare` · drawer **Compare financing** |
| Cash forecast & alerts | `GET /sme/{id}/dashboard` → `alerts`, `runway_days_est` |
| Malay / English | **Settings → Language** |
| Offline dashboard | Cached when API fails |
| PDF + share report | Simulator result → **Share** / **PDF** |
| Onboarding | First launch wizard |

## ML & data

| Feature | Where |
|---------|--------|
| LightGBM ensemble | `train_models.py` + `ml_predictor.py` |
| Bandit → training labels | `python backend/ml_pipeline/scripts/export_bandit_labels.py` |
| Gov scheme refresh | `POST /gov-aid/refresh` (JSON catalog) |
| Islamic products | Seed + compare `islamic_only` |
| SST estimate | Compare `include_sst` |

## Security & ops

| Feature | Config |
|---------|--------|
| JWT (optional) | `POST /auth/token` password `sme2026` · `AUTH_REQUIRED=true` |
| Rate limit | `RATE_LIMIT=120/minute` |
| Audit log | `audit_log` table |
| CI | `.github/workflows/ci.yml` |
| HTTPS | `deploy/aws/nginx-https.conf` |
| DB backup | `deploy/aws/backup-db.sh` |

## Flutter drawer

- Upload CSV
- AI Insights
- Compare financing
- Settings (dark mode, language, text size, biometric)
