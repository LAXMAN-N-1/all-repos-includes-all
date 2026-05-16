from __future__ import annotations

from pathlib import Path


LATEST_MIGRATION_PATH = Path(
    "alembic/versions/e0a1b2c3d4e9_add_tenant_scope_to_logistics_inventory.py"
)
BASE_MIGRATION_PATH = Path(
    "alembic/versions/e0a1b2c3d4e8_enable_tenant_rls_core_tables.py"
)


def test_tenant_rls_migration_exists_and_is_head_linked():
    assert BASE_MIGRATION_PATH.exists(), "Base tenant RLS migration is missing"
    assert LATEST_MIGRATION_PATH.exists(), "Latest tenant RLS migration is missing"
    text = LATEST_MIGRATION_PATH.read_text(encoding="utf-8")
    assert 'down_revision: Union[str, None] = "e0a1b2c3d4e8"' in text


def test_tenant_rls_migration_enforces_force_rls_and_scope_policies():
    text = LATEST_MIGRATION_PATH.read_text(encoding="utf-8")
    assert "FORCE ROW LEVEL SECURITY" in text
    assert "wezu_global_access" in text
    assert "wezu_tenant_access" in text
    assert "current_setting('app.scope', true) = 'global'" in text
    assert "current_setting('app.scope', true) = 'tenant'" in text


def test_tenant_rls_migration_covers_critical_tenant_sensitive_tables():
    text = (
        BASE_MIGRATION_PATH.read_text(encoding="utf-8")
        + "\n"
        + LATEST_MIGRATION_PATH.read_text(encoding="utf-8")
    )
    for table_name in (
        "dealer_profiles",
        "logistics_orders",
        "logistics_order_batteries",
        "battery_transfers",
        "inventory_transfers",
        "inventory_transfer_items",
        "stations",
        "settlements",
        "commission_logs",
        "chargebacks",
        "settlement_disputes",
        "manifests",
        "manifest_items",
    ):
        assert table_name in text, f"RLS migration missing critical table: {table_name}"
