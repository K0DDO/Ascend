from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import Settings, get_settings
from app.core.database import get_db_session
from app.core.deps import get_current_user
from app.mentor.schemas import (
    AssignmentCommentRequest,
    AssignmentCreateRequest,
    AssignmentView,
    MentorLinkRequest,
    MentorLinkView,
    MentorProgressSnapshot,
    MentorStudentView,
)
from app.mentor.service import MentorService
from app.models.user import User

router = APIRouter(prefix="/mentor", tags=["mentor"])


@router.post("/links", response_model=MentorLinkView)
async def link_student(
    payload: MentorLinkRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> MentorLinkView:
    return await MentorService(session, settings).link_student(
        mentor=user, student_user_id=payload.student_user_id
    )


@router.get("/students", response_model=list[MentorStudentView])
async def list_students(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> list[MentorStudentView]:
    return await MentorService(session, settings).list_students(mentor=user)


@router.get("/students/{student_user_id}/progress", response_model=MentorProgressSnapshot)
async def student_progress(
    student_user_id: UUID,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> MentorProgressSnapshot:
    return await MentorService(session, settings).student_progress(
        mentor=user, student_user_id=student_user_id
    )


@router.post("/assignments", response_model=AssignmentView)
async def create_assignment(
    payload: AssignmentCreateRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> AssignmentView:
    return await MentorService(session, settings).create_assignment(mentor=user, payload=payload)


@router.get("/assignments", response_model=list[AssignmentView])
async def list_mentor_assignments(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> list[AssignmentView]:
    return await MentorService(session, settings).list_assignments_for_mentor(mentor=user)


@router.get("/assignments/mine", response_model=list[AssignmentView])
async def list_my_assignments(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> list[AssignmentView]:
    return await MentorService(session, settings).list_assignments_for_student(student=user)


@router.post("/assignments/{assignment_id}/comments", response_model=AssignmentView)
async def comment_assignment(
    assignment_id: UUID,
    payload: AssignmentCommentRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> AssignmentView:
    return await MentorService(session, settings).add_assignment_comment(
        mentor=user, assignment_id=assignment_id, note=payload.note
    )
