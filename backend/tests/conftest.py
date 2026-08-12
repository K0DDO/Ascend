import uuid

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.auth.service import ensure_default_features
from app.content.seed import ensure_demo_content
from app.core.config import Settings
from app.core.database import Base, get_db_session
from app.main import create_app
from app.models import content as _content_models  # noqa: F401
from app.models import learning as _learning_models  # noqa: F401
from app.models import srs as _srs_models  # noqa: F401
from app.models.user import Role, RoleName

STUDENT_ROLE_ID = uuid.UUID("00000000-0000-4000-8000-000000000003")


@pytest.fixture
def settings() -> Settings:
    return Settings(
        environment="test",
        jwt_secret_key="test-secret-key-for-auth-tests-32b",
        database_url_override="sqlite+aiosqlite:///:memory:",
    )


@pytest_asyncio.fixture
async def session(settings: Settings):
    engine = create_async_engine(settings.database_url, echo=False)
    session_factory = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with session_factory() as db:
        db.add(
            Role(
                id=STUDENT_ROLE_ID,
                name=RoleName.STUDENT,
                description="Learner account",
            )
        )
        await db.commit()
        await ensure_default_features(db)
        await ensure_demo_content(db)

        yield db

    await engine.dispose()


@pytest_asyncio.fixture
async def client(settings: Settings, session: AsyncSession):
    app = create_app(settings)

    async def override_db():
        yield session

    app.dependency_overrides[get_db_session] = override_db

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac

    app.dependency_overrides.clear()


DEVICE = {
    "device_id": "test-device-001",
    "platform": "android",
    "app_version": "0.1.0",
}
