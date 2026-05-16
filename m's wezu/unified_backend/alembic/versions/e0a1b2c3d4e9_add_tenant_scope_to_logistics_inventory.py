"""add_tenant_scope_to_logistics_inventory

Revision ID: e0a1b2c3d4e9
Revises: e0a1b2c3d4e8
Create Date: 2026-04-23 01:10:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "e0a1b2c3d4e9"
down_revision: Union[str, None] = "e0a1b2c3d4e8"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


TENANT_TABLES: tuple[str, ...] = (
    "logistics_orders",
    "logistics_order_batteries",
    "battery_transfers",
    "logistics_manifests",
    "delivery_orders",
    "inventory_transfers",
    "inventory_transfer_items",
    "stock_discrepancies",
    "manifests",
    "manifest_items",
)

GLOBAL_SCOPE_EXPR = "current_setting('app.scope', true) = 'global'"
TENANT_SCOPE_EXPR = "current_setting('app.scope', true) = 'tenant'"
TENANT_ID_EXPR = "NULLIF(current_setting('app.tenant_id', true), '')::integer"


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


def _index_exists(inspector: sa.Inspector, table_name: str, index_name: str) -> bool:
    try:
        return any(idx.get("name") == index_name for idx in inspector.get_indexes(table_name))
    except Exception:
        return False


def _fk_exists(inspector: sa.Inspector, table_name: str, fk_name: str) -> bool:
    try:
        return any(fk.get("name") == fk_name for fk in inspector.get_foreign_keys(table_name))
    except Exception:
        return False


def _drop_policy_if_exists(table_name: str, policy_name: str) -> None:
    op.execute(sa.text(f'DROP POLICY IF EXISTS "{policy_name}" ON "{table_name}"'))


def _enable_rls_for_table(table_name: str) -> None:
    op.execute(sa.text(f'ALTER TABLE "{table_name}" ENABLE ROW LEVEL SECURITY'))
    op.execute(sa.text(f'ALTER TABLE "{table_name}" FORCE ROW LEVEL SECURITY'))

    _drop_policy_if_exists(table_name, "wezu_global_access")
    _drop_policy_if_exists(table_name, "wezu_tenant_access")

    tenant_predicate = f'"{table_name}"."tenant_id" = {TENANT_ID_EXPR}'
    tenant_scope_predicate = f"({TENANT_SCOPE_EXPR}) AND ({tenant_predicate})"

    op.execute(
        sa.text(
            f"""
            CREATE POLICY "wezu_global_access" ON "{table_name}"
            FOR ALL
            USING ({GLOBAL_SCOPE_EXPR})
            WITH CHECK ({GLOBAL_SCOPE_EXPR})
            """
        )
    )
    op.execute(
        sa.text(
            f"""
            CREATE POLICY "wezu_tenant_access" ON "{table_name}"
            FOR ALL
            USING ({tenant_scope_predicate})
            WITH CHECK ({tenant_scope_predicate})
            """
        )
    )


def _disable_rls_for_table(table_name: str) -> None:
    _drop_policy_if_exists(table_name, "wezu_global_access")
    _drop_policy_if_exists(table_name, "wezu_tenant_access")
    op.execute(sa.text(f'ALTER TABLE "{table_name}" NO FORCE ROW LEVEL SECURITY'))
    op.execute(sa.text(f'ALTER TABLE "{table_name}" DISABLE ROW LEVEL SECURITY'))


def _backfill_tenant_columns_postgres() -> None:
    op.execute(
        sa.text(
            """
            UPDATE logistics_orders o
            SET tenant_id = u.created_by_dealer_id
            FROM driver_profiles dp
            JOIN users u ON u.id = dp.user_id
            WHERE o.tenant_id IS NULL
              AND o.assigned_driver_id = dp.id
              AND u.created_by_dealer_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE logistics_orders child
            SET tenant_id = parent.tenant_id
            FROM logistics_orders parent
            WHERE child.tenant_id IS NULL
              AND child.original_order_id = parent.id
              AND parent.tenant_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE logistics_order_batteries ob
            SET tenant_id = o.tenant_id
            FROM logistics_orders o
            WHERE ob.tenant_id IS NULL
              AND ob.order_id = o.id
              AND o.tenant_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE logistics_manifests m
            SET tenant_id = u.created_by_dealer_id
            FROM users u
            WHERE m.tenant_id IS NULL
              AND m.driver_id = u.id
              AND u.created_by_dealer_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE battery_transfers bt
            SET tenant_id = lm.tenant_id
            FROM logistics_manifests lm
            WHERE bt.tenant_id IS NULL
              AND bt.manifest_id = lm.id
              AND lm.tenant_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE battery_transfers bt
            SET tenant_id = s.dealer_id
            FROM stations s
            WHERE bt.tenant_id IS NULL
              AND bt.to_location_type = 'station'
              AND bt.to_location_id = s.id
              AND s.dealer_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE battery_transfers bt
            SET tenant_id = s.dealer_id
            FROM stations s
            WHERE bt.tenant_id IS NULL
              AND bt.from_location_type = 'station'
              AND bt.from_location_id = s.id
              AND s.dealer_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE delivery_orders d
            SET tenant_id = u.created_by_dealer_id
            FROM users u
            WHERE d.tenant_id IS NULL
              AND d.assigned_driver_id = u.id
              AND u.created_by_dealer_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE inventory_transfers t
            SET tenant_id = s.dealer_id
            FROM stations s
            WHERE t.tenant_id IS NULL
              AND t.to_location_type = 'station'
              AND t.to_location_id = s.id
              AND s.dealer_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE inventory_transfers t
            SET tenant_id = s.dealer_id
            FROM stations s
            WHERE t.tenant_id IS NULL
              AND t.from_location_type = 'station'
              AND t.from_location_id = s.id
              AND s.dealer_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE inventory_transfer_items i
            SET tenant_id = t.tenant_id
            FROM inventory_transfers t
            WHERE i.tenant_id IS NULL
              AND i.transfer_id = t.id
              AND t.tenant_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE stock_discrepancies d
            SET tenant_id = s.dealer_id
            FROM stations s
            WHERE d.tenant_id IS NULL
              AND d.location_type = 'station'
              AND d.location_id = s.id
              AND s.dealer_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE manifests m
            SET tenant_id = src.tenant_id
            FROM (
                SELECT mi.manifest_id AS manifest_id, MAX(s.dealer_id) AS tenant_id
                FROM manifest_items mi
                JOIN batteries b ON b.id = mi.battery_table_id
                JOIN stations s
                  ON b.location_type = 'station'
                 AND b.location_id = s.id
                WHERE s.dealer_id IS NOT NULL
                GROUP BY mi.manifest_id
            ) AS src
            WHERE m.tenant_id IS NULL
              AND src.manifest_id = m.id
              AND src.tenant_id IS NOT NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE manifest_items mi
            SET tenant_id = m.tenant_id
            FROM manifests m
            WHERE mi.tenant_id IS NULL
              AND mi.manifest_id = m.id
              AND m.tenant_id IS NOT NULL
            """
        )
    )


def upgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)
    dialect = bind.dialect.name.lower()

    for table_name in TENANT_TABLES:
        if not _table_exists(inspector, table_name):
            continue

        if not _column_exists(inspector, table_name, "tenant_id"):
            op.add_column(table_name, sa.Column("tenant_id", sa.Integer(), nullable=True))

        inspector = sa.inspect(bind)
        index_name = f"ix_{table_name}_tenant_id"
        if not _index_exists(inspector, table_name, index_name):
            op.create_index(index_name, table_name, ["tenant_id"], unique=False)

        if dialect == "postgresql" and _table_exists(inspector, "tenants"):
            fk_name = f"fk_{table_name}_tenant_id_tenants"
            if not _fk_exists(inspector, table_name, fk_name):
                op.create_foreign_key(
                    fk_name,
                    table_name,
                    "tenants",
                    ["tenant_id"],
                    ["id"],
                    ondelete="SET NULL",
                )

    if dialect != "postgresql":
        return

    _backfill_tenant_columns_postgres()

    inspector = sa.inspect(bind)
    for table_name in TENANT_TABLES:
        if not _table_exists(inspector, table_name):
            continue
        if not _column_exists(inspector, table_name, "tenant_id"):
            continue
        _enable_rls_for_table(table_name)


def downgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)
    dialect = bind.dialect.name.lower()

    if dialect == "postgresql":
        for table_name in TENANT_TABLES:
            if not _table_exists(inspector, table_name):
                continue
            _disable_rls_for_table(table_name)

    for table_name in reversed(TENANT_TABLES):
        if not _table_exists(inspector, table_name):
            continue
        if not _column_exists(inspector, table_name, "tenant_id"):
            continue

        fk_name = f"fk_{table_name}_tenant_id_tenants"
        if dialect == "postgresql" and _fk_exists(inspector, table_name, fk_name):
            op.drop_constraint(fk_name, table_name, type_="foreignkey")

        index_name = f"ix_{table_name}_tenant_id"
        if _index_exists(inspector, table_name, index_name):
            op.drop_index(index_name, table_name=table_name)

        op.drop_column(table_name, "tenant_id")
