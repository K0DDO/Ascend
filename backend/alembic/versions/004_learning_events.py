"""Learning events: card review history."""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "004_learning_events"
down_revision: Union[str, None] = "003_content_curriculum"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "learning_events",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=False),
        sa.Column("card_id", sa.UUID(), nullable=False),
        sa.Column("card_version_id", sa.UUID(), nullable=False),
        sa.Column(
            "result",
            sa.Enum("repeat", "know", name="review_result", native_enum=False),
            nullable=False,
        ),
        sa.Column("question_ms", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("answer_ms", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("source_opened", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["card_id"], ["cards.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["card_version_id"], ["card_versions.id"], ondelete="CASCADE"),
    )
    op.create_index("ix_learning_events_user_card", "learning_events", ["user_id", "card_id"])
    op.create_index("ix_learning_events_user_completed", "learning_events", ["user_id", "completed_at"])


def downgrade() -> None:
    op.drop_index("ix_learning_events_user_completed", "learning_events")
    op.drop_index("ix_learning_events_user_card", "learning_events")
    op.drop_table("learning_events")
