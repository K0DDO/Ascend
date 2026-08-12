from __future__ import annotations

import uuid
from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.admin.schemas import (
    AdminAnalyticsOverview,
    CardModerationView,
    CardStatusUpdateRequest,
    EntitlementGrantRequest,
    EntitlementGrantView,
)
from app.core.errors import AppError
from app.models.auth import EntitlementGrant
from app.models.content import Card, CardStatus, CardVersion
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
        card = await self.session.get(Card, card_id)
        if card is None or card.deleted_at is not None:
            raise AppError("not_found", "Card not found", status_code=404)
        card.status = CardStatus(payload.status)
        await self.session.commit()
        preview = ""
        if card.versions:
            front = card.versions[-1].front or {}
            preview = str(front.get("text") or "")[:120]
        return CardModerationView(
            id=card.id,
            topic_id=card.topic_id,
            status=card.status.value,
            front_preview=preview,
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
        )

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
        sync_total = (
            await self.session.execute(select(func.count(SyncEvent.id)))
        ).scalar_one()
        return AdminAnalyticsOverview(
            user_count=user_count,
            active_sessions_24h=active_sessions,
            cards_in_review=cards_in_review,
            sync_events_total=sync_total,
        )
