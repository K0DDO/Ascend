import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_register_login_refresh_flow(client: AsyncClient) -> None:
    register_payload = {
        "email": "student@example.com",
        "password": "password123",
        "display_name": "Student",
        **{
            "device_id": "test-device-001",
            "platform": "android",
            "app_version": "0.1.0",
        },
    }
    register = await client.post("/api/v1/auth/register", json=register_payload)
    assert register.status_code == 200
    reg_body = register.json()
    assert reg_body["user"]["email"] == "student@example.com"
    assert "student" in reg_body["user"]["roles"]

    login = await client.post(
        "/api/v1/auth/login",
        json={
            "email": "student@example.com",
            "password": "password123",
            "device_id": "test-device-001",
            "platform": "android",
        },
    )
    assert login.status_code == 200
    tokens = login.json()["tokens"]

    me = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {tokens['access_token']}"},
    )
    assert me.status_code == 200
    assert me.json()["display_name"] == "Student"

    entitlements = await client.get(
        "/api/v1/me/entitlements",
        headers={"Authorization": f"Bearer {tokens['access_token']}"},
    )
    assert entitlements.status_code == 200
    keys = {item["key"] for item in entitlements.json()["features"]}
    assert "demo_access" in keys

    refresh = await client.post(
        "/api/v1/auth/refresh",
        json={
            "refresh_token": tokens["refresh_token"],
            "device_id": "test-device-001",
        },
    )
    assert refresh.status_code == 200
    new_tokens = refresh.json()
    assert new_tokens["refresh_token"] != tokens["refresh_token"]
    assert new_tokens["access_token"] is not None


@pytest.mark.asyncio
async def test_register_duplicate_email(client: AsyncClient) -> None:
    payload = {
        "email": "dup@example.com",
        "password": "password123",
        "display_name": "One",
        "device_id": "device-a",
        "platform": "android",
    }
    assert (await client.post("/api/v1/auth/register", json=payload)).status_code == 200
    dup = await client.post("/api/v1/auth/register", json=payload)
    assert dup.status_code == 409
    assert dup.json()["error"]["code"] == "conflict"


@pytest.mark.asyncio
async def test_login_invalid_password(client: AsyncClient) -> None:
    await client.post(
        "/api/v1/auth/register",
        json={
            "email": "user@example.com",
            "password": "password123",
            "display_name": "User",
            "device_id": "device-b",
            "platform": "android",
        },
    )
    bad = await client.post(
        "/api/v1/auth/login",
        json={
            "email": "user@example.com",
            "password": "wrong-password",
            "device_id": "device-b",
            "platform": "android",
        },
    )
    assert bad.status_code == 401
