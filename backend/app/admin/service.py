from __future__ import annotations

import uuid
from datetime import UTC, datetime, timedelta
from decimal import Decimal
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.admin.schemas import (
    AdminAnalyticsOverview,
    AnalyticsIngestRequest,
    AnalyticsIngestResponse,
    CardAdminView,
    CardModerationView,
    CardStatusUpdateRequest,
    CreateCardRequest,
    CreateDocumentRequest,
    DocumentAdminView,
    EntitlementGrantRequest,
    EntitlementGrantView,
    EntitlementRevokeRequest,
)
from app.core.errors import AppError
from app.models.auth import EntitlementGrant
from app.models.content import (
    AnalyticsEvent,
    Card,
    CardSourceReference,
    CardStatus,
    CardVersion,
    Course,
    CourseSection,
    PublishStatus,
    SourceBlock,
    SourceBlockType,
    SourceDocument,
    SourceVersion,
    Topic,
)
from app.models.sync import SyncEvent
from app.models.user import User, UserStatus


class AdminService:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def list_review_queue(self) -> list[CardModerationView]:
        rows = (
            await self.session.execute(
                select(Card, CardVersion.front)
                .outerjoin(CardVersion, CardVersion.card_id == Card.id)
                .where(
                    Card.status == CardStatus.REVIEW_REQUIRED,
                    Card.deleted_at.is_(None),
                )
            )
        ).all()
        items: list[CardModerationView] = []
        for card, front in rows:
            preview = str((front or {}).get("text") or "")[:120]
            items.append(
                CardModerationView(
                    id=card.id,
                    topic_id=card.topic_id,
                    status=card.status.value,
                    front_preview=preview,
                )
            )
        return items

    async def update_card_status(self, card_id: UUID, payload: CardStatusUpdateRequest) -> CardModerationView:
        card = await self.session.scalar(
            select(Card).options(selectinload(Card.versions)).where(Card.id == card_id)
        )
        if card is None or card.deleted_at is not None:
            raise AppError("not_found", "Card not found", status_code=404)
        card.status = CardStatus(payload.status)
        if card.status == CardStatus.PUBLISHED and card.versions:
            latest = max(card.versions, key=lambda v: v.version)
            if latest.published_at is None:
                latest.published_at = datetime.now(UTC)
            await self._bump_course_revision_for_topic(card.topic_id)
        await self.session.commit()
        preview = ""
        if card.versions:
            front = max(card.versions, key=lambda v: v.version).front or {}
            preview = str(front.get("text") or "")[:120]
        return CardModerationView(
            id=card.id,
            topic_id=card.topic_id,
            status=card.status.value,
            front_preview=preview,
        )

    async def create_document(self, topic_id: UUID, payload: CreateDocumentRequest) -> DocumentAdminView:
        topic = await self.session.get(Topic, topic_id)
        if topic is None:
            raise AppError("not_found", "Topic not found", status_code=404)

        now = datetime.now(UTC)
        document = SourceDocument(
            id=uuid.uuid4(),
            topic_id=topic_id,
            title=payload.title,
            status=PublishStatus.PUBLISHED if payload.publish else PublishStatus.DRAFT,
        )
        version = SourceVersion(
            id=uuid.uuid4(),
            document_id=document.id,
            version=1,
            checksum=f"admin-{uuid.uuid4().hex[:8]}",
            published_at=now if payload.publish else None,
        )
        self.session.add(document)
        await self.session.flush()
        self.session.add(version)
        await self.session.flush()
        for block in payload.blocks:
            self.session.add(
                SourceBlock(
                    id=uuid.uuid4(),
                    source_version_id=version.id,
                    block_key=block.block_key,
                    type=SourceBlockType(block.type),
                    position=block.position,
                    payload=block.payload,
                )
            )
        if payload.publish:
            await self._bump_course_revision_for_topic(topic_id)
        await self.session.commit()
        return DocumentAdminView(
            id=document.id,
            topic_id=topic_id,
            title=document.title,
            status=document.status.value,
            version_id=version.id,
            version=version.version,
        )

    async def create_card(self, topic_id: UUID, payload: CreateCardRequest) -> CardAdminView:
        topic = await self.session.get(Topic, topic_id)
        if topic is None:
            raise AppError("not_found", "Topic not found", status_code=404)

        now = datetime.now(UTC)
        card = Card(
            id=uuid.uuid4(),
            topic_id=topic_id,
            status=CardStatus.PUBLISHED if payload.publish else CardStatus.DRAFT,
            difficulty=Decimal(str(round(payload.difficulty, 3))),
        )
        version = CardVersion(
            id=uuid.uuid4(),
            card_id=card.id,
            version=1,
            front={"text": payload.front_text},
            back={"text": payload.back_text},
            metadata_={},
            published_at=now if payload.publish else None,
        )
        self.session.add(card)
        await self.session.flush()
        self.session.add(version)
        await self.session.flush()
        for idx, source in enumerate(payload.sources):
            self.session.add(
                CardSourceReference(
                    id=uuid.uuid4(),
                    card_version_id=version.id,
                    document_id=source.document_id,
                    source_version_id=source.source_version_id,
                    block_id=source.block_id,
                    position=source.position if source.position else idx,
                )
            )
        if payload.publish:
            await self._bump_course_revision_for_topic(topic_id)
        await self.session.commit()
        return CardAdminView(
            id=card.id,
            topic_id=topic_id,
            version_id=version.id,
            status=card.status.value,
            front=version.front,
            back=version.back,
        )

    async def grant_entitlement(self, payload: EntitlementGrantRequest) -> EntitlementGrantView:
        user = await self.session.get(User, payload.user_id)
        if user is None or user.deleted_at is not None:
            raise AppError("not_found", "User not found", status_code=404)
        grant = EntitlementGrant(
            user_id=payload.user_id,
            feature_key=payload.feature_key,
            source=payload.source,
            constraints=payload.constraints,
            starts_at=datetime.now(UTC),
            ends_at=payload.ends_at,
        )
        self.session.add(grant)
        await self.session.commit()
        await self.session.refresh(grant)
        return EntitlementGrantView(
            id=grant.id,
            user_id=grant.user_id,
            feature_key=grant.feature_key,
            source=grant.source,
            starts_at=grant.starts_at,
            ends_at=grant.ends_at,
        )

    async def revoke_entitlement(self, payload: EntitlementRevokeRequest) -> EntitlementGrantView:
        grant = await self.session.scalar(
            select(EntitlementGrant)
            .where(
                EntitlementGrant.user_id == payload.user_id,
                EntitlementGrant.feature_key == payload.feature_key,
            )
            .order_by(EntitlementGrant.starts_at.desc())
        )
        if grant is None:
            raise AppError("not_found", "Entitlement grant not found", status_code=404)
        grant.ends_at = datetime.now(UTC)
        await self.session.commit()
        return EntitlementGrantView(
            id=grant.id,
            user_id=grant.user_id,
            feature_key=grant.feature_key,
            source=grant.source,
            starts_at=grant.starts_at,
            ends_at=grant.ends_at,
        )

    async def ingest_analytics(
        self, *, user_id: UUID | None, payload: AnalyticsIngestRequest
    ) -> AnalyticsIngestResponse:
        event = AnalyticsEvent(
            id=uuid.uuid4(),
            user_id=user_id,
            device_id=payload.device_id,
            event_name=payload.event_name,
            payload_json=payload.payload,
        )
        self.session.add(event)
        await self.session.commit()
        return AnalyticsIngestResponse(id=event.id, accepted=True)

    async def analytics_overview(self) -> AdminAnalyticsOverview:
        user_count = (
            await self.session.execute(
                select(func.count(User.id)).where(User.deleted_at.is_(None), User.status == UserStatus.ACTIVE)
            )
        ).scalar_one()
        since = datetime.now(UTC) - timedelta(hours=24)
        from app.models.ai import AIInterviewSession

        active_sessions = (
            await self.session.execute(
                select(func.count(AIInterviewSession.id)).where(AIInterviewSession.updated_at >= since)
            )
        ).scalar_one()
        cards_in_review = (
            await self.session.execute(
                select(func.count(Card.id)).where(
                    Card.status == CardStatus.REVIEW_REQUIRED,
                    Card.deleted_at.is_(None),
                )
            )
        ).scalar_one()
        sync_total = (await self.session.execute(select(func.count(SyncEvent.id)))).scalar_one()
        return AdminAnalyticsOverview(
            user_count=user_count,
            active_sessions_24h=active_sessions,
            cards_in_review=cards_in_review,
            sync_events_total=sync_total,
        )

    async def _bump_course_revision_for_topic(self, topic_id: UUID) -> None:
        topic = await self.session.get(Topic, topic_id)
        if topic is None:
            return
        section = await self.session.get(CourseSection, topic.section_id)
        if section is None:
            return
        course = await self.session.get(Course, section.course_id)
        if course is None:
            return
        course.content_revision = int(course.content_revision or 1) + 1
