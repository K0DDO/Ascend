from uuid import UUID

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from tests.conftest import ADMIN_ROLE_ID


async def _register(client: AsyncClient, email: str) -> dict:
    payload = {
        "email": email,
        "password": "password123",
        "display_name": email.split("@")[0],
        "device_id": f"device-{email}",
        "platform": "android",
        "app_version": "0.1.0",
    }
    r = await client.post("/api/v1/auth/register", json=payload)
    assert r.status_code == 200
    return r.json()


async def _make_admin(session: AsyncSession, user_id: UUID) -> None:
    from app.models.user import UserRole

    session.add(UserRole(user_id=user_id, role_id=ADMIN_ROLE_ID))
    await session.commit()


@pytest.mark.asyncio
async def test_admin_requires_role(client: AsyncClient) -> None:
    reg = await _register(client, "regular@example.com")
    token = reg["tokens"]["access_token"]
    resp = await client.get(
        "/api/v1/admin/analytics/overview",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 403


@pytest.mark.asyncio
async def test_admin_analytics_and_entitlement_grant(client: AsyncClient, session: AsyncSession) -> None:
    admin_reg = await _register(client, "admin@example.com")
    student_reg = await _register(client, "grant-target@example.com")
    admin_token = admin_reg["tokens"]["access_token"]
    await _make_admin(session, UUID(admin_reg["user"]["id"]))

    analytics = await client.get(
        "/api/v1/admin/analytics/overview",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert analytics.status_code == 200
    assert analytics.json()["user_count"] >= 2

    grant = await client.post(
        "/api/v1/admin/entitlements/grants",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={
            "user_id": student_reg["user"]["id"],
            "feature_key": "ai_interview",
            "source": "admin-test",
        },
    )
    assert grant.status_code == 200
    assert grant.json()["feature_key"] == "ai_interview"
