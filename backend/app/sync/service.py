from __future__ import annotations

import uuid
from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.errors import AppError
from app.models.sync import SyncEvent
from app.sync.schemas import (
    SyncBatchRequest,
    SyncBatchResponse,
    SyncDiagnosticsResponse,
    SyncEventRequest,
    SyncEventView,
    SyncSrsStateItem,
    SyncStateResponse,
)


class SyncService:
    MAX_RETRIES = 3

    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def ingest_batch(self, *, user_id: UUID, payload: SyncBatchRequest) -> SyncBatchResponse:
        accepted: list[SyncEventView] = []
        failed: list[dict] = []

        for event in payload.events:
            try:
                view = await self._ingest_one(user_id=user_id, device_id=payload.device_id, event=event)
                accepted.append(view)
            except AppError as exc:
                failed.append({"idempotency_key": event.idempotency_key, "code": exc.code, "message": exc.message})
            except Exception as exc:
                failed.append({"idempotency_key": event.idempotency_key, "code": "sync_error", "message": str(exc)})

        await self.session.commit()
        return SyncBatchResponse(accepted=accepted, failed=failed)

    async def _ingest_one(self, *, user_id: UUID, device_id: str, event: SyncEventRequest) -> SyncEventView:
        existing = await self.session.scalar(
            select(SyncEvent).where(
                SyncEvent.user_id == user_id,
                SyncEvent.idempotency_key == event.idempotency_key,
            )
        )
        if existing:
            return SyncEventView(
                id=existing.id,
                event_type=existing.event_type,
                idempotency_key=existing.idempotency_key,
                status=existing.status,
                created_at=existing.created_at,
                duplicate=True,
            )

        status = await self._apply_event(user_id=user_id, event=event)
        row = SyncEvent(
            id=uuid.uuid4(),
            user_id=user_id,
            device_id=device_id,
            event_type=event.event_type,
            idempotency_key=event.idempotency_key,
            payload_json=event.payload,
            status=status,
        )
        self.session.add(row)
        await self.session.flush()
        return SyncEventView(
            id=row.id,
            event_type=row.event_type,
            idempotency_key=row.idempotency_key,
            status=row.status,
            created_at=row.created_at,
        )

    async def _apply_event(self, *, user_id: UUID, event: SyncEventRequest) -> str:
        if event.event_type == "learning.review":
            return await self._apply_review(user_id, event.payload)
        if event.event_type == "content.meta":
            return "accepted"
        raise AppError("unsupported_event", f"Unsupported sync event: {event.event_type}", status_code=422)

    async def _apply_review(self, user_id: UUID, payload: dict) -> str:
        card_id = payload.get("card_id")
        card_version_id = payload.get("card_version_id")
        result = payload.get("result")
        if not card_id or not card_version_id or not result:
            raise AppError(
                "invalid_payload",
                "Review event requires card_id, card_version_id and result",
                status_code=422,
            )

        from app.learning.schemas import ReviewSignal
        from app.learning.service import LearningService

        signal = ReviewSignal(
            card_id=UUID(str(card_id)),
            card_version_id=UUID(str(card_version_id)),
            result=str(result),
            question_ms=int(payload.get("question_ms") or 0),
            answer_ms=int(payload.get("answer_ms") or payload.get("response_ms") or 0),
            source_opened=bool(payload.get("source_opened") or False),
        )
        await LearningService(self.session).record_review(user_id, signal)
        return "applied"

    async def diagnostics(self, *, user_id: UUID) -> SyncDiagnosticsResponse:
        rows = (
            await self.session.scalars(
                select(SyncEvent)
                .where(SyncEvent.user_id == user_id)
                .order_by(SyncEvent.created_at.desc())
                .limit(20)
            )
        ).all()
        pending = sum(1 for row in rows if row.status == "accepted")
        last_at = rows[0].created_at if rows else None
        failures = [
            {"idempotency_key": row.idempotency_key, "event_type": row.event_type, "status": row.status}
            for row in rows
            if row.status == "failed"
        ]
        return SyncDiagnosticsResponse(
            pending_estimate=pending,
            last_event_at=last_at,
            recent_failures=failures,
        )

    async def state(self, *, user_id: UUID, since: str | None = None) -> SyncStateResponse:
        from app.auth.service import AuthService
        from app.core.config import get_settings
        from app.gamification.service import GamificationService
        from app.models.content import Course, PublishStatus
        from app.models.srs import CardMemoryState
        from sqlalchemy import func

        stmt = select(CardMemoryState).where(CardMemoryState.user_id == user_id)
        if since:
            try:
                since_dt = datetime.fromisoformat(since.replace("Z", "+00:00"))
                stmt = stmt.where(CardMemoryState.updated_at > since_dt)
            except ValueError:
                pass
        rows = (await self.session.scalars(stmt.order_by(CardMemoryState.updated_at))).all()
        cursor = rows[-1].updated_at.isoformat() if rows else (since or datetime.now(UTC).isoformat())

        gamification = await GamificationService(self.session).overview(user_id)
        content_revision = (
            await self.session.scalar(
                select(func.max(Course.content_revision)).where(Course.status == PublishStatus.PUBLISHED)
            )
            or 1
        )
        entitlements = await AuthService(self.session, get_settings()).get_entitlements(user_id)
        etag = ",".join(sorted(item.key for item in entitlements.features))

        return SyncStateResponse(
            cursor=cursor,
            srs_states=[
                SyncSrsStateItem(
                    card_id=row.card_id,
                    stability=row.stability,
                    difficulty=row.difficulty,
                    interval_h=row.interval_h,
                    reps=row.reps,
                    lapses=row.lapses,
                    due_at=row.due_at,
                    algorithm_version=row.algorithm_version,
                    updated_at=row.updated_at,
                )
                for row in rows
            ],
            streak_days=gamification.streak_days,
            daily_goal_reviews=gamification.daily_goal_reviews,
            daily_progress_reviews=gamification.daily_progress_reviews,
            content_revision=int(content_revision),
            entitlements_etag=etag,
        )
