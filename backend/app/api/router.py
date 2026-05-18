from fastapi import APIRouter

from app.api.endpoints import dashboard, history, metrics, predict, upload

api_router = APIRouter()
api_router.include_router(upload.router)
api_router.include_router(dashboard.router)
api_router.include_router(predict.router)
api_router.include_router(history.router)
api_router.include_router(metrics.router)
