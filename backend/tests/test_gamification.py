import pytest
from httpx import AsyncClient


async def _register_and_token(client: AsyncClient, email: str) -> str:
    payload = {
        "email": email,
        "password": "password123",
        "display_name": "Student",
        "device_id": "test-device-gamification",
        "platform": "android",
        "app_version": "0.1.0",
    }
    register = await client.post("/api/v1/auth/register", json=payload)
    assert register.status_code == 200
    return register.json()["tokens"]["access_token"]


@pytest.mark.asyncio
async def test_gamification_overview_returns_shape(client: AsyncClient) -> None:
    token = await _register_and_token(client, "gamification@example.com")
    response = await client.get(
        "/api/v1/gamification/overview",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200
    body = response.json()
    assert "streak_days" in body
    assert "xp_total" in body
    assert "xp_today" in body
    assert "daily_goal_reviews" in body
    assert "daily_progress_reviews" in body
    assert "achievements" in body
