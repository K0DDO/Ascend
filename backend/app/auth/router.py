from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.schemas import (
    AuthResponse,
    EntitlementsListResponse,
    LoginRequest,
    LogoutRequest,
    RefreshRequest,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)
from app.auth.service import AuthService
from app.core.config import Settings, get_settings
from app.core.database import get_db_session
from app.core.deps import get_current_user
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["auth"])


def _service(session: AsyncSession, settings: Settings) -> AuthService:
    return AuthService(session, settings)


@router.post("/register", response_model=AuthResponse)
async def register(
    body: RegisterRequest,
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> AuthResponse:
    # Device is registered on first login in mobile flow; allow optional device on register via login after.
    return await _service(session, settings).register(
        email=body.email,
        password=body.password,
        display_name=body.display_name,
        device_key=body.device_id,
        platform=body.platform,
        app_version=body.app_version,
    )


@router.post("/login", response_model=AuthResponse)
async def login(
    body: LoginRequest,
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> AuthResponse:
    return await _service(session, settings).login(
        email=body.email,
        password=body.password,
        device_key=body.device_id,
        platform=body.platform,
        app_version=body.app_version,
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh(
    body: RefreshRequest,
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> TokenResponse:
    return await _service(session, settings).refresh(
        refresh_token=body.refresh_token,
        device_key=body.device_id,
    )


@router.post("/logout", status_code=204)
async def logout(
    body: LogoutRequest,
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> None:
    await _service(session, settings).logout(refresh_token=body.refresh_token)


@router.get("/me", response_model=UserResponse)
async def me(user: User = Depends(get_current_user)) -> UserResponse:
    return UserResponse(
        id=user.id,
        email=user.email,
        display_name=user.display_name,
        locale=user.locale,
        roles=[role.name.value for role in user.roles],
    )
