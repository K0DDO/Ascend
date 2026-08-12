from datetime import UTC, datetime
from uuid import UUID

from pydantic import BaseModel, Field


class CourseSummary(BaseModel):
    id: UUID
    slug: str
    title: str
    description: str | None
    content_revision: int
    locked: bool
    access_feature_key: str | None = None
    topic_count: int = 0


class CourseListResponse(BaseModel):
    courses: list[CourseSummary]


class TopicSummary(BaseModel):
    id: UUID
    slug: str
    title: str
    description: str | None
    position: int
    estimated_minutes: int
    locked: bool
    prerequisite_ids: list[UUID] = Field(default_factory=list)


class CourseSectionResponse(BaseModel):
    id: UUID
    title: str
    position: int
    topics: list[TopicSummary]


class CourseDetailResponse(BaseModel):
    id: UUID
    slug: str
    title: str
    description: str | None
    content_revision: int
    locked: bool
    access_feature_key: str | None = None
    sections: list[CourseSectionResponse] = Field(default_factory=list)


class TopicDetailResponse(BaseModel):
    id: UUID
    slug: str
    title: str
    description: str | None
    estimated_minutes: int
    course_id: UUID
    course_slug: str
    locked: bool
    prerequisite_ids: list[UUID] = Field(default_factory=list)
    card_count: int = 0


class CardSourceRef(BaseModel):
    document_id: UUID
    source_version_id: UUID
    block_id: UUID | None = None
    document_title: str | None = None


class CardPreview(BaseModel):
    id: UUID
    version_id: UUID
    front: dict
    back: dict
    difficulty: float
    sources: list[CardSourceRef] = Field(default_factory=list)


class TopicCardsResponse(BaseModel):
    topic_id: UUID
    cards: list[CardPreview]
    locked: bool = False
    lock_reason: str | None = None


class SourceBlockResponse(BaseModel):
    id: UUID
    block_key: str
    type: str
    position: int
    payload: dict


class SourceDocumentResponse(BaseModel):
    id: UUID
    title: str
    topic_id: UUID
    version_id: UUID
    version: int
    blocks: list[SourceBlockResponse]


class TopicDocumentsResponse(BaseModel):
    topic_id: UUID
    documents: list[SourceDocumentResponse]


class ContentManifestCourse(BaseModel):
    id: UUID
    slug: str
    content_revision: int
    hash: str
    locked: bool


class ContentManifestResponse(BaseModel):
    content_revision: int
    courses: list[ContentManifestCourse]


class ContentPackageSummary(BaseModel):
    id: str
    course_id: UUID
    revision: int
    size_bytes: int
    checksum: str


class ContentPackagesResponse(BaseModel):
    packages: list[ContentPackageSummary]
