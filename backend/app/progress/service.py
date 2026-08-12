from __future__ import annotations

import uuid
from collections import defaultdict
from datetime import UTC, date, datetime, timedelta

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.content import Card, Topic
from app.models.learning import LearningEvent
from app.models.srs import CardMemoryState
from app.progress.schemas import ActivityDay, ProgressOverviewResponse, WeakAreaItem


class ProgressService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def overview(self, user_id: uuid.UUID) -> ProgressOverviewResponse:
        total_reviews = await self._total_reviews(user_id)
        know_rate = await self._know_rate(user_id)
        readiness = await self._readiness(user_id, know_rate)
        weak_areas = await self._weak_areas(user_id)
        activity = await self._activity(user_id)
        return ProgressOverviewResponse(
            total_reviews=total_reviews,
            know_rate=know_rate,
            readiness=readiness,
            weak_areas=weak_areas,
            activity=activity,
        )

    async def _total_reviews(self, user_id: uuid.UUID) -> int:
        stmt = select(func.count(LearningEvent.id)).where(LearningEvent.user_id == user_id)
        return (await self._session.execute(stmt)).scalar_one()

    async def _know_rate(self, user_id: uuid.UUID) -> float:
        result_stmt = (
            select(LearningEvent.result, func.count(LearningEvent.id))
            .where(LearningEvent.user_id == user_id)
            .group_by(LearningEvent.result)
        )
        rows = (await self._session.execute(result_stmt)).all()
        total = sum(count for _, count in rows)
        if total == 0:
            return 0.0
        know = sum(count for result, count in rows if result.value == "know")
        return max(0.0, min(1.0, know / total))

    async def _readiness(self, user_id: uuid.UUID, know_rate: float) -> float:
        now = datetime.now(UTC)
        due_stmt = select(func.count(CardMemoryState.id)).where(
            CardMemoryState.user_id == user_id,
            CardMemoryState.due_at <= now,
        )
        due = (await self._session.execute(due_stmt)).scalar_one()
        total_stmt = select(func.count(CardMemoryState.id)).where(CardMemoryState.user_id == user_id)
        total = (await self._session.execute(total_stmt)).scalar_one()
        due_factor = 1.0 if total == 0 else max(0.0, 1.0 - (due / total))
        # 70% recall quality + 30% due-load cleanliness
        return max(0.0, min(1.0, know_rate * 0.7 + due_factor * 0.3))

    async def _weak_areas(self, user_id: uuid.UUID) -> list[WeakAreaItem]:
        stmt = (
            select(
                Topic.id,
                Topic.title,
                LearningEvent.result,
                func.count(LearningEvent.id),
            )
            .join(Card, Card.topic_id == Topic.id)
            .join(LearningEvent, LearningEvent.card_id == Card.id)
            .where(LearningEvent.user_id == user_id)
            .group_by(Topic.id, Topic.title, LearningEvent.result)
        )
        rows = (await self._session.execute(stmt)).all()
        if not rows:
            return []

        bucket: dict[tuple[str, str], dict[str, int]] = defaultdict(lambda: {"know": 0, "total": 0})
        for topic_id, title, result, count in rows:
            key = (str(topic_id), title)
            bucket[key]["total"] += count
            if result.value == "know":
                bucket[key]["know"] += count

        ranked = []
        for (topic_id, title), item in bucket.items():
            mastery = item["know"] / item["total"] if item["total"] else 0.0
            ranked.append(WeakAreaItem(topic_id=topic_id, topic_title=title, mastery=mastery))
        ranked.sort(key=lambda x: x.mastery)
        return ranked[:3]

    async def _activity(self, user_id: uuid.UUID) -> list[ActivityDay]:
        today = datetime.now(UTC).date()
        start = today - timedelta(days=13)
        start_dt = datetime.combine(start, datetime.min.time(), tzinfo=UTC)
        stmt = (
            select(func.date(LearningEvent.completed_at), func.count(LearningEvent.id))
            .where(LearningEvent.user_id == user_id, LearningEvent.completed_at >= start_dt)
            .group_by(func.date(LearningEvent.completed_at))
        )
        rows = (await self._session.execute(stmt)).all()
        values: dict[date, int] = {day: count for day, count in rows}
        return [ActivityDay(day=day, reviews=values.get(day, 0)) for day in (start + timedelta(days=i) for i in range(14))]
