from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class SyncEventRequest(BaseModel):
    device_id: str = Field(min_length=1, max_length=128)
    event_type: str = Field(min_length=1, max_length=64)
    idempotency_key: str = Field(min_length=1, max_length=128)
    payload: dict = Field(default_factory=dict)


class SyncEventView(BaseModel):
    id: UUID
    event_type: str
    idempotency_key: str
    status: str
    created_at: datetime
    duplicate: bool = False


class SyncBatchRequest(BaseModel):
    device_id: str = Field(min_length=1, max_length=128)
    events: list[SyncEventRequest] = Field(min_length=1, max_length=50)


class SyncBatchResponse(BaseModel):
    accepted: list[SyncEventView]
    failed: list[dict] = Field(default_factory=list)


class SyncDiagnosticsResponse(BaseModel):
    pending_estimate: int
    last_event_at: datetime | None
    recent_failures: list[dict] = Field(default_factory=list)


class SyncSrsStateItem(BaseModel):
    card_id: UUID
    stability: float
    difficulty: float
    interval_h: float
    reps: int
    lapses: int
    due_at: datetime
    algorithm_version: str
    updated_at: datetime


class SyncStateResponse(BaseModel):
    cursor: str
    srs_states: list[SyncSrsStateItem]
    streak_days: int
    daily_goal_reviews: int
    daily_progress_reviews: int
    content_revision: int
    entitlements_etag: str
