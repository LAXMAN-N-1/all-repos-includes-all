"""wave 3: convert logistics_orders.id (and dependent FK columns) INT -> VARCHAR

Revision ID: b3c4d5e6f7a8
Revises: a1b2c3d4e5f8
Create Date: 2026-04-20 00:00:00.000000

URGENT production fix. The application generates order identifiers of the
form ``ORD-XXXXXX`` (see ``app.models.order.Order.id: str``) but the DB
column ``logistics_orders.id`` was originally created as INTEGER/SERIAL in
``f1e2d3c4b5a6_unified_new_tables``. First ``POST /api/v1/orders/`` after
deploying the new code path crashed with::

    psycopg2.errors.InvalidTextRepresentation:
    invalid input syntax for type integer: "ORD-6D0B75"
    LINE 3: WHERE logistics_orders.id = 'ORD-6D0B75'

This migration realigns the DB with the ORM by converting:

- ``logistics_orders.id``                INTEGER -> VARCHAR (PK)
- ``logistics_order_batteries.order_id`` INTEGER -> VARCHAR (FK CASCADE)
- ``logistics_order_batteries.battery_id`` INTEGER -> VARCHAR
    (The business id in the model is a string like ``BAT-1001``; the
    INTEGER FK to ``batteries.id`` is carried separately by
    ``battery_pk`` which ``a1b2c3d4e5f8`` already introduced.)
- ``manifests.order_id``                 INTEGER -> VARCHAR (FK nullable)
- ``order_realtime_outbox.order_id``     INTEGER -> VARCHAR (no DB-side FK)

Procedure
---------

1. Detect current type via ``information_schema.columns``; skip whole run
   if ``logistics_orders.id`` is already a string type.
2. Drop FK constraints referencing ``logistics_orders.id`` (names are
   looked up from ``pg_constraint`` so they match whatever SQLAlchemy
   auto-generated at create_table time).
3. Drop the existing SERIAL default and orphan the sequence.
4. Cast each column via ``ALTER COLUMN TYPE VARCHAR USING col::VARCHAR``.
5. Re-add FK constraints with explicit names and matching ON DELETE
   semantics (CASCADE for logistics_order_batteries, default for manifests).
6. ``DROP SEQUENCE IF EXISTS logistics_orders_id_seq CASCADE`` to clean
   up the no-longer-owned sequence.

Idempotency: the whole body runs inside a DO block that short-circuits if
the PK column is already a text type, so re-running is safe.

PostgreSQL-only. SQLite dev DBs rely on ``SQLModel.metadata.create_all``
and already get the column types from the ORM definitions.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "b3c4d5e6f7a8"
down_revision: Union[str, None] = "a1b2c3d4e5f8"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


_UPGRADE_SQL = r"""
DO $$
DECLARE
    id_type text;
    fk_rec RECORD;
BEGIN
    -- Bail if the source table does not exist yet (fresh DB, nothing to do).
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_name = 'logistics_orders'
    ) THEN
        RETURN;
    END IF;

    SELECT data_type INTO id_type
    FROM information_schema.columns
    WHERE table_name = 'logistics_orders' AND column_name = 'id';

    -- Already converted? Nothing to do.
    IF id_type IN ('character varying', 'text') THEN
        RETURN;
    END IF;

    -- 1a. Drop every FK constraint that currently references logistics_orders.id.
    --     We look them up dynamically so whatever name SQLAlchemy auto-generated
    --     (e.g. logistics_order_batteries_order_id_fkey) is handled correctly.
    FOR fk_rec IN
        SELECT c.conname, cl.relname AS table_name
        FROM pg_constraint c
        JOIN pg_class cl ON cl.oid = c.conrelid
        JOIN pg_class rcl ON rcl.oid = c.confrelid
        WHERE c.contype = 'f' AND rcl.relname = 'logistics_orders'
    LOOP
        EXECUTE format('ALTER TABLE %I DROP CONSTRAINT %I',
                       fk_rec.table_name, fk_rec.conname);
    END LOOP;

    -- 1b. Drop any FK *on* the dependent columns that would block a type
    --     change. The migration created logistics_order_batteries.battery_id
    --     with FK -> batteries.id (INTEGER), but the model no longer declares
    --     that FK — it carries the INT FK to batteries separately on
    --     battery_pk, leaving battery_id free to hold BAT-XXXX strings. Same
    --     principle for any future cruft FK on the columns we retype.
    FOR fk_rec IN
        SELECT c.conname, cl.relname AS table_name
        FROM pg_constraint c
        JOIN pg_class cl ON cl.oid = c.conrelid
        JOIN pg_attribute a
            ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
        WHERE c.contype = 'f'
          AND (
              (cl.relname = 'logistics_order_batteries'
                   AND a.attname IN ('order_id', 'battery_id'))
              OR (cl.relname = 'manifests' AND a.attname = 'order_id')
              OR (cl.relname = 'order_realtime_outbox' AND a.attname = 'order_id')
          )
    LOOP
        EXECUTE format('ALTER TABLE %I DROP CONSTRAINT %I',
                       fk_rec.table_name, fk_rec.conname);
    END LOOP;

    -- 2. Drop the SERIAL default (the sequence becomes orphaned; dropped below).
    ALTER TABLE logistics_orders ALTER COLUMN id DROP DEFAULT;

    -- 3. Cast columns to VARCHAR. USING clauses make the text cast explicit.
    ALTER TABLE logistics_orders
        ALTER COLUMN id TYPE VARCHAR USING id::VARCHAR;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'logistics_order_batteries' AND column_name = 'order_id'
    ) THEN
        ALTER TABLE logistics_order_batteries
            ALTER COLUMN order_id TYPE VARCHAR USING order_id::VARCHAR;
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'logistics_order_batteries' AND column_name = 'battery_id'
    ) THEN
        ALTER TABLE logistics_order_batteries
            ALTER COLUMN battery_id TYPE VARCHAR USING battery_id::VARCHAR;
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'manifests' AND column_name = 'order_id'
    ) THEN
        ALTER TABLE manifests
            ALTER COLUMN order_id TYPE VARCHAR USING order_id::VARCHAR;
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'order_realtime_outbox' AND column_name = 'order_id'
    ) THEN
        ALTER TABLE order_realtime_outbox
            ALTER COLUMN order_id TYPE VARCHAR USING order_id::VARCHAR;
    END IF;

    -- 4. Re-add FK constraints with explicit names, preserving CASCADE semantics
    --    for logistics_order_batteries (see f1e2d3c4b5a6 line 80).
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'logistics_order_batteries' AND column_name = 'order_id'
    ) AND NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_logistics_order_batteries_order_id'
    ) THEN
        ALTER TABLE logistics_order_batteries
            ADD CONSTRAINT fk_logistics_order_batteries_order_id
            FOREIGN KEY (order_id) REFERENCES logistics_orders(id) ON DELETE CASCADE;
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'manifests' AND column_name = 'order_id'
    ) AND NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_manifests_order_id'
    ) THEN
        ALTER TABLE manifests
            ADD CONSTRAINT fk_manifests_order_id
            FOREIGN KEY (order_id) REFERENCES logistics_orders(id);
    END IF;

    -- 5. Drop the orphan sequence (was owned by the old SERIAL column).
    --    CASCADE is safe here — the sequence has no other dependents now.
    IF EXISTS (
        SELECT 1 FROM pg_class
        WHERE relkind = 'S' AND relname = 'logistics_orders_id_seq'
    ) THEN
        DROP SEQUENCE logistics_orders_id_seq CASCADE;
    END IF;
END $$;
"""


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name != "postgresql":
        # SQLite dev DBs materialize via SQLModel.metadata.create_all with the
        # correct str PK type directly — nothing to fix here.
        return
    op.execute(sa.text(_UPGRADE_SQL))


def downgrade() -> None:
    # Intentional no-op. Reverting VARCHAR -> INTEGER would require every
    # row's id to be castable to int, which is impossible for the
    # ``ORD-XXXXXX`` identifiers that now populate this table. If a true
    # rollback is ever needed it must be preceded by an application-layer
    # migration to purely-numeric ids.
    pass
