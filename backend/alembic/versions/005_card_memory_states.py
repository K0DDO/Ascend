"""SRS: card_memory_states table."""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "005_card_memory_states"
down_revision: Union[str, None] = "004_learning_events"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "card_memory_states",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=False),
        sa.Column("card_id", sa.UUID(), nullable=False),
        sa.Column("stability", sa.Float(), nullable=False),
        sa.Column("difficulty", sa.Float(), nullable=False),
        sa.Column("interval_h", sa.Float(), nullable=False),
        sa.Column("reps", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("lapses", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("due_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("last_reviewed_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("algorithm_version", sa.String(length=32), nullable=False),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["card_id"], ["cards.id"], ondelete="CASCADE"),
        sa.UniqueConstraint("user_id", "card_id", name="uq_card_memory_states_user_card"),
    )
    op.create_index("ix_card_memory_states_user", "card_memory_states", ["user_id"])
    op.create_index("ix_card_memory_states_due", "card_memory_states", ["user_id", "due_at"])


def downgrade() -> None:
    op.drop_index("ix_card_memory_states_due", "card_memory_states")
    op.drop_index("ix_card_memory_states_user", "card_memory_states")
    op.drop_table("card_memory_states")
