from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=(".env", "../.env"),
        extra="ignore",
    )

    UPLOAD_DIR: str = "data/uploads"

    PROJECT_NAME: str = "BNPL Advisor API"
    API_V1_STR: str = "/api/v1"

    # Set DATABASE_URL=sqlite:///./bnpl_local.db for local runs without Docker/Postgres
    DATABASE_URL: str | None = None

    POSTGRES_USER: str = "bnpl"
    POSTGRES_PASSWORD: str = "bnpl_secret"
    POSTGRES_DB: str = "bnpl_advisor"
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5432

    ML_MODELS_DIR: str = "app/ml_models"

    # v2: RAG + LangChain agents (optional OpenAI — works offline with BM25 + rules)
    OPENAI_API_KEY: str | None = None
    OPENAI_MODEL: str = "gpt-4o-mini"

    # AWS / production hints (used by deploy docs and health)
    AWS_REGION: str = "ap-southeast-1"
    APP_ENV: str = "development"

    # v3: vector RAG, bandit, RL
    USE_VECTOR_RAG: bool = True
    CHROMA_PERSIST_DIR: str = "data/chroma"
    RL_Q_TABLE_PATH: str = "data/rl_q_table.json"
    FINETUNE_ADAPTER_DIR: str = "data/finetune_adapter"
    FINETUNE_BASE_MODEL: str = "microsoft/Phi-3-mini-4k-instruct"

    # APC+ auth & rate limits (off by default for local demo)
    AUTH_REQUIRED: bool = False
    API_KEY: str | None = None
    JWT_SECRET: str = "change-me-in-production-sme-advisor"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRE_MINUTES: int = 1440
    RATE_LIMIT: str = "120/minute"

    @property
    def sqlalchemy_database_uri(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL
        return (
            f"postgresql+psycopg2://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    @property
    def is_sqlite(self) -> bool:
        return self.sqlalchemy_database_uri.startswith("sqlite")


@lru_cache
def get_settings() -> Settings:
    return Settings()
