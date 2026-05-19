# Deploy from GitHub → Render (step-by-step)

After you push to **https://github.com/mizn08/SME-Advisor**, connect Render once; every push to `main` redeploys automatically.

## Part 1 — Push to GitHub (already set up)

Your remote: `origin` → `https://github.com/mizn08/SME-Advisor.git`

```powershell
cd c:\Users\mizn\Desktop\APC\bnpl_advisor_mobile
git add -A
git status
git commit -m "v4: RAG, agents, Render Docker, CI, web demo, APC upgrades"
git push origin main
```

GitHub Actions (`.github/workflows/ci.yml`) will:

- Build `backend/Dockerfile.render` with Docker
- Smoke-test `/health` in a container
- Run Python import + Flutter analyze

Check: **GitHub repo → Actions** tab.

## Part 2 — Connect Render to GitHub

1. Go to [dashboard.render.com](https://dashboard.render.com) → sign in with **GitHub**.
2. **New +** → **PostgreSQL**
   - Name: `sme-advisor-db`
   - Region: Singapore (or closest to Malaysia)
   - Free plan → **Create**
3. **New +** → **Web Service** → **Build and deploy from a Git repository**
   - Connect **mizn08/SME-Advisor**
   - If the repo root is the folder above `bnpl_advisor_mobile`, set **Root Directory** to `bnpl_advisor_mobile`

| Setting | Value |
|---------|--------|
| **Branch** | `main` |
| **Runtime** | Docker |
| **Dockerfile Path** | `backend/Dockerfile.render` |
| **Docker build context** | `.` |
| **Instance** | Free (or Starter to avoid sleep) |

**Environment variables** (Web Service → Environment):

| Key | Value |
|-----|--------|
| `DATABASE_URL` | Link from Postgres service **or** paste Internal URL and change `postgres://` → `postgresql+psycopg2://` |
| `ML_MODELS_DIR` | `/app/backend/app/ml_models` |
| `USE_VECTOR_RAG` | `false` |
| `APP_ENV` | `production` |

Entrypoint auto-fixes `postgres://` if you paste Render’s URL as-is.

4. **Create Web Service** — wait for build (8–15 min first time).
5. Open: `https://sme-advisor-api.onrender.com/health` and `/docs`.

**Auto-deploy:** Settings → **Auto-Deploy** = Yes → every `git push` to `main` triggers a new deploy.

## Part 3 — Blueprint (alternative)

**New +** → **Blueprint** → select repo → path: `deploy/render/render.yaml`

Creates API + Postgres in one step. Then set `OPENAI_API_KEY` manually if needed.

## Part 4 — Flutter web (optional)

On your PC after API is live:

```powershell
.\scripts\build_web.ps1 -ApiBase https://sme-advisor-api.onrender.com
```

**New +** → **Static Site** → same repo → publish directory `mobile_app/build/web` (commit `build/web` on a `gh-pages` branch or use Netlify drop).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Build fails on Render | Logs → check Docker; confirm `Dockerfile.render` path |
| CI fails on push | GitHub → Actions → open failed job |
| DB connection error | `DATABASE_URL` must use `postgresql+psycopg2://` |
| 502 cold start | Wait 60s; free tier sleeps when idle |

## Links for APC submission

- **API:** `https://<your-service>.onrender.com/docs`
- **GitHub:** `https://github.com/mizn08/SME-Advisor`
- **Web:** Static site URL after step 4
