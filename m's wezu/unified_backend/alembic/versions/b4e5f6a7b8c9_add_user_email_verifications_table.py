"""add user_email_verifications table for canonical email verification state

Revision ID: b4e5f6a7b8c9
Revises: a1b2c3d4e5fb
Create Date: 2026-04-21 18:10:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "b4e5f6a7b8c9"
down_revision: Union[str, Sequence[str], None] = "a1b2c3d4e5fb"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    conn = op.get_bind()
    inspector = sa.inspect(conn)

    if not inspector.has_table("user_email_verifications"):
        op.create_table(
            "user_email_verifications",
            sa.Column("id", sa.Integer(), nullable=False),
            sa.Column("user_id", sa.Integer(), nullable=False),
            sa.Column("token_hash", sa.String(), nullable=False),
            sa.Column("expires_at", sa.DateTime(), nullable=False),
            sa.Column("consumed_at", sa.DateTime(), nullable=True),
            sa.Column("created_at", sa.DateTime(), nullable=False),
            sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
            sa.PrimaryKeyConstraint("id"),
            sa.UniqueConstraint("token_hash"),
        )

    op.execute(
        "CREATE INDEX IF NOT EXISTS ix_user_email_verifications_user_id "
        "ON user_email_verifications (user_id)"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS ix_user_email_verifications_token_hash "
        "ON user_email_verifications (token_hash)"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS ix_user_email_verifications_expires_at "
        "ON user_email_verifications (expires_at)"
    )
    op.execute(
        "CREATE INDEX IF NOT EXISTS ix_user_email_verifications_consumed_at "
        "ON user_email_verifications (consumed_at)"
    )


def downgrade() -> None:
    conn = op.get_bind()
    inspector = sa.inspect(conn)
    if not inspector.has_table("user_email_verifications"):
        return

    op.execute("DROP INDEX IF EXISTS ix_user_email_verifications_consumed_at")
    op.execute("DROP INDEX IF EXISTS ix_user_email_verifications_expires_at")
    op.execute("DROP INDEX IF EXISTS ix_user_email_verifications_token_hash")
    op.execute("DROP INDEX IF EXISTS ix_user_email_verifications_user_id")
    op.drop_table("user_email_verifications")
