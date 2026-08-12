import uuid
from datetime import UTC, datetime

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.learning.schemas import DueQueueResponse, DueQueueItem, ReviewResponse, ReviewSignal, TopicProgressResponse
from app.models.content import Card, CardVersion
from app.models.learning import LearningEvent, ReviewResult
from app.models.srs import CardMemoryState
from app.srs.algorithm import ReviewSignalInput, retrievability
from app.srs.service import SRSService, _row_to_state


class LearningService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def record_review(
        self,
        user_id: uuid.UUID,
        signal: ReviewSignal,
    ) -> ReviewResponse:
        card = await self._session.get(Card, signal.card_id)
        if card is None:
            raise ValueError("card_not_found")

        version = await self._session.get(CardVersion, signal.card_version_id)
        if version is None or version.card_id != card.id:
            raise ValueError("card_version_not_found")

        completed_at = signal.completed_at or datetime.now(UTC)

        event = LearningEvent(
            id=uuid.uuid4(),
            user_id=user_id,
            card_id=signal.card_id,
            card_version_id=signal.card_version_id,
            result=ReviewResult(signal.result),
            question_ms=signal.question_ms,
            answer_ms=signal.answer_ms,
            source_opened=signal.source_opened,
            completed_at=completed_at,
        )
        self._session.add(event)

        # Update SRS state
        srs_signal = ReviewSignalInput(
            result=signal.result,
            question_ms=signal.question_ms,
            answer_ms=signal.answer_ms,
            source_opened=signal.source_opened,
            card_difficulty=float(card.difficulty),
        )
        await SRSService(self._session).record_and_schedule(
            user_id=user_id,
            card_id=signal.card_id,
            signal=srs_signal,
            now=completed_at,
        )

        await self._session.commit()

        return ReviewResponse(
            event_id=event.id,
            card_id=event.card_id,
            result=event.result.value,
            completed_at=event.completed_at,
        )

    async def topic_progress(
        self,
        user_id: uuid.UUID,
        topic_id: uuid.UUID,
    ) -> TopicProgressResponse:
        total_stmt = (
            select(func.count(Card.id))
            .where(Card.topic_id == topic_id, Card.deleted_at.is_(None))
        )
        total: int = (await self._session.execute(total_stmt)).scalar_one()

        today_start = datetime.now(UTC).replace(hour=0, minute=0, second=0, microsecond=0)

        latest_per_card = (
            select(
                LearningEvent.card_id,
                LearningEvent.result,
                func.max(LearningEvent.completed_at).label("last_at"),
            )
            .join(Card, Card.id == LearningEvent.card_id)
            .where(
                LearningEvent.user_id == user_id,
                Card.topic_id == topic_id,
                LearningEvent.completed_at >= today_start,
            )
            .group_by(LearningEvent.card_id, LearningEvent.result)
            .subquery()
        )

        rows = (await self._session.execute(select(latest_per_card))).all()
        know_count = sum(1 for r in rows if r.result == "know")
        repeat_count = sum(1 for r in rows if r.result == "repeat")

        return TopicProgressResponse(
            topic_id=topic_id,
            total_cards=total,
            reviewed_today=len(rows),
            know_count=know_count,
            repeat_count=repeat_count,
        )

    async def due_queue(
        self,
        user_id: uuid.UUID,
        topic_id: uuid.UUID,
        limit: int = 20,
    ) -> DueQueueResponse:
        """
        Ordered study queue for a topic:
        1. Due cards (retrievability < target, sorted by due_at asc)
        2. New cards not yet seen
        """
        now = datetime.now(UTC)
        srs = SRSService(self._session)

        due_pairs = await srs.due_cards(user_id, topic_id, limit=limit, now=now)
        due_ids = {cid for cid, _ in due_pairs}

        new_limit = max(0, limit - len(due_pairs))
        new_ids = await srs.new_cards_for_topic(user_id, topic_id, limit=new_limit)

        items: list[DueQueueItem] = []

        for card_id, ret in due_pairs:
            items.append(DueQueueItem(card_id=card_id, is_new=False, retrievability=ret))

        for card_id in new_ids:
            if card_id not in due_ids:
                items.append(DueQueueItem(card_id=card_id, is_new=True, retrievability=None))

        return DueQueueResponse(topic_id=topic_id, items=items, generated_at=now)
