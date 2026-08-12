import hashlib
from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.auth.service import AuthService
from app.content.schemas import (
    CardPreview,
    CardSourceRef,
    ContentManifestCourse,
    ContentManifestResponse,
    ContentPackageSummary,
    ContentPackagesResponse,
    CourseDetailResponse,
    CourseListResponse,
    CourseSectionResponse,
    CourseSummary,
    SourceBlockResponse,
    SourceDocumentResponse,
    TopicCardsResponse,
    TopicDetailResponse,
    TopicDocumentsResponse,
    TopicSummary,
)
from app.core.config import Settings
from app.core.errors import AppError
from app.models.content import (
    Card,
    CardSourceReference,
    CardStatus,
    CardVersion,
    Course,
    CourseSection,
    PublishStatus,
    SourceDocument,
    SourceVersion,
    Topic,
    TopicDependency,
)
from app.models.learning import LearningEvent, ReviewResult


class ContentService:
    def __init__(self, session: AsyncSession, settings: Settings) -> None:
        self.session = session
        self.settings = settings

    async def list_courses(self, user_id: UUID) -> CourseListResponse:
        feature_keys = await self._feature_keys(user_id)
        result = await self.session.execute(
            select(Course)
            .where(Course.status == PublishStatus.PUBLISHED)
            .order_by(Course.title)
        )
        courses = result.scalars().all()
        summaries: list[CourseSummary] = []
        for course in courses:
            locked = not self._has_access(course.access_feature_key, feature_keys)
            topic_count = await self._published_topic_count(course.id)
            summaries.append(
                CourseSummary(
                    id=course.id,
                    slug=course.slug,
                    title=course.title,
                    description=course.description if not locked else None,
                    content_revision=course.content_revision,
                    locked=locked,
                    access_feature_key=course.access_feature_key,
                    topic_count=topic_count if not locked else 0,
                )
            )
        return CourseListResponse(courses=summaries)

    async def get_course(self, course_id: UUID, user_id: UUID) -> CourseDetailResponse:
        course = await self._get_published_course(course_id)
        feature_keys = await self._feature_keys(user_id)
        locked = not self._has_access(course.access_feature_key, feature_keys)

        sections: list[CourseSectionResponse] = []
        if not locked:
            result = await self.session.execute(
                select(Course)
                .options(selectinload(Course.sections).selectinload(CourseSection.topics))
                .where(Course.id == course_id)
            )
            loaded = result.scalar_one()
            prereq_map = await self._topic_prerequisites(
                [topic.id for section in loaded.sections for topic in section.topics]
            )
            topic_ids = [topic.id for section in loaded.sections for topic in section.topics]
            lock_map = await self._prereq_lock_map(user_id, topic_ids, prereq_map)
            for section in loaded.sections:
                topics = [
                    TopicSummary(
                        id=topic.id,
                        slug=topic.slug,
                        title=topic.title,
                        description=topic.description,
                        position=topic.position,
                        estimated_minutes=topic.estimated_minutes,
                        locked=lock_map.get(topic.id, (False, None))[0],
                        prerequisite_ids=prereq_map.get(topic.id, []),
                    )
                    for topic in section.topics
                    if topic.status == PublishStatus.PUBLISHED
                ]
                sections.append(
                    CourseSectionResponse(
                        id=section.id,
                        title=section.title,
                        position=section.position,
                        topics=topics,
                    )
                )

        return CourseDetailResponse(
            id=course.id,
            slug=course.slug,
            title=course.title,
            description=course.description if not locked else None,
            content_revision=course.content_revision,
            locked=locked,
            access_feature_key=course.access_feature_key,
            sections=sections,
        )

    async def get_topic(self, topic_id: UUID, user_id: UUID) -> TopicDetailResponse:
        topic = await self._get_published_topic(topic_id)
        course = await self._course_for_topic(topic)
        feature_keys = await self._feature_keys(user_id)
        course_locked = not self._has_access(course.access_feature_key, feature_keys)
        prereq_map = await self._topic_prerequisites([topic.id])
        prereq_locked, _ = (await self._prereq_lock_map(user_id, [topic.id], prereq_map)).get(
            topic.id, (False, None)
        )
        locked = course_locked or prereq_locked
        card_count = 0 if locked else await self._published_card_count(topic.id)

        return TopicDetailResponse(
            id=topic.id,
            slug=topic.slug,
            title=topic.title,
            description=topic.description if not course_locked else None,
            estimated_minutes=topic.estimated_minutes,
            course_id=course.id,
            course_slug=course.slug,
            locked=locked,
            prerequisite_ids=prereq_map.get(topic.id, []),
            card_count=card_count,
        )

    async def get_topic_cards(self, topic_id: UUID, user_id: UUID) -> TopicCardsResponse:
        topic = await self._get_published_topic(topic_id)
        course = await self._course_for_topic(topic)
        feature_keys = await self._feature_keys(user_id)
        if not self._has_access(course.access_feature_key, feature_keys):
            raise AppError("forbidden", "Course access required", status_code=403)

        prereq_map = await self._topic_prerequisites([topic.id])
        locked, lock_reason = (await self._prereq_lock_map(user_id, [topic.id], prereq_map)).get(
            topic.id, (False, None)
        )
        if locked:
            return TopicCardsResponse(topic_id=topic_id, cards=[], locked=True, lock_reason=lock_reason)

        result = await self.session.execute(
            select(Card, CardVersion)
            .join(CardVersion, CardVersion.card_id == Card.id)
            .where(
                Card.topic_id == topic_id,
                Card.status == CardStatus.PUBLISHED,
                Card.deleted_at.is_(None),
                CardVersion.published_at.is_not(None),
            )
            .order_by(Card.created_at)
        )
        rows = result.all()
        version_ids = [version.id for _, version in rows]
        refs_by_version = await self._source_refs_for_versions(version_ids)
        cards = [
            CardPreview(
                id=card.id,
                version_id=version.id,
                front=version.front,
                back=version.back,
                difficulty=float(card.difficulty),
                sources=refs_by_version.get(version.id, []),
            )
            for card, version in rows
        ]
        return TopicCardsResponse(topic_id=topic_id, cards=cards, locked=False)

    async def list_topic_documents(self, topic_id: UUID, user_id: UUID) -> TopicDocumentsResponse:
        topic = await self._get_published_topic(topic_id)
        course = await self._course_for_topic(topic)
        feature_keys = await self._feature_keys(user_id)
        if not self._has_access(course.access_feature_key, feature_keys):
            raise AppError("forbidden", "Course access required", status_code=403)

        result = await self.session.execute(
            select(SourceDocument)
            .options(selectinload(SourceDocument.versions).selectinload(SourceVersion.blocks))
            .where(
                SourceDocument.topic_id == topic_id,
                SourceDocument.status == PublishStatus.PUBLISHED,
            )
            .order_by(SourceDocument.title)
        )
        documents: list[SourceDocumentResponse] = []
        for document in result.scalars().all():
            version = self._latest_published_version(document.versions)
            if version is None:
                continue
            documents.append(
                SourceDocumentResponse(
                    id=document.id,
                    title=document.title,
                    topic_id=document.topic_id,
                    version_id=version.id,
                    version=version.version,
                    blocks=[
                        SourceBlockResponse(
                            id=block.id,
                            block_key=block.block_key,
                            type=block.type.value,
                            position=block.position,
                            payload=block.payload,
                        )
                        for block in version.blocks
                    ],
                )
            )
        return TopicDocumentsResponse(topic_id=topic_id, documents=documents)

    async def get_document(self, document_id: UUID, user_id: UUID) -> SourceDocumentResponse:
        result = await self.session.execute(
            select(SourceDocument)
            .options(selectinload(SourceDocument.versions).selectinload(SourceVersion.blocks))
            .where(
                SourceDocument.id == document_id,
                SourceDocument.status == PublishStatus.PUBLISHED,
            )
        )
        document = result.scalar_one_or_none()
        if document is None:
            raise AppError("not_found", "Document not found", status_code=404)

        topic = await self._get_published_topic(document.topic_id)
        course = await self._course_for_topic(topic)
        feature_keys = await self._feature_keys(user_id)
        if not self._has_access(course.access_feature_key, feature_keys):
            raise AppError("forbidden", "Course access required", status_code=403)

        version = self._latest_published_version(document.versions)
        if version is None:
            raise AppError("not_found", "Published source version not found", status_code=404)

        return SourceDocumentResponse(
            id=document.id,
            title=document.title,
            topic_id=document.topic_id,
            version_id=version.id,
            version=version.version,
            blocks=[
                SourceBlockResponse(
                    id=block.id,
                    block_key=block.block_key,
                    type=block.type.value,
                    position=block.position,
                    payload=block.payload,
                )
                for block in version.blocks
            ],
        )

    async def get_manifest(self, user_id: UUID) -> ContentManifestResponse:
        feature_keys = await self._feature_keys(user_id)
        result = await self.session.execute(
            select(Course).where(Course.status == PublishStatus.PUBLISHED).order_by(Course.slug)
        )
        courses = result.scalars().all()
        entries: list[ContentManifestCourse] = []
        max_revision = 0
        for course in courses:
            max_revision = max(max_revision, course.content_revision)
            locked = not self._has_access(course.access_feature_key, feature_keys)
            entries.append(
                ContentManifestCourse(
                    id=course.id,
                    slug=course.slug,
                    content_revision=course.content_revision,
                    hash=self._course_hash(course),
                    locked=locked,
                )
            )
        return ContentManifestResponse(content_revision=max_revision, courses=entries)

    async def list_packages(self, *, since_revision: int | None, user_id: UUID) -> ContentPackagesResponse:
        feature_keys = await self._feature_keys(user_id)
        result = await self.session.execute(
            select(Course).where(Course.status == PublishStatus.PUBLISHED).order_by(Course.slug)
        )
        packages: list[ContentPackageSummary] = []
        for course in result.scalars().all():
            if not self._has_access(course.access_feature_key, feature_keys):
                continue
            if since_revision is not None and course.content_revision <= since_revision:
                continue
            packages.append(
                ContentPackageSummary(
                    id=f"{course.slug}-r{course.content_revision}",
                    course_id=course.id,
                    revision=course.content_revision,
                    size_bytes=0,
                    checksum=self._course_hash(course),
                )
            )
        return ContentPackagesResponse(packages=packages)

    async def _source_refs_for_versions(self, version_ids: list[UUID]) -> dict[UUID, list[CardSourceRef]]:
        if not version_ids:
            return {}
        rows = (
            await self.session.execute(
                select(CardSourceReference, SourceDocument.title)
                .join(SourceDocument, SourceDocument.id == CardSourceReference.document_id)
                .where(CardSourceReference.card_version_id.in_(version_ids))
                .order_by(CardSourceReference.position)
            )
        ).all()
        mapping: dict[UUID, list[CardSourceRef]] = {}
        for ref, title in rows:
            mapping.setdefault(ref.card_version_id, []).append(
                CardSourceRef(
                    document_id=ref.document_id,
                    source_version_id=ref.source_version_id,
                    block_id=ref.block_id,
                    document_title=title,
                )
            )
        return mapping

    async def _topic_mastery(self, user_id: UUID, topic_id: UUID) -> float:
        total = await self._published_card_count(topic_id)
        if total == 0:
            return 1.0
        know_cards = await self.session.scalar(
            select(func.count(func.distinct(LearningEvent.card_id)))
            .join(Card, Card.id == LearningEvent.card_id)
            .where(
                LearningEvent.user_id == user_id,
                Card.topic_id == topic_id,
                Card.deleted_at.is_(None),
                LearningEvent.result == ReviewResult.KNOW,
            )
        )
        return float(know_cards or 0) / float(total)

    async def _prereq_lock_map(
        self,
        user_id: UUID,
        topic_ids: list[UUID],
        prereq_map: dict[UUID, list[UUID]],
    ) -> dict[UUID, tuple[bool, str | None]]:
        result: dict[UUID, tuple[bool, str | None]] = {}
        mastery_cache: dict[UUID, float] = {}
        for topic_id in topic_ids:
            prereqs = prereq_map.get(topic_id, [])
            unmet: list[str] = []
            for prereq_id in prereqs:
                if prereq_id not in mastery_cache:
                    mastery_cache[prereq_id] = await self._topic_mastery(user_id, prereq_id)
                if mastery_cache[prereq_id] < 0.5:
                    title = await self.session.scalar(select(Topic.title).where(Topic.id == prereq_id))
                    unmet.append(title or str(prereq_id))
            if unmet:
                result[topic_id] = (True, f"Сначала закрой: {', '.join(unmet)}")
            else:
                result[topic_id] = (False, None)
        return result

    async def _feature_keys(self, user_id: UUID) -> set[str]:
        entitlements = await AuthService(self.session, self.settings).get_entitlements(user_id)
        return {item.key for item in entitlements.features}

    @staticmethod
    def _has_access(required_feature: str | None, feature_keys: set[str]) -> bool:
        if required_feature is None:
            return True
        return required_feature in feature_keys

    async def _get_published_course(self, course_id: UUID) -> Course:
        course = await self.session.scalar(
            select(Course).where(Course.id == course_id, Course.status == PublishStatus.PUBLISHED)
        )
        if course is None:
            raise AppError("not_found", "Course not found", status_code=404)
        return course

    async def _get_published_topic(self, topic_id: UUID) -> Topic:
        topic = await self.session.scalar(
            select(Topic).where(Topic.id == topic_id, Topic.status == PublishStatus.PUBLISHED)
        )
        if topic is None:
            raise AppError("not_found", "Topic not found", status_code=404)
        return topic

    async def _course_for_topic(self, topic: Topic) -> Course:
        section = await self.session.scalar(
            select(CourseSection).where(CourseSection.id == topic.section_id)
        )
        if section is None:
            raise AppError("internal_error", "Topic section missing", status_code=500)
        return await self._get_published_course(section.course_id)

    async def _published_topic_count(self, course_id: UUID) -> int:
        result = await self.session.scalar(
            select(func.count(Topic.id))
            .select_from(Topic)
            .join(CourseSection, Topic.section_id == CourseSection.id)
            .where(
                CourseSection.course_id == course_id,
                Topic.status == PublishStatus.PUBLISHED,
            )
        )
        return int(result or 0)

    async def _published_card_count(self, topic_id: UUID) -> int:
        result = await self.session.scalar(
            select(func.count(Card.id)).where(
                Card.topic_id == topic_id,
                Card.status == CardStatus.PUBLISHED,
                Card.deleted_at.is_(None),
            )
        )
        return int(result or 0)

    async def _topic_prerequisites(self, topic_ids: list[UUID]) -> dict[UUID, list[UUID]]:
        if not topic_ids:
            return {}
        result = await self.session.execute(
            select(TopicDependency).where(TopicDependency.topic_id.in_(topic_ids))
        )
        mapping: dict[UUID, list[UUID]] = {}
        for dep in result.scalars().all():
            mapping.setdefault(dep.topic_id, []).append(dep.prerequisite_topic_id)
        return mapping

    @staticmethod
    def _latest_published_version(versions: list[SourceVersion]) -> SourceVersion | None:
        published = [v for v in versions if v.published_at is not None]
        if not published:
            return None
        return max(published, key=lambda item: item.version)

    @staticmethod
    def _course_hash(course: Course) -> str:
        payload = f"{course.id}:{course.content_revision}:{course.updated_at.isoformat()}"
        return hashlib.sha256(payload.encode()).hexdigest()[:16]
