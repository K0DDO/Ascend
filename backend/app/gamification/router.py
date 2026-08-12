from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.core.deps import get_current_user
from app.gamification.schemas import GamificationOverviewResponse
from app.gamification.service import GamificationService
from app.models.user import User

router = APIRouter(prefix="/gamification", tags=["gamification"])


@router.get("/overview", response_model=GamificationOverviewResponse)
async def gamification_overview(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> GamificationOverviewResponse:
    return await GamificationService(session).overview(user.id)
