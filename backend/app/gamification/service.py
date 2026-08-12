from __future__ import annotations

import uuid
from datetime import UTC, date, datetime, timedelta

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.gamification.schemas import AchievementItem, GamificationOverviewResponse
from app.models.learning import LearningEvent

XP_KNOW = 8
XP_REPEAT = 3
DAILY_GOAL_REVIEWS = 24


class GamificationService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def overview(self, user_id: uuid.UUID) -> GamificationOverviewResponse:
        by_day = await self._reviews_by_day(user_id)
        today = datetime.now(UTC).date()
        daily_progress = by_day.get(today, 0)
        streak = _streak_days(by_day, today)
        xp_total, xp_today = await self._xp(user_id, today)

        achievements = _build_achievements(
            streak_days=streak,
            xp_total=xp_total,
            daily_goal=DAILY_GOAL_REVIEWS,
            daily_progress=daily_progress,
        )
        return GamificationOverviewResponse(
            streak_days=streak,
            xp_total=xp_total,
            xp_today=xp_today,
            daily_goal_reviews=DAILY_GOAL_REVIEWS,
            daily_progress_reviews=daily_progress,
            achievements=achievements,
        )

    async def _reviews_by_day(self, user_id: uuid.UUID) -> dict[date, int]:
        since = datetime.now(UTC) - timedelta(days=60)
        stmt = (
            select(func.date(LearningEvent.completed_at), func.count(LearningEvent.id))
            .where(LearningEvent.user_id == user_id, LearningEvent.completed_at >= since)
            .group_by(func.date(LearningEvent.completed_at))
        )
        rows = (await self._session.execute(stmt)).all()
        return {d: count for d, count in rows}

    async def _xp(self, user_id: uuid.UUID, today: date) -> tuple[int, int]:
        stmt = select(LearningEvent.result, LearningEvent.completed_at).where(LearningEvent.user_id == user_id)
        rows = (await self._session.execute(stmt)).all()
        total = 0
        today_xp = 0
        for result, completed_at in rows:
            gain = XP_KNOW if result.value == "know" else XP_REPEAT
            total += gain
            if completed_at.date() == today:
                today_xp += gain
        return total, today_xp


def _streak_days(by_day: dict[date, int], today: date) -> int:
    streak = 0
    day = today
    while by_day.get(day, 0) > 0:
        streak += 1
        day -= timedelta(days=1)
    return streak


def _build_achievements(
    *,
    streak_days: int,
    xp_total: int,
    daily_goal: int,
    daily_progress: int,
) -> list[AchievementItem]:
    return [
        AchievementItem(
            key="first_session",
            title="First Session",
            unlocked=xp_total > 0,
            progress=1.0 if xp_total > 0 else 0.0,
        ),
        AchievementItem(
            key="streak_7",
            title="7-Day Streak",
            unlocked=streak_days >= 7,
            progress=min(1.0, streak_days / 7),
        ),
        AchievementItem(
            key="xp_1000",
            title="1000 XP",
            unlocked=xp_total >= 1000,
            progress=min(1.0, xp_total / 1000),
        ),
        AchievementItem(
            key="daily_goal",
            title="Daily Goal",
            unlocked=daily_progress >= daily_goal,
            progress=min(1.0, daily_progress / daily_goal if daily_goal > 0 else 0.0),
        ),
    ]
