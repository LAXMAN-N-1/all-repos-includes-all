"""add_tenant_domain_tables

Revision ID: e0a1b2c3d4e6
Revises: e0a1b2c3d4e5
Create Date: 2026-04-22 22:18:00.000000
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "e0a1b2c3d4e6"
down_revision: Union[str, None] = "e0a1b2c3d4e5"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _table_exists(inspector: sa.Inspector, table_name: str) -> bool:
    try:
        return inspector.has_table(table_name)
    except Exception:
        return False


def upgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    if not _table_exists(inspector, "tenants"):
        op.create_table(
            "tenants",
            sa.Column("id", sa.Integer(), primary_key=True, nullable=False),
            sa.Column("slug", sa.String(length=128), nullable=False),
            sa.Column("name", sa.String(length=255), nullable=False),
            sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
            sa.Column("created_at", sa.DateTime(), nullable=False),
            sa.Column("updated_at", sa.DateTime(), nullable=False),
            sa.UniqueConstraint("slug", name="uq_tenants_slug"),
        )

    op.execute("CREATE INDEX IF NOT EXISTS ix_tenants_slug ON tenants (slug)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_tenants_is_active ON tenants (is_active)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_tenants_created_at ON tenants (created_at)")

    if not _table_exists(inspector, "tenant_memberships"):
        op.create_table(
            "tenant_memberships",
            sa.Column("id", sa.Integer(), primary_key=True, nullable=False),
            sa.Column("tenant_id", sa.Integer(), nullable=False),
            sa.Column("user_id", sa.Integer(), nullable=False),
            sa.Column("status", sa.String(length=32), nullable=False, server_default="active"),
            sa.Column("scope", sa.String(length=64), nullable=False, server_default="tenant_member"),
            sa.Column("is_default", sa.Boolean(), nullable=False, server_default=sa.text("false")),
            sa.Column("linked_at", sa.DateTime(), nullable=False),
            sa.Column("created_at", sa.DateTime(), nullable=False),
            sa.Column("updated_at", sa.DateTime(), nullable=False),
            sa.ForeignKeyConstraint(["tenant_id"], ["tenants.id"]),
            sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
            sa.UniqueConstraint("tenant_id", "user_id", name="uq_tenant_memberships_tenant_user"),
        )

    op.execute("CREATE INDEX IF NOT EXISTS ix_tenant_memberships_tenant_id ON tenant_memberships (tenant_id)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_tenant_memberships_user_id ON tenant_memberships (user_id)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_tenant_memberships_status ON tenant_memberships (status)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_tenant_memberships_is_default ON tenant_memberships (is_default)")
    op.execute("CREATE INDEX IF NOT EXISTS ix_tenant_memberships_linked_at ON tenant_memberships (linked_at)")

    inspector = sa.inspect(bind)
    existing_tables = set(inspector.get_table_names())
    now = datetime.now(timezone.utc).replace(tzinfo=None)

    if "dealer_profiles" in existing_tables:
        dealer_rows = bind.execute(
            sa.text(
                """
                SELECT id, user_id, business_name, is_active
                FROM dealer_profiles
                WHERE id IS NOT NULL
                """
            )
        ).fetchall()

        for row in dealer_rows:
            tenant_id = int(row.id)
            name = (row.business_name or "").strip() or f"Dealer {tenant_id}"
            slug = f"dealer-{tenant_id}"
            bind.execute(
                sa.text(
                    """
                    INSERT INTO tenants (id, slug, name, is_active, created_at, updated_at)
                    VALUES (:id, :slug, :name, :is_active, :created_at, :updated_at)
                    ON CONFLICT (id) DO UPDATE
                    SET name = EXCLUDED.name,
                        slug = EXCLUDED.slug,
                        is_active = EXCLUDED.is_active,
                        updated_at = EXCLUDED.updated_at
                    """
                ),
                {
                    "id": tenant_id,
                    "slug": slug,
                    "name": name,
                    "is_active": bool(row.is_active) if row.is_active is not None else True,
                    "created_at": now,
                    "updated_at": now,
                },
            )

            if row.user_id is not None:
                bind.execute(
                    sa.text(
                        """
                        INSERT INTO tenant_memberships (
                            tenant_id, user_id, status, scope, is_default, linked_at, created_at, updated_at
                        )
                        VALUES (
                            :tenant_id, :user_id, 'active', 'tenant_owner', true, :linked_at, :created_at, :updated_at
                        )
                        ON CONFLICT (tenant_id, user_id) DO UPDATE
                        SET status = 'active',
                            scope = 'tenant_owner',
                            is_default = true,
                            updated_at = EXCLUDED.updated_at
                        """
                    ),
                    {
                        "tenant_id": tenant_id,
                        "user_id": int(row.user_id),
                        "linked_at": now,
                        "created_at": now,
                        "updated_at": now,
                    },
                )

    if "users" in existing_tables:
        created_by_rows = bind.execute(
            sa.text(
                """
                SELECT id, created_by_dealer_id
                FROM users
                WHERE created_by_dealer_id IS NOT NULL
                """
            )
        ).fetchall()
        for row in created_by_rows:
            bind.execute(
                sa.text(
                    """
                    INSERT INTO tenant_memberships (
                        tenant_id, user_id, status, scope, is_default, linked_at, created_at, updated_at
                    )
                    VALUES (
                        :tenant_id, :user_id, 'active', 'tenant_member', false, :linked_at, :created_at, :updated_at
                    )
                    ON CONFLICT (tenant_id, user_id) DO NOTHING
                    """
                ),
                {
                    "tenant_id": int(row.created_by_dealer_id),
                    "user_id": int(row.id),
                    "linked_at": now,
                    "created_at": now,
                    "updated_at": now,
                },
            )

    bind.execute(
        sa.text(
            """
            WITH ranked AS (
                SELECT
                    id,
                    ROW_NUMBER() OVER (
                        PARTITION BY user_id
                        ORDER BY CASE WHEN is_default THEN 0 ELSE 1 END, linked_at, id
                    ) AS rn
                FROM tenant_memberships
                WHERE status = 'active'
            )
            UPDATE tenant_memberships tm
            SET is_default = CASE WHEN ranked.rn = 1 THEN true ELSE false END,
                updated_at = :updated_at
            FROM ranked
            WHERE ranked.id = tm.id
            """
        ),
        {"updated_at": now},
    )


def downgrade() -> None:
    op.execute("DROP INDEX IF EXISTS ix_tenant_memberships_linked_at")
    op.execute("DROP INDEX IF EXISTS ix_tenant_memberships_is_default")
    op.execute("DROP INDEX IF EXISTS ix_tenant_memberships_status")
    op.execute("DROP INDEX IF EXISTS ix_tenant_memberships_user_id")
    op.execute("DROP INDEX IF EXISTS ix_tenant_memberships_tenant_id")
    op.execute("DROP TABLE IF EXISTS tenant_memberships")

    op.execute("DROP INDEX IF EXISTS ix_tenants_created_at")
    op.execute("DROP INDEX IF EXISTS ix_tenants_is_active")
    op.execute("DROP INDEX IF EXISTS ix_tenants_slug")
    op.execute("DROP TABLE IF EXISTS tenants")
