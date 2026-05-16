"""enable_tenant_rls_core_tables

Revision ID: e0a1b2c3d4e8
Revises: e0a1b2c3d4e7
Create Date: 2026-04-22 23:55:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "e0a1b2c3d4e8"
down_revision: Union[str, None] = "e0a1b2c3d4e7"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


GLOBAL_SCOPE_EXPR = "current_setting('app.scope', true) = 'global'"
TENANT_SCOPE_EXPR = "current_setting('app.scope', true) = 'tenant'"
TENANT_ID_EXPR = "NULLIF(current_setting('app.tenant_id', true), '')::integer"


DIRECT_TENANT_TABLES: dict[str, str] = {
    "dealer_profiles": "id",
    "dealer_documents": "dealer_id",
    "dealer_applications": "dealer_id",
    "dealer_inventories": "dealer_id",
    "dealer_stock_requests": "dealer_id",
    "dealer_promotions": "dealer_id",
    "staff_profiles": "dealer_id",
    "stations": "dealer_id",
    "settlements": "dealer_id",
}

DERIVED_TENANT_TABLES: dict[str, str] = {
    "users": (
        "("
        f"users.created_by_dealer_id = {TENANT_ID_EXPR}"
        f" OR EXISTS (SELECT 1 FROM dealer_profiles dp WHERE dp.user_id = users.id AND dp.id = {TENANT_ID_EXPR})"
        f" OR EXISTS (SELECT 1 FROM staff_profiles sp WHERE sp.user_id = users.id AND sp.dealer_id = {TENANT_ID_EXPR})"
        ")"
    ),
    "commission_logs": (
        f"EXISTS (SELECT 1 FROM dealer_profiles dp WHERE dp.user_id = commission_logs.dealer_id AND dp.id = {TENANT_ID_EXPR})"
    ),
    "chargebacks": (
        f"EXISTS (SELECT 1 FROM dealer_profiles dp WHERE dp.user_id = chargebacks.dealer_id AND dp.id = {TENANT_ID_EXPR})"
    ),
    "settlement_disputes": (
        f"EXISTS (SELECT 1 FROM dealer_profiles dp WHERE dp.user_id = settlement_disputes.dealer_id AND dp.id = {TENANT_ID_EXPR})"
    ),
    "inventory_transactions": (
        f"EXISTS (SELECT 1 FROM dealer_inventories di WHERE di.id = inventory_transactions.inventory_id AND di.dealer_id = {TENANT_ID_EXPR})"
    ),
    "promotion_usages": (
        f"EXISTS (SELECT 1 FROM dealer_promotions dp WHERE dp.id = promotion_usages.promotion_id AND dp.dealer_id = {TENANT_ID_EXPR})"
    ),
}


def _table_exists(inspector: sa.Inspector, table_name: str) -> bool:
    try:
        return inspector.has_table(table_name)
    except Exception:
        return False


def _drop_policy_if_exists(table_name: str, policy_name: str) -> None:
    op.execute(
        sa.text(
            f'DROP POLICY IF EXISTS "{policy_name}" ON "{table_name}"'
        )
    )


def _enable_rls_for_table(table_name: str, tenant_predicate: str) -> None:
    op.execute(sa.text(f'ALTER TABLE "{table_name}" ENABLE ROW LEVEL SECURITY'))
    op.execute(sa.text(f'ALTER TABLE "{table_name}" FORCE ROW LEVEL SECURITY'))

    _drop_policy_if_exists(table_name, "wezu_global_access")
    _drop_policy_if_exists(table_name, "wezu_tenant_access")

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


def upgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)
    dialect = bind.dialect.name.lower()

    # RLS is PostgreSQL-specific.
    if dialect != "postgresql":
        return

    for table_name, tenant_column in DIRECT_TENANT_TABLES.items():
        if not _table_exists(inspector, table_name):
            continue
        tenant_predicate = f'"{table_name}"."{tenant_column}" = {TENANT_ID_EXPR}'
        _enable_rls_for_table(table_name, tenant_predicate)

    for table_name, tenant_predicate in DERIVED_TENANT_TABLES.items():
        if not _table_exists(inspector, table_name):
            continue
        _enable_rls_for_table(table_name, tenant_predicate)


def downgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)
    dialect = bind.dialect.name.lower()

    if dialect != "postgresql":
        return

    all_tables = set(DIRECT_TENANT_TABLES.keys()) | set(DERIVED_TENANT_TABLES.keys())
    for table_name in sorted(all_tables):
        if not _table_exists(inspector, table_name):
            continue
        _disable_rls_for_table(table_name)
