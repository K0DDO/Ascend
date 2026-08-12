"""Curriculum schema: courses, topics, sources, cards."""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "003_content_curriculum"
down_revision: Union[str, None] = "002_auth_entitlements"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "courses",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("slug", sa.String(length=64), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column(
            "status",
            sa.Enum("draft", "published", name="publish_status", native_enum=False),
            nullable=False,
            server_default="draft",
        ),
        sa.Column("content_revision", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("access_feature_key", sa.String(length=64), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["access_feature_key"], ["features.key"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("slug"),
    )

    op.create_table(
        "course_sections",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("course_id", sa.UUID(), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("position", sa.Integer(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["course_id"], ["courses.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("course_id", "position", name="uq_course_sections_course_position"),
    )
    op.create_index("ix_course_sections_course_id", "course_sections", ["course_id"])

    op.create_table(
        "topics",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("section_id", sa.UUID(), nullable=False),
        sa.Column("slug", sa.String(length=64), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("position", sa.Integer(), nullable=False),
        sa.Column("estimated_minutes", sa.Integer(), nullable=False, server_default="15"),
        sa.Column(
            "status",
            sa.Enum("draft", "published", name="topic_publish_status", native_enum=False),
            nullable=False,
            server_default="draft",
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["section_id"], ["course_sections.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("section_id", "slug", name="uq_topics_section_slug"),
    )
    op.create_index("ix_topics_section_id", "topics", ["section_id"])

    op.create_table(
        "topic_dependencies",
        sa.Column("topic_id", sa.UUID(), nullable=False),
        sa.Column("prerequisite_topic_id", sa.UUID(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["prerequisite_topic_id"], ["topics.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["topic_id"], ["topics.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("topic_id", "prerequisite_topic_id"),
        sa.UniqueConstraint("topic_id", "prerequisite_topic_id", name="uq_topic_dependencies_pair"),
    )

    op.create_table(
        "source_documents",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("topic_id", sa.UUID(), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column(
            "status",
            sa.Enum("draft", "published", name="source_publish_status", native_enum=False),
            nullable=False,
            server_default="draft",
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["topic_id"], ["topics.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_source_documents_topic_id", "source_documents", ["topic_id"])

    op.create_table(
        "source_versions",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("document_id", sa.UUID(), nullable=False),
        sa.Column("version", sa.Integer(), nullable=False),
        sa.Column("checksum", sa.String(length=64), nullable=False),
        sa.Column("published_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["document_id"], ["source_documents.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("document_id", "version", name="uq_source_versions_doc_version"),
    )
    op.create_index("ix_source_versions_document_id", "source_versions", ["document_id"])

    op.create_table(
        "source_blocks",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("source_version_id", sa.UUID(), nullable=False),
        sa.Column("block_key", sa.String(length=64), nullable=False),
        sa.Column(
            "type",
            sa.Enum(
                "heading",
                "paragraph",
                "list",
                "code",
                "quote",
                "table",
                "callout",
                "divider",
                "link",
                name="source_block_type",
                native_enum=False,
            ),
            nullable=False,
        ),
        sa.Column("position", sa.Integer(), nullable=False),
        sa.Column("payload", sa.JSON(), nullable=False, server_default=sa.text("'{}'")),
        sa.ForeignKeyConstraint(["source_version_id"], ["source_versions.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("source_version_id", "block_key", name="uq_source_blocks_version_key"),
    )
    op.create_index("ix_source_blocks_source_version_id", "source_blocks", ["source_version_id"])

    op.create_table(
        "cards",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("topic_id", sa.UUID(), nullable=False),
        sa.Column(
            "status",
            sa.Enum(
                "draft",
                "review_required",
                "published",
                "archived",
                name="card_status",
                native_enum=False,
            ),
            nullable=False,
            server_default="draft",
        ),
        sa.Column("difficulty", sa.Numeric(precision=4, scale=3), nullable=False, server_default="0.500"),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["topic_id"], ["topics.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_cards_topic_id", "cards", ["topic_id"])

    op.create_table(
        "card_versions",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("card_id", sa.UUID(), nullable=False),
        sa.Column("version", sa.Integer(), nullable=False),
        sa.Column("front", sa.JSON(), nullable=False),
        sa.Column("back", sa.JSON(), nullable=False),
        sa.Column("metadata", sa.JSON(), nullable=False, server_default=sa.text("'{}'")),
        sa.Column("published_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["card_id"], ["cards.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("card_id", "version", name="uq_card_versions_card_version"),
    )
    op.create_index("ix_card_versions_card_id", "card_versions", ["card_id"])


def downgrade() -> None:
    op.drop_index("ix_card_versions_card_id", table_name="card_versions")
    op.drop_table("card_versions")
    op.drop_index("ix_cards_topic_id", table_name="cards")
    op.drop_table("cards")
    op.drop_index("ix_source_blocks_source_version_id", table_name="source_blocks")
    op.drop_table("source_blocks")
    op.drop_index("ix_source_versions_document_id", table_name="source_versions")
    op.drop_table("source_versions")
    op.drop_index("ix_source_documents_topic_id", table_name="source_documents")
    op.drop_table("source_documents")
    op.drop_table("topic_dependencies")
    op.drop_index("ix_topics_section_id", table_name="topics")
    op.drop_table("topics")
    op.drop_index("ix_course_sections_course_id", table_name="course_sections")
    op.drop_table("course_sections")
    op.drop_table("courses")
