from functools import lru_cache

from pydantic import Field, PostgresDsn, computed_field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        populate_by_name=True,
    )

    app_name: str = "Ascend API"
    app_version: str = "0.1.0"
    environment: str = Field(default="development", pattern="^(development|staging|production|test)$")
    debug: bool = False
    api_v1_prefix: str = "/api/v1"

    database_host: str = "localhost"
    database_port: int = 5432
    database_user: str = "ascend"
    database_password: str = "ascend"
    database_name: str = "ascend"
    database_url_override: str | None = Field(default=None, alias="DATABASE_URL")

    log_level: str = "INFO"
    cors_origins: list[str] = Field(default_factory=lambda: ["http://localhost:3000"])

    jwt_secret_key: str = Field(default="dev-only-change-in-production", min_length=16)
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 30

    @computed_field  # type: ignore[prop-decorator]
    @property
    def database_url(self) -> str:
        if self.database_url_override:
            return self.database_url_override
        return str(
            PostgresDsn.build(
                scheme="postgresql+asyncpg",
                username=self.database_user,
                password=self.database_password,
                host=self.database_host,
                port=self.database_port,
                path=self.database_name,
            )
        )

    @computed_field  # type: ignore[prop-decorator]
    @property
    def database_url_sync(self) -> str:
        url = self.database_url
        return url.replace("postgresql+asyncpg://", "postgresql+psycopg://", 1)


@lru_cache
def get_settings() -> Settings:
    return Settings()
