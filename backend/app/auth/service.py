from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import and_, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.auth.schemas import (
    AuthResponse,
    EntitlementResponse,
    EntitlementsListResponse,
    TokenResponse,
    UserResponse,
)
from app.core.config import Settings
from app.core.errors import AppError
from app.core.security import (
    create_access_token,
    generate_refresh_token,
    hash_password,
    hash_refresh_token,
    verify_password,
)
from app.models.auth import Device, DevicePlatform, EntitlementGrant, Feature, RefreshToken
from app.models.user import Role, RoleName, User, UserRole, UserStatus

DEMO_FEATURE = "demo_access"
DEFAULT_FEATURES = [
    (DEMO_FEATURE, "Demo access to sample content"),
    ("course_access", "Full course access"),
    ("ai_interview", "AI interview entitlement"),
    ("mentor_access", "Mentor messaging"),
]


class AuthService:
    def __init__(self, session: AsyncSession, settings: Settings) -> None:
        self.session = session
        self.settings = settings

    async def register(
        self,
        *,
        email: str,
        password: str,
        display_name: str,
        device_key: str,
        platform: str,
        app_version: str | None,
    ) -> AuthResponse:
        existing = await self.session.scalar(select(User).where(User.email == email.lower()))
        if existing is not None:
            raise AppError("conflict", "Email already registered", status_code=409)

        user = User(
            email=email.lower(),
            display_name=display_name.strip(),
            password_hash=hash_password(password),
            status=UserStatus.ACTIVE,
        )
        self.session.add(user)
        await self.session.flush()

        await self._ensure_student_role(user)
        await self._grant_feature(user.id, DEMO_FEATURE, source="registration")
        device = await self._upsert_device(user.id, device_key, platform, app_version)
        tokens = await self._issue_tokens(user.id, device.id)

        await self.session.commit()
        await self.session.refresh(user, attribute_names=["roles"])
        return AuthResponse(user=self._user_response(user), tokens=tokens)

    async def login(
        self,
        *,
        email: str,
        password: str,
        device_key: str,
        platform: str,
        app_version: str | None,
    ) -> AuthResponse:
        result = await self.session.execute(
            select(User).options(selectinload(User.roles)).where(User.email == email.lower())
        )
        user = result.scalar_one_or_none()
        if user is None or user.password_hash is None or not verify_password(password, user.password_hash):
            raise AppError("unauthenticated", "Invalid email or password", status_code=401)
        if user.status != UserStatus.ACTIVE or user.deleted_at is not None:
            raise AppError("forbidden", "Account is disabled", status_code=403)

        device = await self._upsert_device(user.id, device_key, platform, app_version)
        tokens = await self._issue_tokens(user.id, device.id)
        await self.session.commit()
        return AuthResponse(user=self._user_response(user), tokens=tokens)

    async def refresh(self, *, refresh_token: str, device_key: str) -> TokenResponse:
        token_hash = hash_refresh_token(refresh_token)
        now = datetime.now(UTC)
        result = await self.session.execute(
            select(RefreshToken).where(
                RefreshToken.token_hash == token_hash,
                RefreshToken.revoked_at.is_(None),
                RefreshToken.expires_at > now,
            )
        )
        stored = result.scalar_one_or_none()
        if stored is None:
            raise AppError("unauthenticated", "Invalid refresh token", status_code=401)

        stored.revoked_at = now
        device = await self._upsert_device(stored.user_id, device_key, "other", None)
        tokens = await self._issue_tokens(stored.user_id, device.id)
        await self.session.commit()
        return tokens

    async def logout(self, *, refresh_token: str) -> None:
        token_hash = hash_refresh_token(refresh_token)
        result = await self.session.execute(
            select(RefreshToken).where(
                RefreshToken.token_hash == token_hash,
                RefreshToken.revoked_at.is_(None),
            )
        )
        stored = result.scalar_one_or_none()
        if stored is not None:
            stored.revoked_at = datetime.now(UTC)
            await self.session.commit()

    async def get_entitlements(self, user_id: UUID) -> EntitlementsListResponse:
        now = datetime.now(UTC)
        result = await self.session.execute(
            select(EntitlementGrant).where(
                EntitlementGrant.user_id == user_id,
                EntitlementGrant.revoked_at.is_(None),
                EntitlementGrant.starts_at <= now,
                or_(EntitlementGrant.ends_at.is_(None), EntitlementGrant.ends_at > now),
            )
        )
        grants = result.scalars().all()
        return EntitlementsListResponse(
            features=[
                EntitlementResponse(
                    key=g.feature_key,
                    constraints=g.constraints or {},
                    ends_at=g.ends_at,
                )
                for g in grants
            ]
        )

    async def _ensure_student_role(self, user: User) -> None:
        role = await self.session.scalar(select(Role).where(Role.name == RoleName.STUDENT))
        if role is None:
            raise AppError("internal_error", "Student role is not configured", status_code=500)
        self.session.add(UserRole(user_id=user.id, role_id=role.id))

    async def _grant_feature(self, user_id: UUID, feature_key: str, *, source: str) -> None:
        feature = await self.session.scalar(select(Feature).where(Feature.key == feature_key))
        if feature is None:
            raise AppError("internal_error", f"Feature {feature_key} is not configured", status_code=500)
        self.session.add(
            EntitlementGrant(
                user_id=user_id,
                feature_key=feature_key,
                source=source,
                constraints={},
            )
        )

    async def _upsert_device(
        self,
        user_id: UUID,
        device_key: str,
        platform: str,
        app_version: str | None,
    ) -> Device:
        platform_enum = self._parse_platform(platform)
        result = await self.session.execute(
            select(Device).where(Device.user_id == user_id, Device.device_key == device_key)
        )
        device = result.scalar_one_or_none()
        if device is None:
            device = Device(
                user_id=user_id,
                device_key=device_key,
                platform=platform_enum,
                app_version=app_version,
            )
            self.session.add(device)
            await self.session.flush()
        else:
            device.platform = platform_enum
            device.app_version = app_version
            device.last_seen_at = datetime.now(UTC)
        return device

    async def _issue_tokens(self, user_id: UUID, device_id: UUID) -> TokenResponse:
        access = create_access_token(user_id=user_id, settings=self.settings)
        refresh = generate_refresh_token()
        expires_at = datetime.now(UTC) + timedelta(days=self.settings.refresh_token_expire_days)
        self.session.add(
            RefreshToken(
                user_id=user_id,
                device_id=device_id,
                token_hash=hash_refresh_token(refresh),
                expires_at=expires_at,
            )
        )
        return TokenResponse(
            access_token=access,
            refresh_token=refresh,
            expires_in=self.settings.access_token_expire_minutes * 60,
        )

    @staticmethod
    def _user_response(user: User) -> UserResponse:
        return UserResponse(
            id=user.id,
            email=user.email,
            display_name=user.display_name,
            locale=user.locale,
            roles=[role.name.value for role in user.roles],
        )

    @staticmethod
    def _parse_platform(platform: str) -> DevicePlatform:
        try:
            return DevicePlatform(platform.lower())
        except ValueError:
            return DevicePlatform.OTHER


async def ensure_default_features(session: AsyncSession) -> None:
    for key, description in DEFAULT_FEATURES:
        existing = await session.scalar(select(Feature).where(Feature.key == key))
        if existing is None:
            session.add(Feature(key=key, description=description))
    await session.commit()
