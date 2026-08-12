from datetime import UTC, datetime, timedelta
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    display_name: str = Field(min_length=1, max_length=255)
    device_id: str = Field(min_length=8, max_length=128)
    platform: str = "other"
    app_version: str | None = None


class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    device_id: str = Field(min_length=8, max_length=128)
    platform: str = "other"
    app_version: str | None = None


class RefreshRequest(BaseModel):
    refresh_token: str
    device_id: str = Field(min_length=8, max_length=128)


class LogoutRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class UserResponse(BaseModel):
    id: UUID
    email: str | None
    display_name: str
    locale: str
    roles: list[str]


class AuthResponse(BaseModel):
    user: UserResponse
    tokens: TokenResponse


class EntitlementResponse(BaseModel):
    key: str
    constraints: dict = Field(default_factory=dict)
    ends_at: datetime | None = None


class EntitlementsListResponse(BaseModel):
    features: list[EntitlementResponse]
