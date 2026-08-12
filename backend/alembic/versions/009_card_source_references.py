"""Card source references linking card versions to source blocks."""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "009_card_source_references"
down_revision: Union[str, None] = "008_mentor_admin_sync"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "card_source_references",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("card_version_id", sa.UUID(), nullable=False),
        sa.Column("document_id", sa.UUID(), nullable=False),
        sa.Column("source_version_id", sa.UUID(), nullable=False),
        sa.Column("block_id", sa.UUID(), nullable=True),
        sa.Column("range", sa.JSON(), nullable=True),
        sa.Column("position", sa.Integer(), nullable=False, server_default="0"),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["card_version_id"], ["card_versions.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["document_id"], ["source_documents.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["source_version_id"], ["source_versions.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["block_id"], ["source_blocks.id"], ondelete="SET NULL"),
        sa.UniqueConstraint("card_version_id", "block_id", name="uq_card_source_ref_version_block"),
    )
    op.create_index("ix_card_source_references_card_version_id", "card_source_references", ["card_version_id"])

    op.create_table(
        "analytics_events",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=True),
        sa.Column("device_id", sa.String(length=128), nullable=True),
        sa.Column("event_name", sa.String(length=64), nullable=False),
        sa.Column("payload_json", sa.JSON(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="SET NULL"),
    )
    op.create_index("ix_analytics_events_name", "analytics_events", ["event_name"])


def downgrade() -> None:
    op.drop_index("ix_analytics_events_name", "analytics_events")
    op.drop_table("analytics_events")
    op.drop_index("ix_card_source_references_card_version_id", "card_source_references")
    op.drop_table("card_source_references")
