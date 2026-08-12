import enum
import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import JSON, DateTime, Enum, ForeignKey, Integer, Numeric, String, Text, UniqueConstraint, Uuid, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.user import TimestampMixin, _enum_values


class PublishStatus(str, enum.Enum):
    DRAFT = "draft"
    PUBLISHED = "published"


class CardStatus(str, enum.Enum):
    DRAFT = "draft"
    REVIEW_REQUIRED = "review_required"
    PUBLISHED = "published"
    ARCHIVED = "archived"


class SourceBlockType(str, enum.Enum):
    HEADING = "heading"
    PARAGRAPH = "paragraph"
    LIST = "list"
    CODE = "code"
    QUOTE = "quote"
    TABLE = "table"
    CALLOUT = "callout"
    DIVIDER = "divider"
    LINK = "link"


class Course(Base, TimestampMixin):
    __tablename__ = "courses"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    slug: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[PublishStatus] = mapped_column(
        Enum(PublishStatus, name="publish_status", native_enum=False, values_callable=_enum_values),
        nullable=False,
        default=PublishStatus.DRAFT,
    )
    content_revision: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    access_feature_key: Mapped[str | None] = mapped_column(
        String(64),
        ForeignKey("features.key", ondelete="SET NULL"),
        nullable=True,
    )

    sections: Mapped[list["CourseSection"]] = relationship(
        back_populates="course",
        order_by="CourseSection.position",
    )


class CourseSection(Base, TimestampMixin):
    __tablename__ = "course_sections"
    __table_args__ = (UniqueConstraint("course_id", "position", name="uq_course_sections_course_position"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    course_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("courses.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    position: Mapped[int] = mapped_column(Integer, nullable=False)

    course: Mapped[Course] = relationship(back_populates="sections")
    topics: Mapped[list["Topic"]] = relationship(
        back_populates="section",
        order_by="Topic.position",
    )


class Topic(Base, TimestampMixin):
    __tablename__ = "topics"
    __table_args__ = (UniqueConstraint("section_id", "slug", name="uq_topics_section_slug"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    section_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("course_sections.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    slug: Mapped[str] = mapped_column(String(64), nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    position: Mapped[int] = mapped_column(Integer, nullable=False)
    estimated_minutes: Mapped[int] = mapped_column(Integer, nullable=False, default=15)
    status: Mapped[PublishStatus] = mapped_column(
        Enum(PublishStatus, name="topic_publish_status", native_enum=False, values_callable=_enum_values),
        nullable=False,
        default=PublishStatus.DRAFT,
    )

    section: Mapped[CourseSection] = relationship(back_populates="topics")
    prerequisites: Mapped[list["TopicDependency"]] = relationship(
        foreign_keys="TopicDependency.topic_id",
        back_populates="topic",
    )
    cards: Mapped[list["Card"]] = relationship(back_populates="topic")
    source_documents: Mapped[list["SourceDocument"]] = relationship(back_populates="topic")


class TopicDependency(Base):
    __tablename__ = "topic_dependencies"
    __table_args__ = (
        UniqueConstraint("topic_id", "prerequisite_topic_id", name="uq_topic_dependencies_pair"),
    )

    topic_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("topics.id", ondelete="CASCADE"),
        primary_key=True,
    )
    prerequisite_topic_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("topics.id", ondelete="CASCADE"),
        primary_key=True,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    topic: Mapped[Topic] = relationship(
        foreign_keys=[topic_id],
        back_populates="prerequisites",
    )


class SourceDocument(Base, TimestampMixin):
    __tablename__ = "source_documents"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    topic_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("topics.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    status: Mapped[PublishStatus] = mapped_column(
        Enum(PublishStatus, name="source_publish_status", native_enum=False, values_callable=_enum_values),
        nullable=False,
        default=PublishStatus.DRAFT,
    )

    topic: Mapped[Topic] = relationship(back_populates="source_documents")
    versions: Mapped[list["SourceVersion"]] = relationship(
        back_populates="document",
        order_by="SourceVersion.version",
    )


class SourceVersion(Base):
    __tablename__ = "source_versions"
    __table_args__ = (UniqueConstraint("document_id", "version", name="uq_source_versions_doc_version"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    document_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("source_documents.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    version: Mapped[int] = mapped_column(Integer, nullable=False)
    checksum: Mapped[str] = mapped_column(String(64), nullable=False)
    published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    document: Mapped[SourceDocument] = relationship(back_populates="versions")
    blocks: Mapped[list["SourceBlock"]] = relationship(
        back_populates="source_version",
        order_by="SourceBlock.position",
    )


class SourceBlock(Base):
    __tablename__ = "source_blocks"
    __table_args__ = (
        UniqueConstraint("source_version_id", "block_key", name="uq_source_blocks_version_key"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    source_version_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("source_versions.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    block_key: Mapped[str] = mapped_column(String(64), nullable=False)
    type: Mapped[SourceBlockType] = mapped_column(
        Enum(SourceBlockType, name="source_block_type", native_enum=False, values_callable=_enum_values),
        nullable=False,
    )
    position: Mapped[int] = mapped_column(Integer, nullable=False)
    payload: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)

    source_version: Mapped[SourceVersion] = relationship(back_populates="blocks")


class Card(Base, TimestampMixin):
    __tablename__ = "cards"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    topic_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("topics.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    status: Mapped[CardStatus] = mapped_column(
        Enum(CardStatus, name="card_status", native_enum=False, values_callable=_enum_values),
        nullable=False,
        default=CardStatus.DRAFT,
    )
    difficulty: Mapped[Decimal] = mapped_column(Numeric(4, 3), nullable=False, default=Decimal("0.500"))
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    topic: Mapped[Topic] = relationship(back_populates="cards")
    versions: Mapped[list["CardVersion"]] = relationship(
        back_populates="card",
        order_by="CardVersion.version",
    )


class CardVersion(Base):
    __tablename__ = "card_versions"
    __table_args__ = (UniqueConstraint("card_id", "version", name="uq_card_versions_card_version"),)

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    card_id: Mapped[uuid.UUID] = mapped_column(
        Uuid,
        ForeignKey("cards.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    version: Mapped[int] = mapped_column(Integer, nullable=False)
    front: Mapped[dict] = mapped_column(JSON, nullable=False)
    back: Mapped[dict] = mapped_column(JSON, nullable=False)
    metadata_: Mapped[dict] = mapped_column("metadata", JSON, nullable=False, default=dict)
    published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    card: Mapped[Card] = relationship(back_populates="versions")
    sources: Mapped[list["CardSourceReference"]] = relationship(
        back_populates="card_version",
        order_by="CardSourceReference.position",
    )


class CardSourceReference(Base):
    __tablename__ = "card_source_references"
    __table_args__ = (
        UniqueConstraint("card_version_id", "block_id", name="uq_card_source_ref_version_block"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    card_version_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("card_versions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    document_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("source_documents.id", ondelete="CASCADE"), nullable=False
    )
    source_version_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("source_versions.id", ondelete="CASCADE"), nullable=False
    )
    block_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("source_blocks.id", ondelete="SET NULL"), nullable=True
    )
    range: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    position: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    card_version: Mapped[CardVersion] = relationship(back_populates="sources")


class AnalyticsEvent(Base):
    __tablename__ = "analytics_events"

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    device_id: Mapped[str | None] = mapped_column(String(128), nullable=True)
    event_name: Mapped[str] = mapped_column(String(64), nullable=False, index=True)
    payload_json: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
