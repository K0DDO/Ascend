import pytest
from httpx import ASGITransport, AsyncClient

from app.core.config import Settings
from app.main import create_app


@pytest.fixture
def settings() -> Settings:
    return Settings(
        environment="test",
        debug=False,
        database_host="localhost",
        database_port=5432,
        database_user="ascend",
        database_password="ascend",
        database_name="ascend_test",
    )


@pytest.fixture
async def client(settings: Settings):
    app = create_app(settings)
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


@pytest.mark.asyncio
async def test_root(client: AsyncClient) -> None:
    response = await client.get("/")
    assert response.status_code == 200
    body = response.json()
    assert body["health"] == "/api/v1/health"


@pytest.mark.asyncio
async def test_health(client: AsyncClient) -> None:
    response = await client.get("/api/v1/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert body["app"] == "Ascend API"
    assert "timestamp" in body
    assert response.headers.get("X-Request-ID")


@pytest.mark.asyncio
async def test_ready_without_database(monkeypatch, client: AsyncClient) -> None:
    async def fake_check() -> bool:
        return False

    from app.core import database as db_module

    monkeypatch.setattr(db_module, "check_database_connection", fake_check)

    response = await client.get("/api/v1/ready")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "degraded"
    assert body["database"] == "down"
