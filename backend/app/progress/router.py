from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.core.deps import get_current_user
from app.models.user import User
from app.progress.schemas import ProgressOverviewResponse
from app.progress.service import ProgressService

router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("/overview", response_model=ProgressOverviewResponse)
async def progress_overview(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> ProgressOverviewResponse:
    return await ProgressService(session).overview(user.id)
