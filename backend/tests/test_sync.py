import pytest
from httpx import AsyncClient


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


async def _first_card(client: AsyncClient, token: str) -> tuple[str, str]:
    courses = await client.get("/api/v1/courses", headers={"Authorization": f"Bearer {token}"})
    for course in courses.json()["courses"]:
        detail = await client.get(
            f"/api/v1/courses/{course['id']}",
            headers={"Authorization": f"Bearer {token}"},
        )
        if detail.status_code != 200:
            continue
        for section in detail.json().get("sections") or []:
            for topic in section.get("topics") or []:
                cards = await client.get(
                    f"/api/v1/topics/{topic['id']}/cards",
                    headers={"Authorization": f"Bearer {token}"},
                )
                if cards.status_code == 200 and cards.json().get("cards"):
                    card = cards.json()["cards"][0]
                    return card["id"], card["version_id"]
    raise AssertionError("No card found")


@pytest.mark.asyncio
async def test_sync_idempotent_review(client: AsyncClient) -> None:
    reg = await _register(client, "sync@example.com")
    token = reg["tokens"]["access_token"]
    card_id, version_id = await _first_card(client, token)

    payload = {
        "device_id": "sync-device",
        "events": [
            {
                "device_id": "sync-device",
                "event_type": "learning.review",
                "idempotency_key": "review-1",
                "payload": {
                    "card_id": card_id,
                    "card_version_id": version_id,
                    "result": "know",
                    "question_ms": 1000,
                    "answer_ms": 500,
                },
            }
        ],
    }
    first = await client.post(
        "/api/v1/sync/events",
        headers={"Authorization": f"Bearer {token}"},
        json=payload,
    )
    assert first.status_code == 200
    assert first.json()["accepted"][0]["status"] == "applied"
    assert first.json()["accepted"][0]["duplicate"] is False

    second = await client.post(
        "/api/v1/sync/events",
        headers={"Authorization": f"Bearer {token}"},
        json=payload,
    )
    assert second.status_code == 200
    assert second.json()["accepted"][0]["duplicate"] is True

    diag = await client.get(
        "/api/v1/sync/diagnostics",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert diag.status_code == 200

    state = await client.get(
        "/api/v1/sync/state",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert state.status_code == 200
    assert "srs_states" in state.json()
    assert "cursor" in state.json()
