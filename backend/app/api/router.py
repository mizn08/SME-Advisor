from fastapi import APIRouter

from app.api.endpoints import (
    advanced,
    agent_v2,
    auth,
    bandit,
    catalog,
    chat,
    compare,
    dashboard,
    grants,
    history,
    insights,
    metrics,
    predict,
    profile,
    report,
    upload,
)

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(upload.router)
api_router.include_router(compare.router)
api_router.include_router(catalog.router)
api_router.include_router(grants.router)
api_router.include_router(profile.router)
api_router.include_router(report.router)
api_router.include_router(dashboard.router)
api_router.include_router(predict.router)
api_router.include_router(history.router)
api_router.include_router(metrics.router)
api_router.include_router(chat.router)
api_router.include_router(agent_v2.router)
api_router.include_router(insights.router)
api_router.include_router(bandit.router)
api_router.include_router(advanced.router)
