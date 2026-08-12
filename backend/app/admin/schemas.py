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
    ends_at: datetime | None = None


class EntitlementRevokeRequest(BaseModel):
    user_id: UUID
    feature_key: str = Field(min_length=1, max_length=64)


class AdminAnalyticsOverview(BaseModel):
    user_count: int
    active_sessions_24h: int
    cards_in_review: int
    sync_events_total: int


class SourceBlockInput(BaseModel):
    block_key: str = Field(min_length=1, max_length=64)
    type: str = Field(pattern="^(heading|paragraph|list|code|quote|table|callout|divider|link)$")
    position: int = Field(ge=0)
    payload: dict = Field(default_factory=dict)


class CreateDocumentRequest(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    blocks: list[SourceBlockInput] = Field(default_factory=list)
    publish: bool = False


class DocumentAdminView(BaseModel):
    id: UUID
    topic_id: UUID
    title: str
    status: str
    version_id: UUID
    version: int


class CardSourceInput(BaseModel):
    document_id: UUID
    source_version_id: UUID
    block_id: UUID | None = None
    position: int = 0


class CreateCardRequest(BaseModel):
    front_text: str = Field(min_length=1, max_length=4000)
    back_text: str = Field(min_length=1, max_length=8000)
    difficulty: float = Field(default=0.5, ge=0, le=1)
    sources: list[CardSourceInput] = Field(default_factory=list)
    publish: bool = True


class CardAdminView(BaseModel):
    id: UUID
    topic_id: UUID
    version_id: UUID
    status: str
    front: dict
    back: dict


class AnalyticsIngestRequest(BaseModel):
    event_name: str = Field(min_length=1, max_length=64)
    device_id: str | None = None
    payload: dict = Field(default_factory=dict)


class AnalyticsIngestResponse(BaseModel):
    id: UUID
    accepted: bool = True
