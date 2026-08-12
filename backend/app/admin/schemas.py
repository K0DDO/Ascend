from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class CardModerationView(BaseModel):
    id: UUID
    topic_id: UUID
    status: str
    front_preview: str


class CardStatusUpdateRequest(BaseModel):
    status: str = Field(pattern="^(draft|review_required|published|archived)$")


class EntitlementGrantRequest(BaseModel):
    user_id: UUID
    feature_key: str = Field(min_length=1, max_length=64)
    source: str = "admin"
    constraints: dict = Field(default_factory=dict)
    ends_at: datetime | None = None


class EntitlementGrantView(BaseModel):
    id: UUID
    user_id: UUID
    feature_key: str
    source: str
    starts_at: datetime


class AdminAnalyticsOverview(BaseModel):
    user_count: int
    active_sessions_24h: int
    cards_in_review: int
    sync_events_total: int
