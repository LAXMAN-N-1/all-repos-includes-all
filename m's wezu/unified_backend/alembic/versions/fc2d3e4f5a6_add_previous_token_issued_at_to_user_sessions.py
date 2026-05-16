"""add previous_token_issued_at to user_sessions

Revision ID: fc2d3e4f5a6
Revises: fb1c2d3e4f5a
Create Date: 2026-04-22 15:10:00.000000
"""
from typing import Sequence, Union

from alembic import context, op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "fc2d3e4f5a6"
down_revision: Union[str, Sequence[str], None] = "fb1c2d3e4f5a"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _has_column(inspector: sa.Inspector, table_name: str, column_name: str) -> bool:
    return any(col.get("name") == column_name for col in inspector.get_columns(table_name))


def _has_index(inspector: sa.Inspector, table_name: str, index_name: str) -> bool:
    return any(index.get("name") == index_name for index in inspector.get_indexes(table_name))


def upgrade() -> None:
    if context.is_offline_mode():
        op.execute(
            "ALTER TABLE user_sessions ADD COLUMN IF NOT EXISTS previous_token_issued_at TIMESTAMP WITHOUT TIME ZONE"
        )
        op.execute(
            "CREATE INDEX IF NOT EXISTS ix_user_sessions_previous_token_issued_at ON user_sessions (previous_token_issued_at)"
        )
        op.execute(
            "CREATE INDEX IF NOT EXISTS ix_idempotency_keys_expires_at ON idempotency_keys (expires_at)"
        )
        return

    bind = op.get_bind()
    inspector = sa.inspect(bind)
    if not _has_column(inspector, "user_sessions", "previous_token_issued_at"):
        op.add_column(
            "user_sessions",
            sa.Column("previous_token_issued_at", sa.DateTime(), nullable=True),
        )
    inspector = sa.inspect(bind)
    if not _has_index(inspector, "user_sessions", "ix_user_sessions_previous_token_issued_at"):
        op.create_index(
            "ix_user_sessions_previous_token_issued_at",
            "user_sessions",
            ["previous_token_issued_at"],
            unique=False,
        )
    inspector = sa.inspect(bind)
    if not _has_index(inspector, "idempotency_keys", "ix_idempotency_keys_expires_at"):
        op.create_index(
            "ix_idempotency_keys_expires_at",
            "idempotency_keys",
            ["expires_at"],
            unique=False,
        )


def downgrade() -> None:
    if context.is_offline_mode():
        op.execute("DROP INDEX IF EXISTS ix_user_sessions_previous_token_issued_at")
        op.execute("ALTER TABLE user_sessions DROP COLUMN IF EXISTS previous_token_issued_at")
        return

    bind = op.get_bind()
    inspector = sa.inspect(bind)
    if _has_index(inspector, "idempotency_keys", "ix_idempotency_keys_expires_at"):
        op.drop_index("ix_idempotency_keys_expires_at", table_name="idempotency_keys")
    inspector = sa.inspect(bind)
    if _has_index(inspector, "user_sessions", "ix_user_sessions_previous_token_issued_at"):
        op.drop_index("ix_user_sessions_previous_token_issued_at", table_name="user_sessions")
    inspector = sa.inspect(bind)
    if _has_column(inspector, "user_sessions", "previous_token_issued_at"):
        op.drop_column("user_sessions", "previous_token_issued_at")
