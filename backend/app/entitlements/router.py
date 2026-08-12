from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.auth.schemas import EntitlementsListResponse
from app.auth.service import AuthService
from app.core.config import Settings, get_settings
from app.core.database import get_db_session
from app.core.deps import get_current_user
from app.models.user import User

router = APIRouter(prefix="/me", tags=["me"])


@router.get("/entitlements", response_model=EntitlementsListResponse)
async def my_entitlements(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> EntitlementsListResponse:
    return await AuthService(session, settings).get_entitlements(user.id)
