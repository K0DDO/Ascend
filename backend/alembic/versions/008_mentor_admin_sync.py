"""Mentor links, assignments, sync events."""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "008_mentor_admin_sync"
down_revision: Union[str, None] = "007_ai_rubric_mistakes"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "mentor_links",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("mentor_user_id", sa.UUID(), nullable=False),
        sa.Column("student_user_id", sa.UUID(), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False, server_default="active"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["mentor_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["student_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("mentor_user_id", "student_user_id", name="uq_mentor_links_pair"),
    )

    op.create_table(
        "mentor_assignments",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("mentor_user_id", sa.UUID(), nullable=False),
        sa.Column("student_user_id", sa.UUID(), nullable=False),
        sa.Column("topic_id", sa.UUID(), nullable=True),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("note", sa.Text(), nullable=True),
        sa.Column("due_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("status", sa.String(length=32), nullable=False, server_default="open"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["mentor_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["student_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["topic_id"], ["topics.id"], ondelete="SET NULL"),
    )

    op.create_table(
        "sync_events",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=False),
        sa.Column("device_id", sa.String(length=128), nullable=False),
        sa.Column("event_type", sa.String(length=64), nullable=False),
        sa.Column("idempotency_key", sa.String(length=128), nullable=False),
        sa.Column("payload_json", sa.JSON(), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False, server_default="accepted"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("user_id", "idempotency_key", name="uq_sync_events_user_idempotency"),
    )
    op.create_index("ix_sync_events_user", "sync_events", ["user_id"])


def downgrade() -> None:
    op.drop_index("ix_sync_events_user", "sync_events")
    op.drop_table("sync_events")
    op.drop_table("mentor_assignments")
    op.drop_table("mentor_links")
