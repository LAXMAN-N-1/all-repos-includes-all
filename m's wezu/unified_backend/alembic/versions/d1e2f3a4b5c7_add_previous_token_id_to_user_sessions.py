"""Add previous_token_id to user_sessions for refresh-rotation grace window

Revision ID: d1e2f3a4b5c7
Revises: c4f6e7f8a9d0
Create Date: 2026-04-20 12:00:00.000000

Why: When the backend successfully rotates a refresh token but the network
drops before the client receives the new tokens, the client retries with the
old token.  Storing the previous JTI lets validate_session accept that retry
for a short grace window instead of returning 401 and forcing a re-login.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'd1e2f3a4b5c7'
down_revision: Union[str, None] = 'c4f6e7f8a9d0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    columns = {column["name"] for column in inspector.get_columns("user_sessions")}
    if "previous_token_id" not in columns:
        op.add_column(
            "user_sessions",
            sa.Column("previous_token_id", sa.String(), nullable=True),
        )

    inspector = sa.inspect(bind)
    indexes = {index["name"] for index in inspector.get_indexes("user_sessions")}
    if "ix_user_sessions_previous_token_id" not in indexes:
        op.create_index(
            "ix_user_sessions_previous_token_id",
            "user_sessions",
            ["previous_token_id"],
            unique=False,
        )


def downgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    indexes = {index["name"] for index in inspector.get_indexes("user_sessions")}
    if "ix_user_sessions_previous_token_id" in indexes:
        op.drop_index("ix_user_sessions_previous_token_id", table_name="user_sessions")

    inspector = sa.inspect(bind)
    columns = {column["name"] for column in inspector.get_columns("user_sessions")}
    if "previous_token_id" in columns:
        op.drop_column("user_sessions", "previous_token_id")
