"""Baseline identity schema: users, roles, user_roles."""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "001_baseline_identity"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("display_name", sa.String(length=255), nullable=False),
        sa.Column("email", sa.String(length=320), nullable=True),
        sa.Column("password_hash", sa.String(length=255), nullable=True),
        sa.Column(
            "status",
            sa.Enum("active", "disabled", name="user_status", native_enum=False),
            nullable=False,
            server_default="active",
        ),
        sa.Column("locale", sa.String(length=16), nullable=False, server_default="ru"),
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
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("email"),
    )

    op.create_table(
        "roles",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column(
            "name",
            sa.Enum("admin", "mentor", "student", name="role_name", native_enum=False),
            nullable=False,
        ),
        sa.Column("description", sa.String(length=255), nullable=True),
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
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("name"),
    )

    op.create_table(
        "user_roles",
        sa.Column("user_id", sa.UUID(), nullable=False),
        sa.Column("role_id", sa.UUID(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["role_id"], ["roles.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("user_id", "role_id"),
        sa.UniqueConstraint("user_id", "role_id", name="uq_user_roles_user_role"),
    )

    op.bulk_insert(
        sa.table(
            "roles",
            sa.column("id", sa.UUID()),
            sa.column("name", sa.String()),
            sa.column("description", sa.String()),
        ),
        [
            {
                "id": "00000000-0000-4000-8000-000000000001",
                "name": "admin",
                "description": "Platform administrator",
            },
            {
                "id": "00000000-0000-4000-8000-000000000002",
                "name": "mentor",
                "description": "Mentor with student visibility",
            },
            {
                "id": "00000000-0000-4000-8000-000000000003",
                "name": "student",
                "description": "Learner account",
            },
        ],
    )


def downgrade() -> None:
    op.drop_table("user_roles")
    op.drop_table("roles")
    op.drop_table("users")
