"""AI interview rubric fields and mistakes deck."""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "007_ai_rubric_mistakes"
down_revision: Union[str, None] = "006_ai_interview_sessions"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("ai_interview_turns", sa.Column("card_id", sa.UUID(), nullable=True))
    op.add_column("ai_interview_turns", sa.Column("rubric_json", sa.JSON(), nullable=False, server_default=sa.text("'{}'::json")))
    op.create_foreign_key(
        "fk_ai_interview_turns_card_id",
        "ai_interview_turns",
        "cards",
        ["card_id"],
        ["id"],
        ondelete="SET NULL",
    )

    op.create_table(
        "ai_mistake_items",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=False),
        sa.Column("session_id", sa.UUID(), nullable=False),
        sa.Column("turn_id", sa.UUID(), nullable=True),
        sa.Column("card_id", sa.UUID(), nullable=True),
        sa.Column("topic_id", sa.UUID(), nullable=False),
        sa.Column("prompt", sa.Text(), nullable=False),
        sa.Column("expected_hint", sa.Text(), nullable=False),
        sa.Column("user_answer", sa.Text(), nullable=True),
        sa.Column("score", sa.Float(), nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["session_id"], ["ai_interview_sessions.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["turn_id"], ["ai_interview_turns.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["card_id"], ["cards.id"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["topic_id"], ["topics.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_ai_mistake_items_user", "ai_mistake_items", ["user_id"])


def downgrade() -> None:
    op.drop_index("ix_ai_mistake_items_user", "ai_mistake_items")
    op.drop_table("ai_mistake_items")
    op.drop_constraint("fk_ai_interview_turns_card_id", "ai_interview_turns", type_="foreignkey")
    op.drop_column("ai_interview_turns", "rubric_json")
    op.drop_column("ai_interview_turns", "card_id")
