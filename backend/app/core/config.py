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
