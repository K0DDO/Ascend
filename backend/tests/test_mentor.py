from datetime import UTC, datetime
from uuid import UUID

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.auth import EntitlementGrant
from app.models.user import Role, RoleName, UserRole
from tests.conftest import MENTOR_ROLE_ID


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


async def _make_mentor(session: AsyncSession, user_id: UUID) -> None:
    session.add(UserRole(user_id=user_id, role_id=MENTOR_ROLE_ID))
    await session.commit()


@pytest.mark.asyncio
async def test_mentor_link_and_assignment(client: AsyncClient, session: AsyncSession) -> None:
    mentor_reg = await _register(client, "mentor@example.com")
    student_reg = await _register(client, "student@example.com")
    mentor_token = mentor_reg["tokens"]["access_token"]
    student_token = student_reg["tokens"]["access_token"]
    mentor_id = mentor_reg["user"]["id"]
    student_id = student_reg["user"]["id"]

    await _make_mentor(session, UUID(mentor_id))

    forbidden = await client.post(
        "/api/v1/mentor/links",
        headers={"Authorization": f"Bearer {student_token}"},
        json={"student_user_id": student_id},
    )
    assert forbidden.status_code == 403

    link = await client.post(
        "/api/v1/mentor/links",
        headers={"Authorization": f"Bearer {mentor_token}"},
        json={"student_user_id": student_id},
    )
    assert link.status_code == 200

    assignment = await client.post(
        "/api/v1/mentor/assignments",
        headers={"Authorization": f"Bearer {mentor_token}"},
        json={"student_user_id": student_id, "title": "Review AsyncIO"},
    )
    assert assignment.status_code == 200

    mine = await client.get(
        "/api/v1/mentor/assignments/mine",
        headers={"Authorization": f"Bearer {student_token}"},
    )
    assert mine.status_code == 200
    assert len(mine.json()) == 1

    progress = await client.get(
        f"/api/v1/mentor/students/{student_id}/progress",
        headers={"Authorization": f"Bearer {mentor_token}"},
    )
    assert progress.status_code == 200


@pytest.mark.asyncio
async def test_mentor_access_via_entitlement(client: AsyncClient, session: AsyncSession) -> None:
    reg = await _register(client, "mentor-ent@example.com")
    token = reg["tokens"]["access_token"]
    user_id = UUID(reg["user"]["id"])
    session.add(
        EntitlementGrant(
            user_id=user_id,
            feature_key="mentor_access",
            source="test",
            constraints={},
            starts_at=datetime.now(UTC),
        )
    )
    await session.commit()

    students = await client.get(
        "/api/v1/mentor/students",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert students.status_code == 200
