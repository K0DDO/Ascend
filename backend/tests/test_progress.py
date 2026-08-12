import pytest
from httpx import AsyncClient


async def _register_and_token(client: AsyncClient, email: str) -> str:
    payload = {
        "email": email,
        "password": "password123",
        "display_name": "Student",
        "device_id": "test-device-progress",
        "platform": "android",
        "app_version": "0.1.0",
    }
    register = await client.post("/api/v1/auth/register", json=payload)
    assert register.status_code == 200
    return register.json()["tokens"]["access_token"]


@pytest.mark.asyncio
async def test_progress_overview_returns_shape(client: AsyncClient) -> None:
    token = await _register_and_token(client, "progress@example.com")
    response = await client.get(
        "/api/v1/progress/overview",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200
    body = response.json()
    assert "total_reviews" in body
    assert "know_rate" in body
    assert "readiness" in body
    assert "weak_areas" in body
    assert "activity" in body
    assert isinstance(body["activity"], list)
