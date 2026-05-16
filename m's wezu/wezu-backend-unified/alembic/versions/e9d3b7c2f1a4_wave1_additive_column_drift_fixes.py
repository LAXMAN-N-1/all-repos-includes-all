"""wave1_additive_column_drift_fixes

Revision ID: e9d3b7c2f1a4
Revises: c7a2e4f1d9b8
Create Date: 2026-04-19 00:00:00.000000

Wave 1 of the schema-drift remediation sweep that followed the
2026-04-15 startup drift audit. Adds columns that are purely additive —
they are declared on live SQLModels but absent from every existing
migration, and there is no name/type conflict with an existing column.

Tables & columns added
----------------------

1. ``passkey_credentials`` (5 cols)
   Model: ``app.models.passkey.PasskeyCredential``
   - credential_backed_up  BOOLEAN  NOT NULL DEFAULT FALSE
   - passkey_name          VARCHAR  NULL
   - is_active             BOOLEAN  NOT NULL DEFAULT TRUE
   - revoked_at            TIMESTAMP NULL
   - updated_at            TIMESTAMP NOT NULL DEFAULT now()

2. ``payment_methods`` (3 cols)
   Model: ``app.models.payment_method.PaymentMethod``
   - brand        VARCHAR   NULL
   - status       VARCHAR   NOT NULL DEFAULT 'active'
   - updated_at   TIMESTAMP NOT NULL DEFAULT now()

3. ``inventory_transfers`` (5 cols)
   Model: ``app.models.inventory.InventoryTransfer``
   - from_location_type  VARCHAR   NOT NULL DEFAULT 'warehouse'
   - to_location_type    VARCHAR   NOT NULL DEFAULT 'station'
   - driver_id           INTEGER   NULL (FK driver_profiles.id)
   - items               TEXT      NOT NULL DEFAULT '[]'
   - completed_at        TIMESTAMP NULL

Explicitly deferred (Wave 2 / 3)
--------------------------------

These HIGH-severity drifts are NOT fixed here because they require either
a column rename + data backfill or a structural type change (PK/FK type
mismatch between SQLModel and migration DDL):

- logistics_orders, logistics_order_batteries, manifests, manifest_items,
  inventory_transfer_items: ``id`` / ``battery_id`` are Integer in the
  migrations but String in the models (e.g. ``ORD-XXXXXX`` / ``BAT-1001``).
  Fixing these requires a data migration, FK retarget, and an app freeze.
- idempotency_keys, passkey_challenges, station_daily_metrics,
  analytics_activity_events, analytics_report_jobs, notification_outbox,
  stock_discrepancies, payment_methods.(method_type|provider_token|
  metadata_json), passkey_credentials.credential_device_type: column
  renames where the migration uses one name and the model uses another.
  Wave 2 will either add ``sa_column=sa.Column("db_name", ...)`` overrides
  in the models (no DB change) or add/backfill/drop in a careful sequence.
- inventory_transfers.{from,to}_location_id: non-nullable polymorphic
  location pointers. Requires a product decision on whether to unify the
  warehouse/station split (and a backfill strategy).

Idempotency
-----------

Every statement uses ``ADD COLUMN IF NOT EXISTS`` so this migration is
safe to re-run against any DB state. PostgreSQL-only — SQLite/dev DBs
continue to rely on ``SQLModel.metadata.create_all`` via
``AUTO_CREATE_TABLES``.
"""
from typing import Union, Sequence

from alembic import op
import sqlalchemy as sa


revision: str = "e9d3b7c2f1a4"
down_revision: Union[str, None] = "c7a2e4f1d9b8"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


# Each statement is an independent ``ALTER TABLE ... ADD COLUMN IF NOT EXISTS``.
# Ordered by table for readability; order doesn't matter for correctness because
# there are no cross-column dependencies inside this migration.
_STATEMENTS: list[str] = [
    # ── passkey_credentials ───────────────────────────────────────────────
    "ALTER TABLE passkey_credentials ADD COLUMN IF NOT EXISTS credential_backed_up BOOLEAN NOT NULL DEFAULT FALSE",
    "ALTER TABLE passkey_credentials ADD COLUMN IF NOT EXISTS passkey_name VARCHAR",
    "ALTER TABLE passkey_credentials ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE",
    "ALTER TABLE passkey_credentials ADD COLUMN IF NOT EXISTS revoked_at TIMESTAMP",
    "ALTER TABLE passkey_credentials ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT now()",
    "CREATE INDEX IF NOT EXISTS ix_passkey_credentials_is_active ON passkey_credentials (is_active)",

    # ── payment_methods ───────────────────────────────────────────────────
    "ALTER TABLE payment_methods ADD COLUMN IF NOT EXISTS brand VARCHAR",
    "ALTER TABLE payment_methods ADD COLUMN IF NOT EXISTS status VARCHAR NOT NULL DEFAULT 'active'",
    "ALTER TABLE payment_methods ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT now()",
    "CREATE INDEX IF NOT EXISTS ix_payment_methods_status ON payment_methods (status)",

    # ── inventory_transfers ───────────────────────────────────────────────
    # Polymorphic location-type columns live ALONGSIDE the existing
    # from_warehouse_id / to_warehouse_id / from_station_id / to_station_id
    # split columns. Adding them additively here is safe; the corresponding
    # non-nullable from_location_id / to_location_id are intentionally
    # deferred to Wave 2.
    "ALTER TABLE inventory_transfers ADD COLUMN IF NOT EXISTS from_location_type VARCHAR NOT NULL DEFAULT 'warehouse'",
    "ALTER TABLE inventory_transfers ADD COLUMN IF NOT EXISTS to_location_type VARCHAR NOT NULL DEFAULT 'station'",
    "ALTER TABLE inventory_transfers ADD COLUMN IF NOT EXISTS driver_id INTEGER",
    "ALTER TABLE inventory_transfers ADD COLUMN IF NOT EXISTS items TEXT NOT NULL DEFAULT '[]'",
    "ALTER TABLE inventory_transfers ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP",
]


# The driver_id FK is added in a separate idempotent DO-block so the migration
# stays re-runnable: a plain ``ADD CONSTRAINT`` would error on the second run.
_FK_STATEMENTS: list[str] = [
    """
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'fk_inventory_transfers_driver_id'
        ) THEN
            ALTER TABLE inventory_transfers
                ADD CONSTRAINT fk_inventory_transfers_driver_id
                FOREIGN KEY (driver_id) REFERENCES driver_profiles(id);
        END IF;
    END $$;
    """,
]


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name != "postgresql":
        # SQLite/dev: SQLModel.metadata.create_all handles these.
        return

    for stmt in _STATEMENTS:
        op.execute(sa.text(stmt))

    for stmt in _FK_STATEMENTS:
        op.execute(sa.text(stmt))


def downgrade() -> None:
    # Intentional no-op. Dropping these columns would reinstate the
    # UndefinedColumn errors this migration exists to prevent. If a true
    # rollback is needed it must be done manually after confirming the
    # application no longer reads the affected SQLModel fields.
    pass
