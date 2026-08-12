from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.content.schemas import (
    ContentManifestResponse,
    ContentPackagesResponse,
    CourseDetailResponse,
    CourseListResponse,
    SourceDocumentResponse,
    TopicCardsResponse,
    TopicDetailResponse,
    TopicDocumentsResponse,
)
from app.content.service import ContentService
from app.core.config import Settings, get_settings
from app.core.database import get_db_session
from app.core.deps import get_current_user
from app.models.user import User

router = APIRouter(tags=["content"])


def _service(session: AsyncSession, settings: Settings) -> ContentService:
    return ContentService(session, settings)


@router.get("/courses", response_model=CourseListResponse)
async def list_courses(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> CourseListResponse:
    return await _service(session, settings).list_courses(user.id)


@router.get("/courses/{course_id}", response_model=CourseDetailResponse)
async def get_course(
    course_id: UUID,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> CourseDetailResponse:
    return await _service(session, settings).get_course(course_id, user.id)


@router.get("/topics/{topic_id}", response_model=TopicDetailResponse)
async def get_topic(
    topic_id: UUID,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> TopicDetailResponse:
    return await _service(session, settings).get_topic(topic_id, user.id)


@router.get("/topics/{topic_id}/cards", response_model=TopicCardsResponse)
async def get_topic_cards(
    topic_id: UUID,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> TopicCardsResponse:
    return await _service(session, settings).get_topic_cards(topic_id, user.id)


@router.get("/topics/{topic_id}/documents", response_model=TopicDocumentsResponse)
async def get_topic_documents(
    topic_id: UUID,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> TopicDocumentsResponse:
    return await _service(session, settings).list_topic_documents(topic_id, user.id)


@router.get("/documents/{document_id}", response_model=SourceDocumentResponse)
async def get_document(
    document_id: UUID,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> SourceDocumentResponse:
    return await _service(session, settings).get_document(document_id, user.id)


@router.get("/content/manifest", response_model=ContentManifestResponse)
async def content_manifest(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> ContentManifestResponse:
    return await _service(session, settings).get_manifest(user.id)


@router.get("/content/packages", response_model=ContentPackagesResponse)
async def content_packages(
    since_revision: int | None = Query(default=None),
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session),
    settings: Settings = Depends(get_settings),
) -> ContentPackagesResponse:
    return await _service(session, settings).list_packages(
        since_revision=since_revision,
        user_id=user.id,
    )
