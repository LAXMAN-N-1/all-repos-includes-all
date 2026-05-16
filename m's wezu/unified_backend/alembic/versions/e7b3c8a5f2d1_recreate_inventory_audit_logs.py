"""recreate_missing_model_tables

Revision ID: e7b3c8a5f2d1
Revises: 0ccc880381a2
Create Date: 2026-04-15 07:30:00.000000

Re-creates three tables that live SQLModel ``table=True`` models still use
but that are missing from production schemas:

1. ``inventory_audit_logs`` — actively DROPPED by eb06e42014cb's legacy
   sweep, yet referenced by ``app.models.inventory_audit.InventoryAuditLog``
   and endpoints in ``app/api/admin/audit_trails.py`` /
   ``app/api/v1/inventory.py``. Caused 500s on
   ``GET /api/v1/admin/audit-trails/stats`` with
   ``psycopg2.errors.UndefinedTable``.

2. ``telemetics_data`` — also DROPPED by eb06e42014cb and never re-created
   under a new name; still referenced by
   ``app.models.telematics.TelemeticsData`` and
   ``app.services.telematics_ingest_service.TelematicsIngestService``.
   Every telemetry ingest would 500 without this.

3. ``demand_forecasts`` — never present in any create-table migration;
   referenced by ``app.models.analytics.DemandForecast`` and
   ``app.services.forecasting_service``. Previously only materialised via
   ``create_all()``; when ``AUTO_CREATE_TABLES`` is disabled in prod it
   silently doesn't exist.

All DDL uses IF NOT EXISTS so the migration is fully idempotent and safe
to run against any production DB state (fresh, post-consolidation, or
partially-migrated).
"""
from typing import Union, Sequence

from alembic import op
import sqlalchemy as sa


revision: str = "e7b3c8a5f2d1"
down_revision: Union[str, None] = "0ccc880381a2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


_STATEMENTS: list[str] = [
    # ── inventory_audit_logs ──────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS inventory_audit_logs (
        id SERIAL PRIMARY KEY,
        battery_id INTEGER NOT NULL REFERENCES batteries(id),
        action_type VARCHAR NOT NULL,
        from_location_type VARCHAR,
        from_location_id INTEGER,
        to_location_type VARCHAR,
        to_location_id INTEGER,
        actor_id INTEGER REFERENCES users(id),
        notes TEXT,
        timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_inventory_audit_logs_battery_id ON inventory_audit_logs (battery_id)",
    "CREATE INDEX IF NOT EXISTS ix_inventory_audit_logs_action_type ON inventory_audit_logs (action_type)",
    "CREATE INDEX IF NOT EXISTS ix_inventory_audit_logs_timestamp ON inventory_audit_logs (timestamp)",

    # ── telemetics_data ───────────────────────────────────────────────────
    # Composite PK (timestamp, battery_id) matches the SQLModel so that a
    # future TimescaleDB ``create_hypertable`` call remains valid.
    """
    CREATE TABLE IF NOT EXISTS telemetics_data (
        timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
        battery_id INTEGER NOT NULL REFERENCES batteries(id),
        voltage DOUBLE PRECISION NOT NULL DEFAULT 0,
        current DOUBLE PRECISION NOT NULL DEFAULT 0,
        temperature DOUBLE PRECISION NOT NULL DEFAULT 0,
        soc DOUBLE PRECISION NOT NULL DEFAULT 0,
        soh DOUBLE PRECISION NOT NULL DEFAULT 100,
        gps_latitude DOUBLE PRECISION,
        gps_longitude DOUBLE PRECISION,
        gps_altitude DOUBLE PRECISION,
        gps_speed DOUBLE PRECISION,
        error_codes JSONB,
        raw_payload JSONB,
        received_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (timestamp, battery_id)
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_telemetics_data_battery_id ON telemetics_data (battery_id)",

    # ── demand_forecasts ──────────────────────────────────────────────────
    """
    CREATE TABLE IF NOT EXISTS demand_forecasts (
        id SERIAL PRIMARY KEY,
        forecast_type VARCHAR NOT NULL,
        entity_id INTEGER,
        entity_name VARCHAR NOT NULL,
        forecast_date DATE NOT NULL,
        forecast_hour INTEGER,
        predicted_rentals INTEGER NOT NULL DEFAULT 0,
        predicted_swaps INTEGER NOT NULL DEFAULT 0,
        predicted_purchases INTEGER NOT NULL DEFAULT 0,
        confidence_level DOUBLE PRECISION NOT NULL DEFAULT 0.95,
        lower_bound INTEGER NOT NULL DEFAULT 0,
        upper_bound INTEGER NOT NULL DEFAULT 0,
        actual_rentals INTEGER,
        actual_swaps INTEGER,
        actual_purchases INTEGER,
        forecast_accuracy DOUBLE PRECISION,
        model_version VARCHAR NOT NULL DEFAULT 'v1.0',
        model_features JSONB,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """,
    "CREATE INDEX IF NOT EXISTS ix_demand_forecasts_forecast_date ON demand_forecasts (forecast_date)",
    "CREATE INDEX IF NOT EXISTS ix_demand_forecasts_entity ON demand_forecasts (forecast_type, entity_id)",
]


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name != "postgresql":
        # SQLite/others: SQLModel.metadata.create_all covers dev DBs.
        return
    for stmt in _STATEMENTS:
        op.execute(sa.text(stmt))


def downgrade() -> None:
    # Intentional no-op: dropping these tables would re-introduce the
    # runtime 500s this migration exists to fix. If a rollback is truly
    # required it should be done manually after confirming code no longer
    # references InventoryAuditLog / TelemeticsData / DemandForecast.
    pass
