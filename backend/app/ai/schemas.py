from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class InterviewStartRequest(BaseModel):
    topic_id: UUID
    question_count: int = Field(default=3, ge=1, le=10)


class InterviewTurnView(BaseModel):
    turn_index: int
    question: str
    user_answer: str | None = None
    score: float | None = None
    feedback: str | None = None


class InterviewSessionResponse(BaseModel):
    session_id: UUID
    topic_id: UUID
    status: str
    current_index: int
    total_questions: int
    score: float
    next_question: str | None = None
    turns: list[InterviewTurnView]
    created_at: datetime


class InterviewAnswerRequest(BaseModel):
    answer: str = Field(min_length=1, max_length=4000)
