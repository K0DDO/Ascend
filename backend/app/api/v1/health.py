from datetime import UTC, datetime

from fastapi import APIRouter

from app.api.v1.schemas.health import HealthResponse, ReadinessResponse
from app.core.config import get_settings
from app.core.database import check_database_connection

router = APIRouter(tags=["health"])


@router.get("/health", response_model=HealthResponse)
async def health() -> HealthResponse:
    settings = get_settings()
    return HealthResponse(
        status="ok",
        app=settings.app_name,
        version=settings.app_version,
        environment=settings.environment,
        timestamp=datetime.now(UTC),
    )


@router.get("/ready", response_model=ReadinessResponse)
async def ready() -> ReadinessResponse:
    settings = get_settings()
    db_ok = await check_database_connection()
    return ReadinessResponse(
        status="ok" if db_ok else "degraded",
        app=settings.app_name,
        version=settings.app_version,
        environment=settings.environment,
        timestamp=datetime.now(UTC),
        database="up" if db_ok else "down",
    )
