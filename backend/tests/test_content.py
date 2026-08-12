import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_list_courses_shows_demo_unlocked(client: AsyncClient) -> None:
    register = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "courses@example.com",
            "password": "password123",
            "display_name": "Courses",
            "device_id": "device-courses",
            "platform": "android",
        },
    )
    assert register.status_code == 200
    token = register.json()["tokens"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    response = await client.get("/api/v1/courses", headers=headers)
    assert response.status_code == 200
    courses = response.json()["courses"]
    slugs = {course["slug"]: course for course in courses}
    assert "demo-python" in slugs
    assert slugs["demo-python"]["locked"] is False
    assert "python-pro" in slugs
    assert slugs["python-pro"]["locked"] is True


@pytest.mark.asyncio
async def test_get_demo_course_topics(client: AsyncClient) -> None:
    register = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "topics@example.com",
            "password": "password123",
            "display_name": "Topics",
            "device_id": "device-topics",
            "platform": "android",
        },
    )
    token = register.json()["tokens"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    listing = await client.get("/api/v1/courses", headers=headers)
    demo_id = next(c["id"] for c in listing.json()["courses"] if c["slug"] == "demo-python")

    detail = await client.get(f"/api/v1/courses/{demo_id}", headers=headers)
    assert detail.status_code == 200
    body = detail.json()
    assert body["locked"] is False
    assert len(body["sections"]) == 1
    assert len(body["sections"][0]["topics"]) == 2


@pytest.mark.asyncio
async def test_topic_cards_for_demo(client: AsyncClient) -> None:
    register = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "cards@example.com",
            "password": "password123",
            "display_name": "Cards",
            "device_id": "device-cards",
            "platform": "android",
        },
    )
    token = register.json()["tokens"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    listing = await client.get("/api/v1/courses", headers=headers)
    demo_id = next(c["id"] for c in listing.json()["courses"] if c["slug"] == "demo-python")
    detail = await client.get(f"/api/v1/courses/{demo_id}", headers=headers)
    topic_id = detail.json()["sections"][0]["topics"][0]["id"]

    cards = await client.get(f"/api/v1/topics/{topic_id}/cards", headers=headers)
    assert cards.status_code == 200
    assert len(cards.json()["cards"]) == 2


@pytest.mark.asyncio
async def test_content_manifest(client: AsyncClient) -> None:
    register = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "manifest@example.com",
            "password": "password123",
            "display_name": "Manifest",
            "device_id": "device-manifest",
            "platform": "android",
        },
    )
    token = register.json()["tokens"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    response = await client.get("/api/v1/content/manifest", headers=headers)
    assert response.status_code == 200
    body = response.json()
    assert body["content_revision"] >= 1
    assert len(body["courses"]) >= 2
