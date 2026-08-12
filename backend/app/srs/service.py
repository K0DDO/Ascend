"""SRS service: persists CardMemoryState, integrates with ascend_srs_v1."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.content import Card
from app.models.srs import CardMemoryState
from app.srs.algorithm import (
    ALGORITHM_VERSION,
    ReviewSignalInput,
    SRSState,
    apply,
    initial_state,
    retrievability,
)


class SRSService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    # ── Public ────────────────────────────────────────────────────────────────

    async def record_and_schedule(
        self,
        user_id: uuid.UUID,
        card_id: uuid.UUID,
        signal: ReviewSignalInput,
        now: datetime | None = None,
    ) -> CardMemoryState:
        now = now or datetime.now(UTC)
        row = await self._get_or_create(user_id, card_id, signal.card_difficulty, now)
        state = _row_to_state(row)
        new_state = apply(state, signal, now)
        _update_row(row, new_state)
        await self._session.flush()
        return row

    async def due_cards(
        self,
        user_id: uuid.UUID,
        topic_id: uuid.UUID,
        limit: int = 20,
        now: datetime | None = None,
    ) -> list[tuple[uuid.UUID, float]]:
        """Return (card_id, retrievability) for cards due in this topic, ordered by priority."""
        now = now or datetime.now(UTC)

        stmt = (
            select(CardMemoryState, Card)
            .join(Card, Card.id == CardMemoryState.card_id)
            .where(
                CardMemoryState.user_id == user_id,
                Card.topic_id == topic_id,
                CardMemoryState.due_at <= now,
                Card.deleted_at.is_(None),
            )
            .order_by(CardMemoryState.due_at)
            .limit(limit)
        )
        rows = (await self._session.execute(stmt)).all()
        return [
            (row.CardMemoryState.card_id, retrievability(_row_to_state(row.CardMemoryState), now))
            for row in rows
        ]

    async def new_cards_for_topic(
        self,
        user_id: uuid.UUID,
        topic_id: uuid.UUID,
        limit: int = 10,
    ) -> list[uuid.UUID]:
        """Cards in this topic that have never been reviewed by this user."""
        reviewed_stmt = select(CardMemoryState.card_id).where(CardMemoryState.user_id == user_id)
        stmt = (
            select(Card.id)
            .where(
                Card.topic_id == topic_id,
                Card.deleted_at.is_(None),
                Card.id.not_in(reviewed_stmt),
            )
            .limit(limit)
        )
        return list((await self._session.execute(stmt)).scalars())

    async def bulk_states(
        self,
        user_id: uuid.UUID,
        card_ids: list[uuid.UUID],
    ) -> dict[uuid.UUID, CardMemoryState]:
        if not card_ids:
            return {}
        stmt = select(CardMemoryState).where(
            CardMemoryState.user_id == user_id,
            CardMemoryState.card_id.in_(card_ids),
        )
        rows = (await self._session.execute(stmt)).scalars().all()
        return {row.card_id: row for row in rows}

    # ── Internal ──────────────────────────────────────────────────────────────

    async def _get_or_create(
        self,
        user_id: uuid.UUID,
        card_id: uuid.UUID,
        card_difficulty: float,
        now: datetime,
    ) -> CardMemoryState:
        stmt = select(CardMemoryState).where(
            CardMemoryState.user_id == user_id,
            CardMemoryState.card_id == card_id,
        )
        row = (await self._session.execute(stmt)).scalar_one_or_none()
        if row is None:
            state = initial_state(card_difficulty, now)
            row = CardMemoryState(
                id=uuid.uuid4(),
                user_id=user_id,
                card_id=card_id,
                **_state_to_dict(state),
            )
            self._session.add(row)
            await self._session.flush()
        return row


# ── Helpers ───────────────────────────────────────────────────────────────────

def _row_to_state(row: CardMemoryState) -> SRSState:
    from app.srs.algorithm import SRSState  # local import avoids circular
    return SRSState(
        stability=row.stability,
        difficulty=row.difficulty,
        interval_h=row.interval_h,
        reps=row.reps,
        lapses=row.lapses,
        due_at=row.due_at,
        last_reviewed_at=row.last_reviewed_at,
        algorithm_version=row.algorithm_version,
    )


def _update_row(row: CardMemoryState, state: SRSState) -> None:
    row.stability = state.stability
    row.difficulty = state.difficulty
    row.interval_h = state.interval_h
    row.reps = state.reps
    row.lapses = state.lapses
    row.due_at = state.due_at
    row.last_reviewed_at = state.last_reviewed_at
    row.algorithm_version = state.algorithm_version


def _state_to_dict(state: SRSState) -> dict:
    return {
        "stability": state.stability,
        "difficulty": state.difficulty,
        "interval_h": state.interval_h,
        "reps": state.reps,
        "lapses": state.lapses,
        "due_at": state.due_at,
        "last_reviewed_at": state.last_reviewed_at,
        "algorithm_version": state.algorithm_version,
    }
