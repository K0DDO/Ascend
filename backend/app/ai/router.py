from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.schemas import InterviewAnswerRequest, InterviewSessionResponse, InterviewStartRequest, MistakeListResponse
from app.ai.service import AIInterviewService
from app.core.config import Settings, get_settings
from app.core.database import get_db_session
from app.core.deps import get_current_user
from app.models.user import User

router = APIRouter(prefix="/ai/interviews", tags=["ai-interview"])


@router.post("/start", response_model=InterviewSessionResponse)
async def start_interview(
    payload: InterviewStartRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> InterviewSessionResponse:
    service = AIInterviewService(session, settings)
    return await service.start(user_id=user.id, topic_id=payload.topic_id, question_count=payload.question_count)


@router.get("/mistakes/deck", response_model=MistakeListResponse)
async def list_mistake_deck(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> MistakeListResponse:
    return await AIInterviewService(session, settings).list_mistakes(user_id=user.id)


@router.get("/{session_id}", response_model=InterviewSessionResponse)
async def get_interview(
    session_id: UUID,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> InterviewSessionResponse:
    return await AIInterviewService(session, settings).get(user_id=user.id, session_id=session_id)


@router.post("/{session_id}/answer", response_model=InterviewSessionResponse)
async def answer_interview(
    session_id: UUID,
    payload: InterviewAnswerRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> InterviewSessionResponse:
    return await AIInterviewService(session, settings).answer(
        user_id=user.id, session_id=session_id, answer=payload.answer
    )


@router.get("/{session_id}/mistakes", response_model=MistakeListResponse)
async def list_session_mistakes(
    session_id: UUID,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> MistakeListResponse:
    return await AIInterviewService(session, settings).list_mistakes(user_id=user.id, session_id=session_id)
