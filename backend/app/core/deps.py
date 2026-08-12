import uuid
from datetime import datetime

from fastapi import Depends, Header
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import Settings, get_settings
from app.core.database import get_db_session
from app.core.errors import AppError
from app.core.security import decode_access_token
from app.models.user import RoleName, User, UserStatus


async def get_current_user(
    authorization: str | None = Header(default=None),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> User:
    if not authorization or not authorization.startswith("Bearer "):
        raise AppError("unauthenticated", "Authentication required", status_code=401)

    token = authorization.removeprefix("Bearer ").strip()
    try:
        user_id = decode_access_token(token, settings)
    except Exception as exc:
        raise AppError("unauthenticated", "Invalid or expired token", status_code=401) from exc

    result = await session.execute(
        select(User)
        .options(selectinload(User.roles))
        .where(User.id == user_id, User.deleted_at.is_(None))
    )
    user = result.scalar_one_or_none()
    if user is None or user.status != UserStatus.ACTIVE:
        raise AppError("unauthenticated", "User not found or inactive", status_code=401)
    return user


async def get_optional_user(
    authorization: str | None = Header(default=None),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> User | None:
    if not authorization or not authorization.startswith("Bearer "):
        return None
    try:
        return await get_current_user(authorization, session, settings)
    except AppError:
        return None


def _user_has_role(user: User, role: RoleName) -> bool:
    return any(r.name == role for r in user.roles)


async def require_admin(user: User = Depends(get_current_user)) -> User:
    if not _user_has_role(user, RoleName.ADMIN):
        raise AppError("forbidden", "Admin role required", status_code=403)
    return user


async def require_mentor_or_admin(user: User = Depends(get_current_user)) -> User:
    if _user_has_role(user, RoleName.MENTOR) or _user_has_role(user, RoleName.ADMIN):
        return user
    raise AppError("forbidden", "Mentor or admin role required", status_code=403)
