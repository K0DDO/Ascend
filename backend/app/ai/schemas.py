from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class RubricScores(BaseModel):
    clarity: float = Field(ge=0, le=1)
    correctness: float = Field(ge=0, le=1)
    completeness: float = Field(ge=0, le=1)
    terminology: float = Field(ge=0, le=1)


class InterviewStartRequest(BaseModel):
    topic_id: UUID
    question_count: int = Field(default=3, ge=1, le=10)


class InterviewTurnView(BaseModel):
    turn_index: int
    question: str
    user_answer: str | None = None
    score: float | None = None
    feedback: str | None = None
    rubric: RubricScores | None = None
    card_id: UUID | None = None


class InterviewSummary(BaseModel):
    average_score: float
    confidence_band: str
    strong_dimensions: list[str] = Field(default_factory=list)
    weak_dimensions: list[str] = Field(default_factory=list)
    mistake_count: int = 0


class InterviewSessionResponse(BaseModel):
    session_id: UUID
    topic_id: UUID
    status: str
    current_index: int
    total_questions: int
    score: float
    next_question: str | None = None
    turns: list[InterviewTurnView]
    summary: InterviewSummary | None = None
    created_at: datetime


class InterviewAnswerRequest(BaseModel):
    answer: str = Field(min_length=1, max_length=4000)


class MistakeItemView(BaseModel):
    id: UUID
    session_id: UUID
    turn_id: UUID | None = None
    card_id: UUID | None = None
    topic_id: UUID
    prompt: str
    expected_hint: str
    user_answer: str | None = None
    score: float
    created_at: datetime


class MistakeListResponse(BaseModel):
    items: list[MistakeItemView]
