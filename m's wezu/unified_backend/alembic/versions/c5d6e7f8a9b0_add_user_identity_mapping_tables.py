"""add user identity mapping and identity-link audit tables

Revision ID: c5d6e7f8a9b0
Revises: b4e5f6a7b8c9
Create Date: 2026-04-21 20:05:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "c5d6e7f8a9b0"
down_revision: Union[str, Sequence[str], None] = "b4e5f6a7b8c9"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    conn = op.get_bind()
    inspector = sa.inspect(conn)

    if not inspector.has_table("user_identities"):
        op.create_table(
            "user_identities",
            sa.Column("id", sa.Integer(), nullable=False),
            sa.Column("provider", sa.String(length=64), nullable=False),
            sa.Column("external_subject", sa.String(length=255), nullable=False),
            sa.Column("user_id", sa.Integer(), nullable=False),
            sa.Column("email_snapshot", sa.String(length=320), nullable=True),
            sa.Column("status", sa.String(length=16), nullable=False),
            sa.Column("linked_at", sa.DateTime(), nullable=False),
            sa.Column("last_seen_at", sa.DateTime(), nullable=False),
            sa.Column("created_at", sa.DateTime(), nullable=False),
            sa.Column("updated_at", sa.DateTime(), nullable=False),
            sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
            sa.PrimaryKeyConstraint("id"),
            sa.UniqueConstraint("provider", "external_subject", name="uq_user_identities_provider_subject"),
        )

    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identities_provider ON user_identities (provider)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identities_external_subject ON user_identities (external_subject)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identities_user_id ON user_identities (user_id)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identities_status ON user_identities (status)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identities_linked_at ON user_identities (linked_at)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identities_last_seen_at ON user_identities (last_seen_at)")

    if not inspector.has_table("user_identity_link_audit"):
        op.create_table(
            "user_identity_link_audit",
            sa.Column("id", sa.Integer(), nullable=False),
            sa.Column("provider", sa.String(length=64), nullable=False),
            sa.Column("external_subject", sa.String(length=255), nullable=True),
            sa.Column("email_snapshot", sa.String(length=320), nullable=True),
            sa.Column("user_id", sa.Integer(), nullable=True),
            sa.Column("event_type", sa.String(length=64), nullable=False),
            sa.Column("detail_code", sa.String(length=128), nullable=False),
            sa.Column("success", sa.Boolean(), nullable=False),
            sa.Column("ip_address", sa.String(length=64), nullable=True),
            sa.Column("user_agent", sa.String(length=512), nullable=True),
            sa.Column("created_at", sa.DateTime(), nullable=False),
            sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
            sa.PrimaryKeyConstraint("id"),
        )

    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identity_link_audit_provider ON user_identity_link_audit (provider)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identity_link_audit_external_subject ON user_identity_link_audit (external_subject)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identity_link_audit_email_snapshot ON user_identity_link_audit (email_snapshot)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identity_link_audit_user_id ON user_identity_link_audit (user_id)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identity_link_audit_event_type ON user_identity_link_audit (event_type)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identity_link_audit_success ON user_identity_link_audit (success)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_user_identity_link_audit_created_at ON user_identity_link_audit (created_at)")


def downgrade() -> None:
    conn = op.get_bind()
    inspector = sa.inspect(conn)

    if inspector.has_table("user_identity_link_audit"):
        op.execute("DROP INDEX IF EXISTS ix_user_identity_link_audit_created_at")
        op.execute("DROP INDEX IF EXISTS ix_user_identity_link_audit_success")
        op.execute("DROP INDEX IF EXISTS ix_user_identity_link_audit_event_type")
        op.execute("DROP INDEX IF EXISTS ix_user_identity_link_audit_user_id")
        op.execute("DROP INDEX IF EXISTS ix_user_identity_link_audit_email_snapshot")
        op.execute("DROP INDEX IF EXISTS ix_user_identity_link_audit_external_subject")
        op.execute("DROP INDEX IF EXISTS ix_user_identity_link_audit_provider")
        op.drop_table("user_identity_link_audit")

    if inspector.has_table("user_identities"):
        op.execute("DROP INDEX IF EXISTS ix_user_identities_last_seen_at")
        op.execute("DROP INDEX IF EXISTS ix_user_identities_linked_at")
        op.execute("DROP INDEX IF EXISTS ix_user_identities_status")
        op.execute("DROP INDEX IF EXISTS ix_user_identities_user_id")
        op.execute("DROP INDEX IF EXISTS ix_user_identities_external_subject")
        op.execute("DROP INDEX IF EXISTS ix_user_identities_provider")
        op.drop_table("user_identities")
