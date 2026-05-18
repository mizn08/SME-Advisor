from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.db.session import SessionLocal
from app.services.database_init import init_database


@asynccontextmanager
async def lifespan(_: FastAPI):
    db = SessionLocal()
    try:
        init_database(db)
    finally:
        db.close()
    yield


app = FastAPI(title="BNPL Advisor for SMEs", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(api_router)


@app.get("/health")
def health():
    return {"status": "ok"}
