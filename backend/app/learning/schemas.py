from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class ReviewSignal(BaseModel):
    card_id: UUID
    card_version_id: UUID
    result: str = Field(pattern="^(repeat|know)$")
    question_ms: int = Field(ge=0, default=0)
    answer_ms: int = Field(ge=0, default=0)
    source_opened: bool = False
    completed_at: datetime | None = None


class ReviewResponse(BaseModel):
    event_id: UUID
    card_id: UUID
    result: str
    completed_at: datetime


class TopicProgressResponse(BaseModel):
    topic_id: UUID
    total_cards: int
    reviewed_today: int
    know_count: int
    repeat_count: int


class DueQueueItem(BaseModel):
    card_id: UUID
    is_new: bool
    retrievability: float | None = None


class DueQueueResponse(BaseModel):
    topic_id: UUID
    items: list[DueQueueItem]
    generated_at: datetime
