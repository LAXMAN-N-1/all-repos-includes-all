"""canonical delivery/rental cutover with actor-scoped RBAC + RLS

Revision ID: 2c4d6e8f0a1b
Revises: 1a2b3c4d5e6f
Create Date: 2026-04-24 23:10:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "2c4d6e8f0a1b"
down_revision: Union[str, None] = "1a2b3c4d5e6f"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


CANONICAL_STATUSES = (
    "PENDING_ADMIN_APPROVAL",
    "APPROVED",
    "ASSIGNED_TO_WAREHOUSE",
    "OUT_FOR_DELIVERY",
    "DELIVERED",
    "REJECTED",
)


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


def _add_column_if_missing(inspector: sa.Inspector, table_name: str, column: sa.Column) -> None:
    if _table_exists(inspector, table_name) and not _column_exists(inspector, table_name, column.name):
        op.add_column(table_name, column)


def _create_index_if_missing(inspector: sa.Inspector, table_name: str, index_name: str, columns: list[str]) -> None:
    if _table_exists(inspector, table_name) and not _index_exists(inspector, table_name, index_name):
        op.create_index(index_name, table_name, columns, unique=False)


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
    if not _table_exists(inspector, table_name) or not _table_exists(inspector, remote_table):
        return
    if _fk_exists(inspector, table_name, fk_name):
        return
    op.create_foreign_key(fk_name, table_name, remote_table, local_cols, remote_cols)


def _drop_policy_if_exists(table_name: str, policy_name: str) -> None:
    op.execute(sa.text(f'DROP POLICY IF EXISTS "{policy_name}" ON "{table_name}"'))


def _enable_rls(table_name: str) -> None:
    op.execute(sa.text(f'ALTER TABLE "{table_name}" ENABLE ROW LEVEL SECURITY'))
    op.execute(sa.text(f'ALTER TABLE "{table_name}" FORCE ROW LEVEL SECURITY'))


def _upgrade_postgres_status_guard() -> None:
    op.execute(
        sa.text(
            """
            CREATE TABLE IF NOT EXISTS logistics_order_status_history (
                id BIGSERIAL PRIMARY KEY,
                order_id VARCHAR NOT NULL,
                from_status VARCHAR NULL,
                to_status VARCHAR NOT NULL,
                changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            )
            """
        )
    )

    op.execute(
        sa.text(
            """
            CREATE OR REPLACE FUNCTION app_normalize_logistics_order_status(raw_status TEXT)
            RETURNS TEXT
            LANGUAGE plpgsql
            AS $$
            DECLARE
                normalized TEXT;
            BEGIN
                normalized := UPPER(REPLACE(REPLACE(COALESCE(raw_status, ''), '-', '_'), ' ', '_'));
                IF normalized IN ('PENDING', 'ASSIGNED', 'NEW') THEN
                    RETURN 'PENDING_ADMIN_APPROVAL';
                ELSIF normalized IN ('APPROVED') THEN
                    RETURN 'APPROVED';
                ELSIF normalized IN ('ASSIGNED_TO_WAREHOUSE') THEN
                    RETURN 'ASSIGNED_TO_WAREHOUSE';
                ELSIF normalized IN ('OUT_FOR_DELIVERY', 'IN_TRANSIT', 'IN_PROGRESS', 'DISPATCHED') THEN
                    RETURN 'OUT_FOR_DELIVERY';
                ELSIF normalized IN ('DELIVERED', 'COMPLETED') THEN
                    RETURN 'DELIVERED';
                ELSIF normalized IN ('REJECTED', 'FAILED', 'CANCELLED', 'CANCELED') THEN
                    RETURN 'REJECTED';
                END IF;
                RETURN normalized;
            END;
            $$
            """
        )
    )

    op.execute(
        sa.text(
            """
            CREATE OR REPLACE FUNCTION app_validate_logistics_order_transition()
            RETURNS TRIGGER
            LANGUAGE plpgsql
            AS $$
            DECLARE
                old_norm TEXT;
                new_norm TEXT;
                transition_valid BOOLEAN := FALSE;
            BEGIN
                NEW.status := app_normalize_logistics_order_status(NEW.status);
                IF NEW.status IS NULL OR NEW.status = '' THEN
                    RAISE EXCEPTION 'status is required';
                END IF;

                IF TG_OP = 'INSERT' THEN
                    IF NEW.status <> 'PENDING_ADMIN_APPROVAL' THEN
                        RAISE EXCEPTION 'new orders must start in PENDING_ADMIN_APPROVAL';
                    END IF;
                    RETURN NEW;
                END IF;

                old_norm := app_normalize_logistics_order_status(OLD.status);
                new_norm := app_normalize_logistics_order_status(NEW.status);

                IF old_norm = new_norm THEN
                    RETURN NEW;
                END IF;

                transition_valid := (
                    (old_norm = 'PENDING_ADMIN_APPROVAL' AND new_norm IN ('APPROVED', 'REJECTED')) OR
                    (old_norm = 'APPROVED' AND new_norm = 'ASSIGNED_TO_WAREHOUSE') OR
                    (old_norm = 'ASSIGNED_TO_WAREHOUSE' AND new_norm = 'OUT_FOR_DELIVERY') OR
                    (old_norm = 'OUT_FOR_DELIVERY' AND new_norm = 'DELIVERED')
                );

                IF NOT transition_valid THEN
                    RAISE EXCEPTION 'Invalid logistics order status transition from % to %', old_norm, new_norm;
                END IF;

                INSERT INTO logistics_order_status_history(order_id, from_status, to_status, changed_at)
                VALUES (NEW.id, old_norm, new_norm, NOW());

                RETURN NEW;
            END;
            $$
            """
        )
    )

    op.execute(sa.text("DROP TRIGGER IF EXISTS trg_validate_logistics_order_transition ON logistics_orders"))
    op.execute(
        sa.text(
            """
            CREATE TRIGGER trg_validate_logistics_order_transition
            BEFORE INSERT OR UPDATE OF status ON logistics_orders
            FOR EACH ROW
            EXECUTE FUNCTION app_validate_logistics_order_transition()
            """
        )
    )


def _upgrade_postgres_claim_helpers_and_policies(inspector: sa.Inspector) -> None:
    op.execute(
        sa.text(
            """
            CREATE OR REPLACE FUNCTION app_claim_text(claim_name TEXT)
            RETURNS TEXT
            LANGUAGE plpgsql
            STABLE
            AS $$
            DECLARE
                claim_value TEXT;
            BEGIN
                claim_value := NULLIF(current_setting('request.jwt.claim.' || claim_name, true), '');
                IF claim_value IS NOT NULL THEN
                    RETURN claim_value;
                END IF;

                IF claim_name = 'role' THEN
                    RETURN NULLIF(current_setting('app.actor_role', true), '');
                ELSIF claim_name = 'sub' THEN
                    RETURN NULLIF(current_setting('app.auth_subject', true), '');
                ELSE
                    RETURN NULLIF(current_setting('app.actor_' || claim_name, true), '');
                END IF;
            END;
            $$
            """
        )
    )

    op.execute(
        sa.text(
            """
            CREATE OR REPLACE FUNCTION app_claim_int(claim_name TEXT)
            RETURNS INTEGER
            LANGUAGE plpgsql
            STABLE
            AS $$
            DECLARE
                claim_text TEXT;
            BEGIN
                claim_text := app_claim_text(claim_name);
                IF claim_text IS NULL OR claim_text = '' THEN
                    RETURN NULL;
                END IF;
                IF claim_text ~ '^[0-9]+$' THEN
                    RETURN claim_text::INTEGER;
                END IF;
                RETURN NULL;
            END;
            $$
            """
        )
    )

    # logistics_orders: admin global read, assignment-bound writes, and scoped role access.
    if _table_exists(inspector, "logistics_orders"):
        _enable_rls("logistics_orders")
        for policy_name in (
            "wezu_global_access",
            "wezu_tenant_access",
            "logistics_orders_select_scoped",
            "logistics_orders_insert_scoped",
            "logistics_orders_update_scoped",
        ):
            _drop_policy_if_exists("logistics_orders", policy_name)

        op.execute(
            sa.text(
                """
                CREATE POLICY logistics_orders_select_scoped ON logistics_orders
                FOR SELECT
                USING (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
                    OR (app_claim_text('role') = 'warehouse_operator' AND source_warehouse_id = app_claim_int('warehouse_id'))
                    OR (app_claim_text('role') = 'driver' AND driver_id = app_claim_int('driver_id'))
                    OR (app_claim_text('role') = 'customer' AND customer_id = app_claim_int('customer_id'))
                )
                """
            )
        )

        op.execute(
            sa.text(
                """
                CREATE POLICY logistics_orders_insert_scoped ON logistics_orders
                FOR INSERT
                WITH CHECK (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
                )
                """
            )
        )

        op.execute(
            sa.text(
                """
                CREATE POLICY logistics_orders_update_scoped ON logistics_orders
                FOR UPDATE
                USING (
                    (app_claim_text('role') = 'admin' AND assigned_admin_id = app_claim_int('admin_id'))
                    OR (app_claim_text('role') = 'warehouse_operator' AND source_warehouse_id = app_claim_int('warehouse_id'))
                    OR (app_claim_text('role') = 'driver' AND driver_id = app_claim_int('driver_id'))
                    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
                )
                WITH CHECK (
                    (app_claim_text('role') = 'admin' AND assigned_admin_id = app_claim_int('admin_id'))
                    OR (app_claim_text('role') = 'warehouse_operator' AND source_warehouse_id = app_claim_int('warehouse_id'))
                    OR (app_claim_text('role') = 'driver' AND driver_id = app_claim_int('driver_id'))
                    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
                )
                """
            )
        )

    if _table_exists(inspector, "logistics_order_batteries"):
        _enable_rls("logistics_order_batteries")
        for policy_name in (
            "wezu_global_access",
            "wezu_tenant_access",
            "logistics_order_batteries_select_scoped",
            "logistics_order_batteries_write_scoped",
        ):
            _drop_policy_if_exists("logistics_order_batteries", policy_name)

        op.execute(
            sa.text(
                """
                CREATE POLICY logistics_order_batteries_select_scoped ON logistics_order_batteries
                FOR SELECT
                USING (
                    EXISTS (
                        SELECT 1 FROM logistics_orders o
                        WHERE o.id = logistics_order_batteries.order_id
                          AND (
                            app_claim_text('role') = 'admin'
                            OR (app_claim_text('role') = 'dealer' AND o.dealer_id = app_claim_int('dealer_id'))
                            OR (app_claim_text('role') = 'warehouse_operator' AND o.source_warehouse_id = app_claim_int('warehouse_id'))
                            OR (app_claim_text('role') = 'driver' AND o.driver_id = app_claim_int('driver_id'))
                            OR (app_claim_text('role') = 'customer' AND o.customer_id = app_claim_int('customer_id'))
                          )
                    )
                )
                """
            )
        )

        op.execute(
            sa.text(
                """
                CREATE POLICY logistics_order_batteries_write_scoped ON logistics_order_batteries
                FOR ALL
                USING (app_claim_text('role') IN ('admin', 'warehouse_operator'))
                WITH CHECK (app_claim_text('role') IN ('admin', 'warehouse_operator'))
                """
            )
        )

    if _table_exists(inspector, "rentals"):
        _enable_rls("rentals")
        for policy_name in (
            "rentals_select_scoped",
            "rentals_insert_scoped",
            "rentals_update_scoped",
        ):
            _drop_policy_if_exists("rentals", policy_name)

        op.execute(
            sa.text(
                """
                CREATE POLICY rentals_select_scoped ON rentals
                FOR SELECT
                USING (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'customer' AND user_id = app_claim_int('customer_id'))
                )
                """
            )
        )

        op.execute(
            sa.text(
                """
                CREATE POLICY rentals_insert_scoped ON rentals
                FOR INSERT
                WITH CHECK (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'customer' AND user_id = app_claim_int('customer_id'))
                )
                """
            )
        )

        op.execute(
            sa.text(
                """
                CREATE POLICY rentals_update_scoped ON rentals
                FOR UPDATE
                USING (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'customer' AND user_id = app_claim_int('customer_id'))
                )
                WITH CHECK (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'customer' AND user_id = app_claim_int('customer_id'))
                )
                """
            )
        )

    for table_name in ("dealer_main_inventory_batteries", "station_inventory_batteries", "battery_custody_events"):
        if not _table_exists(inspector, table_name):
            continue
        _enable_rls(table_name)
        _drop_policy_if_exists(table_name, "wezu_global_access")
        _drop_policy_if_exists(table_name, "wezu_tenant_access")

    if _table_exists(inspector, "dealer_main_inventory_batteries"):
        _drop_policy_if_exists("dealer_main_inventory_batteries", "dealer_main_inventory_select_scoped")
        _drop_policy_if_exists("dealer_main_inventory_batteries", "dealer_main_inventory_write_scoped")
        op.execute(
            sa.text(
                """
                CREATE POLICY dealer_main_inventory_select_scoped ON dealer_main_inventory_batteries
                FOR SELECT
                USING (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
                )
                """
            )
        )
        op.execute(
            sa.text(
                """
                CREATE POLICY dealer_main_inventory_write_scoped ON dealer_main_inventory_batteries
                FOR ALL
                USING (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
                )
                WITH CHECK (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
                )
                """
            )
        )

    if _table_exists(inspector, "station_inventory_batteries"):
        _drop_policy_if_exists("station_inventory_batteries", "station_inventory_select_scoped")
        _drop_policy_if_exists("station_inventory_batteries", "station_inventory_write_scoped")
        op.execute(
            sa.text(
                """
                CREATE POLICY station_inventory_select_scoped ON station_inventory_batteries
                FOR SELECT
                USING (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'dealer' AND source_dealer_id = app_claim_int('dealer_id'))
                )
                """
            )
        )
        op.execute(
            sa.text(
                """
                CREATE POLICY station_inventory_write_scoped ON station_inventory_batteries
                FOR ALL
                USING (
                    app_claim_text('role') IN ('admin', 'dealer', 'warehouse_operator')
                )
                WITH CHECK (
                    app_claim_text('role') IN ('admin', 'dealer', 'warehouse_operator')
                )
                """
            )
        )

    if _table_exists(inspector, "battery_custody_events"):
        _drop_policy_if_exists("battery_custody_events", "battery_custody_events_select_scoped")
        _drop_policy_if_exists("battery_custody_events", "battery_custody_events_insert_scoped")
        op.execute(
            sa.text(
                """
                CREATE POLICY battery_custody_events_select_scoped ON battery_custody_events
                FOR SELECT
                USING (
                    app_claim_text('role') = 'admin'
                    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
                    OR (app_claim_text('role') = 'warehouse_operator' AND warehouse_id = app_claim_int('warehouse_id'))
                    OR (app_claim_text('role') = 'driver' AND driver_id = app_claim_int('driver_id'))
                    OR (app_claim_text('role') = 'customer' AND customer_id = app_claim_int('customer_id'))
                )
                """
            )
        )
        op.execute(
            sa.text(
                """
                CREATE POLICY battery_custody_events_insert_scoped ON battery_custody_events
                FOR INSERT
                WITH CHECK (
                    app_claim_text('role') IN ('admin', 'dealer', 'warehouse_operator', 'driver', 'customer')
                )
                """
            )
        )


def upgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)
    dialect = bind.dialect.name.lower()

    # logistics_orders canonical workflow columns
    _add_column_if_missing(inspector, "logistics_orders", sa.Column("assigned_admin_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "logistics_orders", sa.Column("warehouse_operator_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "logistics_orders", sa.Column("driver_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "logistics_orders", sa.Column("customer_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "logistics_orders", sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True))
    _add_column_if_missing(
        inspector,
        "logistics_orders",
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
    )

    inspector = sa.inspect(bind)
    _create_index_if_missing(inspector, "logistics_orders", "ix_logistics_orders_assigned_admin_id", ["assigned_admin_id"])
    _create_index_if_missing(inspector, "logistics_orders", "ix_logistics_orders_warehouse_operator_id", ["warehouse_operator_id"])
    _create_index_if_missing(inspector, "logistics_orders", "ix_logistics_orders_driver_id", ["driver_id"])
    _create_index_if_missing(inspector, "logistics_orders", "ix_logistics_orders_customer_id", ["customer_id"])
    _create_index_if_missing(inspector, "logistics_orders", "ix_logistics_orders_is_active", ["is_active"])

    inspector = sa.inspect(bind)
    _create_fk_if_missing(bind, inspector, "logistics_orders", "fk_logistics_orders_assigned_admin_id", ["assigned_admin_id"], "users", ["id"])
    _create_fk_if_missing(bind, inspector, "logistics_orders", "fk_logistics_orders_warehouse_operator_id", ["warehouse_operator_id"], "users", ["id"])
    _create_fk_if_missing(bind, inspector, "logistics_orders", "fk_logistics_orders_driver_id_users", ["driver_id"], "users", ["id"])
    _create_fk_if_missing(bind, inspector, "logistics_orders", "fk_logistics_orders_customer_id", ["customer_id"], "users", ["id"])

    # Soft delete controls
    for table_name in ("rentals", "batteries", "delivery_assignments"):
        _add_column_if_missing(inspector, table_name, sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True))
        _add_column_if_missing(
            inspector,
            table_name,
            sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
        )
        inspector = sa.inspect(bind)
        _create_index_if_missing(inspector, table_name, f"ix_{table_name}_is_active", ["is_active"])

    # Canonical audit log columns
    _add_column_if_missing(inspector, "audit_logs", sa.Column("actor_id", sa.Integer(), nullable=True))
    _add_column_if_missing(inspector, "audit_logs", sa.Column("actor_role", sa.String(), nullable=True))
    _add_column_if_missing(inspector, "audit_logs", sa.Column("target_table", sa.String(), nullable=True))
    _add_column_if_missing(inspector, "audit_logs", sa.Column("old_state", sa.JSON(), nullable=True))
    _add_column_if_missing(inspector, "audit_logs", sa.Column("new_state", sa.JSON(), nullable=True))
    inspector = sa.inspect(bind)
    _create_index_if_missing(inspector, "audit_logs", "ix_audit_logs_actor_id", ["actor_id"])
    _create_index_if_missing(inspector, "audit_logs", "ix_audit_logs_actor_role", ["actor_role"])
    _create_index_if_missing(inspector, "audit_logs", "ix_audit_logs_target_table", ["target_table"])

    # New custody + inventory domain tables
    if not _table_exists(inspector, "dealer_main_inventory_batteries"):
        op.create_table(
            "dealer_main_inventory_batteries",
            sa.Column("id", sa.Integer(), primary_key=True),
            sa.Column("tenant_id", sa.Integer(), nullable=True),
            sa.Column("dealer_id", sa.Integer(), nullable=False),
            sa.Column("battery_id", sa.String(), nullable=False),
            sa.Column("battery_pk", sa.Integer(), nullable=True),
            sa.Column("status", sa.String(), nullable=False, server_default="IN_STOCK"),
            sa.Column("assigned_station_id", sa.Integer(), nullable=True),
            sa.Column("station_assignment_status", sa.String(), nullable=True),
            sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
            sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
            sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
            sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
            sa.ForeignKeyConstraint(["tenant_id"], ["tenants.id"]),
            sa.ForeignKeyConstraint(["dealer_id"], ["dealer_profiles.id"]),
            sa.ForeignKeyConstraint(["battery_pk"], ["batteries.id"]),
            sa.ForeignKeyConstraint(["assigned_station_id"], ["stations.id"]),
            sa.UniqueConstraint("dealer_id", "battery_id", name="uq_dealer_main_inventory_battery"),
        )

    inspector = sa.inspect(bind)
    if not _table_exists(inspector, "station_inventory_batteries"):
        op.create_table(
            "station_inventory_batteries",
            sa.Column("id", sa.Integer(), primary_key=True),
            sa.Column("tenant_id", sa.Integer(), nullable=True),
            sa.Column("station_id", sa.Integer(), nullable=False),
            sa.Column("source_dealer_id", sa.Integer(), nullable=True),
            sa.Column("battery_id", sa.String(), nullable=False),
            sa.Column("battery_pk", sa.Integer(), nullable=True),
            sa.Column("status", sa.String(), nullable=False, server_default="IN_STOCK"),
            sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
            sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
            sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
            sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
            sa.ForeignKeyConstraint(["tenant_id"], ["tenants.id"]),
            sa.ForeignKeyConstraint(["station_id"], ["stations.id"]),
            sa.ForeignKeyConstraint(["source_dealer_id"], ["dealer_profiles.id"]),
            sa.ForeignKeyConstraint(["battery_pk"], ["batteries.id"]),
            sa.UniqueConstraint("station_id", "battery_id", name="uq_station_inventory_battery"),
        )

    inspector = sa.inspect(bind)
    if not _table_exists(inspector, "battery_custody_events"):
        op.create_table(
            "battery_custody_events",
            sa.Column("id", sa.Integer(), primary_key=True),
            sa.Column("tenant_id", sa.Integer(), nullable=True),
            sa.Column("order_id", sa.String(), nullable=True),
            sa.Column("rental_id", sa.Integer(), nullable=True),
            sa.Column("battery_id", sa.String(), nullable=False),
            sa.Column("battery_pk", sa.Integer(), nullable=True),
            sa.Column("event_type", sa.String(), nullable=False),
            sa.Column("actor_id", sa.Integer(), nullable=True),
            sa.Column("actor_role", sa.String(), nullable=True),
            sa.Column("dealer_id", sa.Integer(), nullable=True),
            sa.Column("warehouse_id", sa.Integer(), nullable=True),
            sa.Column("admin_id", sa.Integer(), nullable=True),
            sa.Column("warehouse_operator_id", sa.Integer(), nullable=True),
            sa.Column("driver_id", sa.Integer(), nullable=True),
            sa.Column("station_id", sa.Integer(), nullable=True),
            sa.Column("customer_id", sa.Integer(), nullable=True),
            sa.Column("from_location_type", sa.String(), nullable=True),
            sa.Column("from_location_id", sa.Integer(), nullable=True),
            sa.Column("to_location_type", sa.String(), nullable=True),
            sa.Column("to_location_id", sa.Integer(), nullable=True),
            sa.Column("metadata_json", sa.JSON(), nullable=True),
            sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("CURRENT_TIMESTAMP")),
            sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.text("true")),
            sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
            sa.ForeignKeyConstraint(["tenant_id"], ["tenants.id"]),
            sa.ForeignKeyConstraint(["order_id"], ["logistics_orders.id"]),
            sa.ForeignKeyConstraint(["rental_id"], ["rentals.id"]),
            sa.ForeignKeyConstraint(["battery_pk"], ["batteries.id"]),
            sa.ForeignKeyConstraint(["actor_id"], ["users.id"]),
            sa.ForeignKeyConstraint(["dealer_id"], ["dealer_profiles.id"]),
            sa.ForeignKeyConstraint(["warehouse_id"], ["warehouses.id"]),
            sa.ForeignKeyConstraint(["admin_id"], ["users.id"]),
            sa.ForeignKeyConstraint(["warehouse_operator_id"], ["users.id"]),
            sa.ForeignKeyConstraint(["driver_id"], ["users.id"]),
            sa.ForeignKeyConstraint(["station_id"], ["stations.id"]),
            sa.ForeignKeyConstraint(["customer_id"], ["users.id"]),
        )

    inspector = sa.inspect(bind)
    for table_name, idx_columns in (
        ("dealer_main_inventory_batteries", ["tenant_id"]),
        ("dealer_main_inventory_batteries", ["dealer_id"]),
        ("dealer_main_inventory_batteries", ["battery_id"]),
        ("dealer_main_inventory_batteries", ["status"]),
        ("dealer_main_inventory_batteries", ["is_active"]),
        ("station_inventory_batteries", ["tenant_id"]),
        ("station_inventory_batteries", ["station_id"]),
        ("station_inventory_batteries", ["battery_id"]),
        ("station_inventory_batteries", ["status"]),
        ("station_inventory_batteries", ["is_active"]),
        ("battery_custody_events", ["tenant_id"]),
        ("battery_custody_events", ["order_id"]),
        ("battery_custody_events", ["rental_id"]),
        ("battery_custody_events", ["battery_id"]),
        ("battery_custody_events", ["event_type"]),
        ("battery_custody_events", ["actor_id"]),
        ("battery_custody_events", ["dealer_id"]),
        ("battery_custody_events", ["warehouse_id"]),
        ("battery_custody_events", ["driver_id"]),
        ("battery_custody_events", ["station_id"]),
        ("battery_custody_events", ["customer_id"]),
        ("battery_custody_events", ["occurred_at"]),
    ):
        idx_name = f"ix_{table_name}_{'_'.join(idx_columns)}"
        _create_index_if_missing(inspector, table_name, idx_name, idx_columns)

    if _table_exists(inspector, "logistics_orders") and _column_exists(inspector, "logistics_orders", "status"):
        op.execute(
            sa.text(
                """
                UPDATE logistics_orders
                SET status = CASE
                    WHEN UPPER(REPLACE(REPLACE(COALESCE(status, ''), '-', '_'), ' ', '_')) IN ('PENDING', 'ASSIGNED', 'NEW') THEN 'PENDING_ADMIN_APPROVAL'
                    WHEN UPPER(REPLACE(REPLACE(COALESCE(status, ''), '-', '_'), ' ', '_')) IN ('APPROVED') THEN 'APPROVED'
                    WHEN UPPER(REPLACE(REPLACE(COALESCE(status, ''), '-', '_'), ' ', '_')) IN ('ASSIGNED_TO_WAREHOUSE') THEN 'ASSIGNED_TO_WAREHOUSE'
                    WHEN UPPER(REPLACE(REPLACE(COALESCE(status, ''), '-', '_'), ' ', '_')) IN ('OUT_FOR_DELIVERY', 'IN_TRANSIT', 'IN_PROGRESS', 'DISPATCHED') THEN 'OUT_FOR_DELIVERY'
                    WHEN UPPER(REPLACE(REPLACE(COALESCE(status, ''), '-', '_'), ' ', '_')) IN ('DELIVERED', 'COMPLETED') THEN 'DELIVERED'
                    WHEN UPPER(REPLACE(REPLACE(COALESCE(status, ''), '-', '_'), ' ', '_')) IN ('FAILED', 'REJECTED', 'CANCELLED', 'CANCELED') THEN 'REJECTED'
                    ELSE 'PENDING_ADMIN_APPROVAL'
                END
                """
            )
        )

        if dialect == "postgresql":
            op.execute(sa.text("ALTER TABLE logistics_orders ALTER COLUMN status SET DEFAULT 'PENDING_ADMIN_APPROVAL'"))
            op.execute(sa.text("ALTER TABLE logistics_orders DROP CONSTRAINT IF EXISTS ck_logistics_orders_status_canonical"))
            op.execute(
                sa.text(
                    """
                    ALTER TABLE logistics_orders
                    ADD CONSTRAINT ck_logistics_orders_status_canonical
                    CHECK (status IN (
                        'PENDING_ADMIN_APPROVAL',
                        'APPROVED',
                        'ASSIGNED_TO_WAREHOUSE',
                        'OUT_FOR_DELIVERY',
                        'DELIVERED',
                        'REJECTED'
                    ))
                    """
                )
            )

    if dialect == "postgresql":
        _upgrade_postgres_status_guard()
        inspector = sa.inspect(bind)
        _upgrade_postgres_claim_helpers_and_policies(inspector)


def downgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)
    dialect = bind.dialect.name.lower()

    if dialect == "postgresql":
        op.execute(sa.text("DROP TRIGGER IF EXISTS trg_validate_logistics_order_transition ON logistics_orders"))
        op.execute(sa.text("DROP FUNCTION IF EXISTS app_validate_logistics_order_transition()"))
        op.execute(sa.text("DROP FUNCTION IF EXISTS app_normalize_logistics_order_status(TEXT)"))
        op.execute(sa.text("DROP TABLE IF EXISTS logistics_order_status_history"))
        op.execute(sa.text("DROP FUNCTION IF EXISTS app_claim_int(TEXT)"))
        op.execute(sa.text("DROP FUNCTION IF EXISTS app_claim_text(TEXT)"))

    for table_name in ("battery_custody_events", "station_inventory_batteries", "dealer_main_inventory_batteries"):
        if _table_exists(inspector, table_name):
            op.drop_table(table_name)

    if _table_exists(inspector, "audit_logs"):
        for column in ("new_state", "old_state", "target_table", "actor_role", "actor_id"):
            if _column_exists(inspector, "audit_logs", column):
                op.drop_column("audit_logs", column)

    for table_name in ("delivery_assignments", "batteries", "rentals", "logistics_orders"):
        if _table_exists(inspector, table_name):
            if _column_exists(inspector, table_name, "deleted_at"):
                op.drop_column(table_name, "deleted_at")
            if _column_exists(inspector, table_name, "is_active"):
                op.drop_column(table_name, "is_active")

    if _table_exists(inspector, "logistics_orders"):
        for column in ("customer_id", "driver_id", "warehouse_operator_id", "assigned_admin_id"):
            if _column_exists(inspector, "logistics_orders", column):
                op.drop_column("logistics_orders", column)
