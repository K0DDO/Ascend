from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.core.deps import get_current_user
from app.learning.schemas import DueQueueResponse, ReviewResponse, ReviewSignal, TopicProgressResponse
from app.learning.service import LearningService
from app.models.user import User

router = APIRouter(prefix="/learning", tags=["learning"])


@router.post("/reviews", response_model=ReviewResponse, status_code=status.HTTP_201_CREATED)
async def record_review(
    signal: ReviewSignal,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> ReviewResponse:
    service = LearningService(session)
    try:
        return await service.record_review(user.id, signal)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc)) from exc


@router.get("/topics/{topic_id}/progress", response_model=TopicProgressResponse)
async def topic_progress(
    topic_id: UUID,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> TopicProgressResponse:
    return await LearningService(session).topic_progress(user.id, topic_id)


@router.get("/topics/{topic_id}/queue", response_model=DueQueueResponse)
async def due_queue(
    topic_id: UUID,
    limit: int = 20,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
) -> DueQueueResponse:
    return await LearningService(session).due_queue(user.id, topic_id, limit=limit)
