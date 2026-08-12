from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.admin.schemas import AnalyticsIngestRequest, AnalyticsIngestResponse
from app.admin.service import AdminService
from app.core.database import get_db_session
from app.core.deps import get_current_user
from app.models.user import User

router = APIRouter(prefix="/analytics", tags=["analytics"])


@router.post("/events", response_model=AnalyticsIngestResponse)
async def ingest_analytics(
    payload: AnalyticsIngestRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> AnalyticsIngestResponse:
    return await AdminService(session).ingest_analytics(user_id=user.id, payload=payload)
