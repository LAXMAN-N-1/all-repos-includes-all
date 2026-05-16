-- Canonical delivery/rental role-scoped RLS and claim helpers.
-- Mirrors Alembic revision: 2c4d6e8f0a1b

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
$$;

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
$$;

ALTER TABLE IF EXISTS logistics_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS logistics_orders FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS wezu_global_access ON logistics_orders;
DROP POLICY IF EXISTS wezu_tenant_access ON logistics_orders;
DROP POLICY IF EXISTS logistics_orders_select_scoped ON logistics_orders;
DROP POLICY IF EXISTS logistics_orders_insert_scoped ON logistics_orders;
DROP POLICY IF EXISTS logistics_orders_update_scoped ON logistics_orders;

CREATE POLICY logistics_orders_select_scoped ON logistics_orders
FOR SELECT
USING (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
    OR (app_claim_text('role') = 'warehouse_operator' AND source_warehouse_id = app_claim_int('warehouse_id'))
    OR (app_claim_text('role') = 'driver' AND driver_id = app_claim_int('driver_id'))
    OR (app_claim_text('role') = 'customer' AND customer_id = app_claim_int('customer_id'))
);

CREATE POLICY logistics_orders_insert_scoped ON logistics_orders
FOR INSERT
WITH CHECK (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
);

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
);

ALTER TABLE IF EXISTS logistics_order_batteries ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS logistics_order_batteries FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS wezu_global_access ON logistics_order_batteries;
DROP POLICY IF EXISTS wezu_tenant_access ON logistics_order_batteries;
DROP POLICY IF EXISTS logistics_order_batteries_select_scoped ON logistics_order_batteries;
DROP POLICY IF EXISTS logistics_order_batteries_write_scoped ON logistics_order_batteries;

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
);

CREATE POLICY logistics_order_batteries_write_scoped ON logistics_order_batteries
FOR ALL
USING (app_claim_text('role') IN ('admin', 'warehouse_operator'))
WITH CHECK (app_claim_text('role') IN ('admin', 'warehouse_operator'));

ALTER TABLE IF EXISTS rentals ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS rentals FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS rentals_select_scoped ON rentals;
DROP POLICY IF EXISTS rentals_insert_scoped ON rentals;
DROP POLICY IF EXISTS rentals_update_scoped ON rentals;

CREATE POLICY rentals_select_scoped ON rentals
FOR SELECT
USING (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'customer' AND user_id = app_claim_int('customer_id'))
);

CREATE POLICY rentals_insert_scoped ON rentals
FOR INSERT
WITH CHECK (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'customer' AND user_id = app_claim_int('customer_id'))
);

CREATE POLICY rentals_update_scoped ON rentals
FOR UPDATE
USING (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'customer' AND user_id = app_claim_int('customer_id'))
)
WITH CHECK (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'customer' AND user_id = app_claim_int('customer_id'))
);

ALTER TABLE IF EXISTS dealer_main_inventory_batteries ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS dealer_main_inventory_batteries FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS wezu_global_access ON dealer_main_inventory_batteries;
DROP POLICY IF EXISTS wezu_tenant_access ON dealer_main_inventory_batteries;
DROP POLICY IF EXISTS dealer_main_inventory_select_scoped ON dealer_main_inventory_batteries;
DROP POLICY IF EXISTS dealer_main_inventory_write_scoped ON dealer_main_inventory_batteries;

CREATE POLICY dealer_main_inventory_select_scoped ON dealer_main_inventory_batteries
FOR SELECT
USING (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
);

CREATE POLICY dealer_main_inventory_write_scoped ON dealer_main_inventory_batteries
FOR ALL
USING (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
)
WITH CHECK (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
);

ALTER TABLE IF EXISTS station_inventory_batteries ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS station_inventory_batteries FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS wezu_global_access ON station_inventory_batteries;
DROP POLICY IF EXISTS wezu_tenant_access ON station_inventory_batteries;
DROP POLICY IF EXISTS station_inventory_select_scoped ON station_inventory_batteries;
DROP POLICY IF EXISTS station_inventory_write_scoped ON station_inventory_batteries;

CREATE POLICY station_inventory_select_scoped ON station_inventory_batteries
FOR SELECT
USING (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'dealer' AND source_dealer_id = app_claim_int('dealer_id'))
);

CREATE POLICY station_inventory_write_scoped ON station_inventory_batteries
FOR ALL
USING (app_claim_text('role') IN ('admin', 'dealer', 'warehouse_operator'))
WITH CHECK (app_claim_text('role') IN ('admin', 'dealer', 'warehouse_operator'));

ALTER TABLE IF EXISTS battery_custody_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS battery_custody_events FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS wezu_global_access ON battery_custody_events;
DROP POLICY IF EXISTS wezu_tenant_access ON battery_custody_events;
DROP POLICY IF EXISTS battery_custody_events_select_scoped ON battery_custody_events;
DROP POLICY IF EXISTS battery_custody_events_insert_scoped ON battery_custody_events;

CREATE POLICY battery_custody_events_select_scoped ON battery_custody_events
FOR SELECT
USING (
    app_claim_text('role') = 'admin'
    OR (app_claim_text('role') = 'dealer' AND dealer_id = app_claim_int('dealer_id'))
    OR (app_claim_text('role') = 'warehouse_operator' AND warehouse_id = app_claim_int('warehouse_id'))
    OR (app_claim_text('role') = 'driver' AND driver_id = app_claim_int('driver_id'))
    OR (app_claim_text('role') = 'customer' AND customer_id = app_claim_int('customer_id'))
);

CREATE POLICY battery_custody_events_insert_scoped ON battery_custody_events
FOR INSERT
WITH CHECK (app_claim_text('role') IN ('admin', 'dealer', 'warehouse_operator', 'driver', 'customer'));
