"""dealer station replenishment rbac

Revision ID: 0f4a5b6c7d8e
Revises: fd3e4f5a6b7c
Create Date: 2026-04-23 18:30:00.000000
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "0f4a5b6c7d8e"
down_revision: Union[str, None] = "fd3e4f5a6b7c"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _table_exists(inspector: sa.Inspector, table_name: str) -> bool:
    try:
        return inspector.has_table(table_name)
    except Exception:
        return False


def _column_exists(inspector: sa.Inspector, table_name: str, column_name: str) -> bool:
    try:
        return any(col.get("name") == column_name for col in inspector.get_columns(table_name))
    except Exception:
        return False


def _fk_exists(inspector: sa.Inspector, table_name: str, fk_name: str) -> bool:
    try:
        return any(fk.get("name") == fk_name for fk in inspector.get_foreign_keys(table_name))
    except Exception:
        return False


def _add_column_if_missing(
    inspector: sa.Inspector,
    table_name: str,
    column: sa.Column,
) -> None:
    if _table_exists(inspector, table_name) and not _column_exists(inspector, table_name, column.name):
        op.add_column(table_name, column)


def _create_fk_if_missing(
    bind: sa.engine.Connection,
    inspector: sa.Inspector,
    table_name: str,
    fk_name: str,
    local_cols: list[str],
    remote_table: str,
    remote_cols: list[str],
) -> None:
    if bind.dialect.name == "sqlite":
        return
    if _table_exists(inspector, table_name) and _table_exists(inspector, remote_table) and not _fk_exists(inspector, table_name, fk_name):
        op.create_foreign_key(fk_name, table_name, remote_table, local_cols, remote_cols)


def _create_indexes() -> None:
    indexes = (
        "CREATE INDEX IF NOT EXISTS ix_dealer_profiles_tenant_id ON dealer_profiles (tenant_id)",
        "CREATE INDEX IF NOT EXISTS ix_stations_tenant_id ON stations (tenant_id)",
        "CREATE INDEX IF NOT EXISTS ix_dealer_stock_requests_tenant_id ON dealer_stock_requests (tenant_id)",
        "CREATE INDEX IF NOT EXISTS ix_dealer_stock_requests_station_id ON dealer_stock_requests (station_id)",
        "CREATE INDEX IF NOT EXISTS ix_dealer_stock_requests_source_warehouse_id ON dealer_stock_requests (source_warehouse_id)",
        "CREATE INDEX IF NOT EXISTS ix_dealer_stock_requests_assigned_transfer_id ON dealer_stock_requests (assigned_transfer_id)",
        "CREATE INDEX IF NOT EXISTS ix_inventory_transfers_dealer_stock_request_id ON inventory_transfers (dealer_stock_request_id)",
        "CREATE INDEX IF NOT EXISTS ix_inventory_transfers_created_by_user_id ON inventory_transfers (created_by_user_id)",
        "CREATE INDEX IF NOT EXISTS ix_inventory_transfers_received_by_user_id ON inventory_transfers (received_by_user_id)",
        "CREATE INDEX IF NOT EXISTS ix_station_staff_assignments_dealer_id ON station_staff_assignments (dealer_id)",
        "CREATE INDEX IF NOT EXISTS ix_station_staff_assignments_station_id ON station_staff_assignments (station_id)",
        "CREATE INDEX IF NOT EXISTS ix_station_staff_assignments_user_id ON station_staff_assignments (user_id)",
        "CREATE INDEX IF NOT EXISTS ix_station_staff_assignments_assigned_by_user_id ON station_staff_assignments (assigned_by_user_id)",
        "CREATE INDEX IF NOT EXISTS ix_station_staff_assignments_is_active ON station_staff_assignments (is_active)",
        "CREATE INDEX IF NOT EXISTS ix_station_staff_assignments_created_at ON station_staff_assignments (created_at)",
        "CREATE INDEX IF NOT EXISTS ix_warehouse_user_assignments_warehouse_id ON warehouse_user_assignments (warehouse_id)",
        "CREATE INDEX IF NOT EXISTS ix_warehouse_user_assignments_user_id ON warehouse_user_assignments (user_id)",
        "CREATE INDEX IF NOT EXISTS ix_warehouse_user_assignments_assigned_by_user_id ON warehouse_user_assignments (assigned_by_user_id)",
        "CREATE INDEX IF NOT EXISTS ix_warehouse_user_assignments_is_active ON warehouse_user_assignments (is_active)",
        "CREATE INDEX IF NOT EXISTS ix_warehouse_user_assignments_created_at ON warehouse_user_assignments (created_at)",
    )
    for statement in indexes:
        op.execute(statement)


def _normalize_station_tenant_id(bind: sa.engine.Connection, inspector: sa.Inspector) -> None:
    if not _table_exists(inspector, "stations") or not _column_exists(inspector, "stations", "tenant_id"):
        return

    if bind.dialect.name == "postgresql":
        op.execute(
            sa.text(
                """
                UPDATE stations
                SET tenant_id = NULL
                WHERE tenant_id IS NOT NULL
                  AND tenant_id::text !~ '^[0-9]+$'
                """
            )
        )
        op.execute(
            sa.text(
                """
                ALTER TABLE stations
                ALTER COLUMN tenant_id TYPE INTEGER
                USING CASE
                    WHEN tenant_id::text ~ '^[0-9]+$' THEN tenant_id::integer
                    ELSE NULL
                END
                """
            )
        )
    elif bind.dialect.name == "sqlite":
        op.execute(
            """
            UPDATE stations
            SET tenant_id = NULL
            WHERE tenant_id IS NOT NULL
              AND tenant_id GLOB '*[^0-9]*'
            """
        )
        with op.batch_alter_table("stations") as batch:
            batch.alter_column("tenant_id", existing_type=sa.String(), type_=sa.Integer(), existing_nullable=True)


def _backfill_dealer_tenants(bind: sa.engine.Connection, inspector: sa.Inspector) -> None:
    if not _table_exists(inspector, "dealer_profiles") or not _table_exists(inspector, "tenants"):
        return

    now = datetime.now(timezone.utc).replace(tzinfo=None)
    dealers = bind.execute(
        sa.text(
            """
            SELECT id, user_id, business_name, is_active
            FROM dealer_profiles
            WHERE id IS NOT NULL
            """
        )
    ).fetchall()
    for dealer in dealers:
        tenant_id = int(dealer.id)
        bind.execute(
            sa.text(
                """
                INSERT INTO tenants (id, slug, name, is_active, created_at, updated_at)
                VALUES (:id, :slug, :name, :is_active, :created_at, :updated_at)
                ON CONFLICT (id) DO UPDATE
                SET slug = EXCLUDED.slug,
                    name = EXCLUDED.name,
                    is_active = EXCLUDED.is_active,
                    updated_at = EXCLUDED.updated_at
                """
            ),
            {
                "id": tenant_id,
                "slug": f"dealer-{tenant_id}",
                "name": (dealer.business_name or "").strip() or f"Dealer {tenant_id}",
                "is_active": bool(dealer.is_active) if dealer.is_active is not None else True,
                "created_at": now,
                "updated_at": now,
            },
        )

        if _table_exists(inspector, "tenant_memberships") and dealer.user_id is not None:
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
                    "user_id": int(dealer.user_id),
                    "linked_at": now,
                    "created_at": now,
                    "updated_at": now,
                },
            )

    if _column_exists(inspector, "dealer_profiles", "tenant_id"):
        bind.execute(sa.text("UPDATE dealer_profiles SET tenant_id = id WHERE tenant_id IS NULL"))


def _backfill_scoped_tables(bind: sa.engine.Connection, inspector: sa.Inspector) -> None:
    if _table_exists(inspector, "stations") and _column_exists(inspector, "stations", "tenant_id"):
        bind.execute(
            sa.text(
                """
                UPDATE stations
                SET tenant_id = (
                    SELECT COALESCE(dp.tenant_id, dp.id)
                    FROM dealer_profiles dp
                    WHERE dp.id = stations.dealer_id
                )
                WHERE tenant_id IS NULL
                  AND dealer_id IS NOT NULL
                """
            )
        )

    if _table_exists(inspector, "dealer_stock_requests") and _column_exists(inspector, "dealer_stock_requests", "tenant_id"):
        bind.execute(
            sa.text(
                """
                UPDATE dealer_stock_requests
                SET tenant_id = (
                    SELECT COALESCE(dp.tenant_id, dp.id)
                    FROM dealer_profiles dp
                    WHERE dp.id = dealer_stock_requests.dealer_id
                )
                WHERE tenant_id IS NULL
                  AND dealer_id IS NOT NULL
                """
            )
        )


def upgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    _add_column_if_missing(
        inspector,
        "dealer_profiles",
        sa.Column("tenant_id", sa.Integer(), nullable=True),
    )
    _normalize_station_tenant_id(bind, inspector)

    inspector = sa.inspect(bind)
    _add_column_if_missing(inspector, "dealer_stock_requests", sa.Column("tenant_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "dealer_stock_requests", sa.Column("station_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "dealer_stock_requests", sa.Column("source_warehouse_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "dealer_stock_requests", sa.Column("assigned_transfer_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "inventory_transfers", sa.Column("dealer_stock_request_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "inventory_transfers", sa.Column("created_by_user_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "inventory_transfers", sa.Column("dispatched_at", sa.DateTime(), nullable=True))
    _add_column_if_missing(inspector, "inventory_transfers", sa.Column("received_by_user_id", sa.Integer(), nullable=True))

    inspector = sa.inspect(bind)
    if not _table_exists(inspector, "station_staff_assignments"):
        op.create_table(
            "station_staff_assignments",
            sa.Column("id", sa.Integer(), nullable=False),
            sa.Column("dealer_id", sa.Integer(), nullable=False),
            sa.Column("station_id", sa.Integer(), nullable=False),
            sa.Column("user_id", sa.Integer(), nullable=False),
            sa.Column("assigned_by_user_id", sa.Integer(), nullable=True),
            sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
            sa.Column("created_at", sa.DateTime(), nullable=False),
            sa.Column("updated_at", sa.DateTime(), nullable=False),
            sa.ForeignKeyConstraint(["assigned_by_user_id"], ["users.id"]),
            sa.ForeignKeyConstraint(["dealer_id"], ["dealer_profiles.id"]),
            sa.ForeignKeyConstraint(["station_id"], ["stations.id"]),
            sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
            sa.PrimaryKeyConstraint("id"),
            sa.UniqueConstraint("user_id", "station_id", name="uq_station_staff_user_station"),
        )

    if not _table_exists(inspector, "warehouse_user_assignments"):
        op.create_table(
            "warehouse_user_assignments",
            sa.Column("id", sa.Integer(), nullable=False),
            sa.Column("warehouse_id", sa.Integer(), nullable=False),
            sa.Column("user_id", sa.Integer(), nullable=False),
            sa.Column("assigned_by_user_id", sa.Integer(), nullable=True),
            sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
            sa.Column("created_at", sa.DateTime(), nullable=False),
            sa.Column("updated_at", sa.DateTime(), nullable=False),
            sa.ForeignKeyConstraint(["assigned_by_user_id"], ["users.id"]),
            sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
            sa.ForeignKeyConstraint(["warehouse_id"], ["warehouses.id"]),
            sa.PrimaryKeyConstraint("id"),
            sa.UniqueConstraint("user_id", "warehouse_id", name="uq_warehouse_user_assignment"),
        )

    _create_indexes()

    inspector = sa.inspect(bind)
    _backfill_dealer_tenants(bind, inspector)
    inspector = sa.inspect(bind)
    _backfill_scoped_tables(bind, inspector)

    inspector = sa.inspect(bind)
    for table_name, fk_name, local_cols, remote_table, remote_cols in (
        ("dealer_profiles", "fk_dealer_profiles_tenant_id_tenants", ["tenant_id"], "tenants", ["id"]),
        ("stations", "fk_stations_tenant_id_tenants", ["tenant_id"], "tenants", ["id"]),
        ("dealer_stock_requests", "fk_dealer_stock_requests_tenant_id_tenants", ["tenant_id"], "tenants", ["id"]),
        ("dealer_stock_requests", "fk_dealer_stock_requests_station_id_stations", ["station_id"], "stations", ["id"]),
        ("dealer_stock_requests", "fk_dealer_stock_requests_source_warehouse_id_warehouses", ["source_warehouse_id"], "warehouses", ["id"]),
        ("dealer_stock_requests", "fk_dlr_stock_reqs_assigned_transfer_id", ["assigned_transfer_id"], "inventory_transfers", ["id"]),
        ("inventory_transfers", "fk_inv_transfers_dlr_stock_req_id", ["dealer_stock_request_id"], "dealer_stock_requests", ["id"]),
        ("inventory_transfers", "fk_inventory_transfers_created_by_user_id_users", ["created_by_user_id"], "users", ["id"]),
        ("inventory_transfers", "fk_inventory_transfers_received_by_user_id_users", ["received_by_user_id"], "users", ["id"]),
    ):
        _create_fk_if_missing(bind, inspector, table_name, fk_name, local_cols, remote_table, remote_cols)


def downgrade() -> None:
    bind = op.get_bind()

    for index_name in (
        "ix_warehouse_user_assignments_created_at",
        "ix_warehouse_user_assignments_is_active",
        "ix_warehouse_user_assignments_assigned_by_user_id",
        "ix_warehouse_user_assignments_user_id",
        "ix_warehouse_user_assignments_warehouse_id",
        "ix_station_staff_assignments_created_at",
        "ix_station_staff_assignments_is_active",
        "ix_station_staff_assignments_assigned_by_user_id",
        "ix_station_staff_assignments_user_id",
        "ix_station_staff_assignments_station_id",
        "ix_station_staff_assignments_dealer_id",
        "ix_inventory_transfers_received_by_user_id",
        "ix_inventory_transfers_created_by_user_id",
        "ix_inventory_transfers_dealer_stock_request_id",
        "ix_dealer_stock_requests_assigned_transfer_id",
        "ix_dealer_stock_requests_source_warehouse_id",
        "ix_dealer_stock_requests_station_id",
        "ix_dealer_stock_requests_tenant_id",
        "ix_stations_tenant_id",
        "ix_dealer_profiles_tenant_id",
    ):
        op.execute(f"DROP INDEX IF EXISTS {index_name}")

    inspector = sa.inspect(bind)
    if _table_exists(inspector, "warehouse_user_assignments"):
        op.drop_table("warehouse_user_assignments")
    if _table_exists(inspector, "station_staff_assignments"):
        op.drop_table("station_staff_assignments")

    if bind.dialect.name != "sqlite":
        inspector = sa.inspect(bind)
        for table_name, fk_name in (
            ("inventory_transfers", "fk_inventory_transfers_received_by_user_id_users"),
            ("inventory_transfers", "fk_inventory_transfers_created_by_user_id_users"),
            ("inventory_transfers", "fk_inv_transfers_dlr_stock_req_id"),
            ("dealer_stock_requests", "fk_dlr_stock_reqs_assigned_transfer_id"),
            ("dealer_stock_requests", "fk_dealer_stock_requests_source_warehouse_id_warehouses"),
            ("dealer_stock_requests", "fk_dealer_stock_requests_station_id_stations"),
            ("dealer_stock_requests", "fk_dealer_stock_requests_tenant_id_tenants"),
            ("stations", "fk_stations_tenant_id_tenants"),
            ("dealer_profiles", "fk_dealer_profiles_tenant_id_tenants"),
        ):
            if _table_exists(inspector, table_name) and _fk_exists(inspector, table_name, fk_name):
                op.drop_constraint(fk_name, table_name, type_="foreignkey")

    inspector = sa.inspect(bind)
    for table_name, columns in (
        ("inventory_transfers", ("received_by_user_id", "dispatched_at", "created_by_user_id", "dealer_stock_request_id")),
        ("dealer_stock_requests", ("assigned_transfer_id", "source_warehouse_id", "station_id", "tenant_id")),
        ("dealer_profiles", ("tenant_id",)),
    ):
        if _table_exists(inspector, table_name):
            for column_name in columns:
                if _column_exists(inspector, table_name, column_name):
                    op.drop_column(table_name, column_name)
