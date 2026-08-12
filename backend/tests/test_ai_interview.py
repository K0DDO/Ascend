from datetime import UTC, datetime
from uuid import UUID

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.auth import EntitlementGrant


async def _register(client: AsyncClient, email: str = "ai@example.com") -> dict:
    payload = {
        "email": email,
        "password": "password123",
        "display_name": "AI Student",
        "device_id": "test-device-ai",
        "platform": "android",
        "app_version": "0.1.0",
    }
    r = await client.post("/api/v1/auth/register", json=payload)
    assert r.status_code == 200
    return r.json()


async def _first_available_topic_id(client: AsyncClient, token: str) -> str:
    courses = await client.get("/api/v1/courses", headers={"Authorization": f"Bearer {token}"})
    assert courses.status_code == 200
    for course in courses.json()["courses"]:
        detail = await client.get(
            f"/api/v1/courses/{course['id']}",
            headers={"Authorization": f"Bearer {token}"},
        )
        if detail.status_code != 200:
            continue
        sections = detail.json().get("sections") or []
        for section in sections:
            topics = section.get("topics") or []
            if topics:
                return topics[0]["id"]
    raise AssertionError("No available topic found for interview tests")


@pytest.mark.asyncio
async def test_ai_interview_requires_entitlement(client: AsyncClient) -> None:
    reg = await _register(client, "ai-lock@example.com")
    token = reg["tokens"]["access_token"]

    topic_id = await _first_available_topic_id(client, token)

    start = await client.post(
        "/api/v1/ai/interviews/start",
        headers={"Authorization": f"Bearer {token}"},
        json={"topic_id": topic_id, "question_count": 2},
    )
    assert start.status_code == 403


@pytest.mark.asyncio
async def test_ai_interview_start_answer_flow(client: AsyncClient, session: AsyncSession) -> None:
    reg = await _register(client, "ai-open@example.com")
    token = reg["tokens"]["access_token"]
    user_id = UUID(reg["user"]["id"])

    session.add(
        EntitlementGrant(
            user_id=user_id,
            feature_key="ai_interview",
            source="test",
            constraints={},
            starts_at=datetime.now(UTC),
        )
    )
    await session.commit()

    topic_id = await _first_available_topic_id(client, token)

    start = await client.post(
        "/api/v1/ai/interviews/start",
        headers={"Authorization": f"Bearer {token}"},
        json={"topic_id": topic_id, "question_count": 2},
    )
    assert start.status_code == 200
    body = start.json()
    assert body["status"] == "in_progress"
    assert body["total_questions"] == 2

    session_id = body["session_id"]
    answer = await client.post(
        f"/api/v1/ai/interviews/{session_id}/answer",
        headers={"Authorization": f"Bearer {token}"},
        json={"answer": "This is my grounded answer with python concepts"},
    )
    assert answer.status_code == 200
    answered = answer.json()
    assert answered["current_index"] == 1

    fetched = await client.get(
        f"/api/v1/ai/interviews/{session_id}",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert fetched.status_code == 200
    assert fetched.json()["session_id"] == session_id
