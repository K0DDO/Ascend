from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class MentorLinkRequest(BaseModel):
    student_user_id: UUID


class MentorLinkView(BaseModel):
    id: UUID
    mentor_user_id: UUID
    student_user_id: UUID
    status: str
    created_at: datetime


class MentorStudentView(BaseModel):
    user_id: UUID
    display_name: str
    link_id: UUID


class MentorProgressSnapshot(BaseModel):
    student_user_id: UUID
    total_reviews: int
    know_rate: float
    readiness: float


class AssignmentCreateRequest(BaseModel):
    student_user_id: UUID
    title: str = Field(min_length=1, max_length=255)
    note: str | None = None
    topic_id: UUID | None = None
    due_at: datetime | None = None


class AssignmentView(BaseModel):
    id: UUID
    mentor_user_id: UUID
    student_user_id: UUID
    topic_id: UUID | None
    title: str
    note: str | None
    due_at: datetime | None
    status: str
    created_at: datetime


class AssignmentCommentRequest(BaseModel):
    note: str = Field(min_length=1, max_length=2000)
