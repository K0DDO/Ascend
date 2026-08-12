from datetime import UTC, datetime
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
    reg = await _register(client, "regular2@example.com")
    token = reg["tokens"]["access_token"]
    resp = await client.get(
        "/api/v1/admin/analytics/overview",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 403


@pytest.mark.asyncio
async def test_admin_create_card_and_document(client: AsyncClient, session: AsyncSession) -> None:
    admin_reg = await _register(client, "admin-author@example.com")
    await _make_admin(session, UUID(admin_reg["user"]["id"]))
    token = admin_reg["tokens"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    courses = await client.get("/api/v1/courses", headers=headers)
    assert courses.status_code == 200
    unlocked = [c for c in courses.json()["courses"] if not c["locked"]]
    assert unlocked, "expected unlocked demo course"
    course_id = unlocked[0]["id"]
    detail = await client.get(f"/api/v1/courses/{course_id}", headers=headers)
    assert detail.status_code == 200
    topics = [t for s in detail.json()["sections"] for t in s["topics"]]
    assert topics
    topic_id = topics[0]["id"]

    doc = await client.post(
        f"/api/v1/admin/content/topics/{topic_id}/documents",
        headers=headers,
        json={
            "title": "Admin Doc",
            "publish": True,
            "blocks": [
                {"block_key": "p1", "type": "paragraph", "position": 1, "payload": {"text": "Hello source"}}
            ],
        },
    )
    assert doc.status_code == 200
    document_id = doc.json()["id"]
    version_id = doc.json()["version_id"]

    card = await client.post(
        f"/api/v1/admin/content/topics/{topic_id}/cards",
        headers=headers,
        json={
            "front_text": "Admin question?",
            "back_text": "Admin answer",
            "publish": True,
            "sources": [
                {
                    "document_id": document_id,
                    "source_version_id": version_id,
                    "position": 0,
                }
            ],
        },
    )
    assert card.status_code == 200
    assert card.json()["status"] == "published"

    cards = await client.get(f"/api/v1/topics/{topic_id}/cards", headers=headers)
    assert cards.status_code == 200
    assert any(c["front"]["text"] == "Admin question?" for c in cards.json()["cards"])


@pytest.mark.asyncio
async def test_admin_analytics_and_entitlement_grant(client: AsyncClient, session: AsyncSession) -> None:
    admin_reg = await _register(client, "admin2@example.com")
    student_reg = await _register(client, "grant-target2@example.com")
    admin_token = admin_reg["tokens"]["access_token"]
    await _make_admin(session, UUID(admin_reg["user"]["id"]))

    analytics = await client.get(
        "/api/v1/admin/analytics/overview",
        headers={"Authorization": f"Bearer {admin_token}"},
    )
    assert analytics.status_code == 200

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

    revoke = await client.post(
        "/api/v1/admin/entitlements/revoke",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"user_id": student_reg["user"]["id"], "feature_key": "ai_interview"},
    )
    assert revoke.status_code == 200
    assert revoke.json()["ends_at"] is not None
