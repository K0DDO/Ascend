"""AI interview sessions and turns."""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "006_ai_interview_sessions"
down_revision: Union[str, None] = "005_card_memory_states"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "ai_interview_sessions",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=False),
        sa.Column("topic_id", sa.UUID(), nullable=False),
        sa.Column(
            "status",
            sa.Enum("in_progress", "completed", name="ai_interview_status", native_enum=False),
            nullable=False,
            server_default="in_progress",
        ),
        sa.Column("current_index", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("score", sa.Float(), nullable=False, server_default="0"),
        sa.Column("rubric_json", sa.JSON(), nullable=False, server_default=sa.text("'{}'::json")),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["topic_id"], ["topics.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_ai_interview_sessions_user", "ai_interview_sessions", ["user_id"])
    op.create_index("ix_ai_interview_sessions_topic", "ai_interview_sessions", ["topic_id"])

    op.create_table(
        "ai_interview_turns",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("session_id", sa.UUID(), nullable=False),
        sa.Column("turn_index", sa.Integer(), nullable=False),
        sa.Column("question", sa.Text(), nullable=False),
        sa.Column("reference_answer", sa.Text(), nullable=False),
        sa.Column("user_answer", sa.Text(), nullable=True),
        sa.Column("score", sa.Float(), nullable=True),
        sa.Column("feedback", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["session_id"], ["ai_interview_sessions.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_ai_interview_turns_session", "ai_interview_turns", ["session_id"])


def downgrade() -> None:
    op.drop_index("ix_ai_interview_turns_session", "ai_interview_turns")
    op.drop_table("ai_interview_turns")
    op.drop_index("ix_ai_interview_sessions_topic", "ai_interview_sessions")
    op.drop_index("ix_ai_interview_sessions_user", "ai_interview_sessions")
    op.drop_table("ai_interview_sessions")
