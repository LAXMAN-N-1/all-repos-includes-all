"""wave 4: remaining INT -> VARCHAR drifts (battery_id / manifest id chains)

Revision ID: c4d5e6f7a8b9
Revises: b3c4d5e6f7a8
Create Date: 2026-04-20 01:00:00.000000

Immediately after wave 3 unblocked POST /api/v1/orders/, the same endpoint
hit a second drift::

    psycopg2.errors.UndefinedFunction: function upper(integer) does not exist
    ... AND upper(inventory_transfer_items.battery_id) IN (%(upper_1_1)s)
    parameters: {'upper_1_1': 'WZ-0-0-1776249262'}

Same class of bug as wave 3: the ORM treats ``battery_id`` as a
business-id string (``BAT-1001`` / ``WZ-...``) while f1e2d3c4b5a6 created
it as INTEGER with an FK to ``batteries.id``. The ORM carries the INT FK
to batteries on a sibling column (``battery_pk`` / ``battery_table_id``),
so dropping the legacy FK is safe.

Tables & columns realigned
--------------------------

1. ``inventory_transfer_items.battery_id``  INT -> VARCHAR
   (model: ``app.models.inventory.InventoryTransferItem.battery_id: str``;
    INT FK to batteries lives on ``battery_pk``, added by a1b2c3d4e5f8)

2. ``manifest_items.battery_id``            INT -> VARCHAR
   (model: ``app.models.manifest.ManifestItem.battery_id: str``;
    INT FK to batteries lives on ``battery_table_id``, added by a1b2c3d4e5f8)

3. ``manifests.id``                         INT/SERIAL -> VARCHAR
   (model: ``app.models.manifest.Manifest.id: str``, format ``MAN-001``)

4. ``manifest_items.manifest_id``           INT -> VARCHAR
   (FK to manifests.id; CASCADE preserved from f1e2d3c4b5a6 line 166)

Procedure mirrors wave 3:

- Idempotent pre-check on ``manifests.id`` *and* the two battery_id
  columns — the script only performs work that is still required, so a
  partial re-run (e.g. crash between steps in a non-transactional deploy)
  is still safe.
- Dynamically drop every FK on the columns we're about to retype.
- Drop SERIAL default on ``manifests.id``; cast columns with explicit
  ``USING col::VARCHAR``; re-add the manifest_items → manifests FK with
  ON DELETE CASCADE.
- Drop the orphan ``manifests_id_seq``.

PostgreSQL-only. SQLite dev DBs materialize the correct types directly
via ``SQLModel.metadata.create_all``.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "c4d5e6f7a8b9"
down_revision: Union[str, None] = "b3c4d5e6f7a8"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


_UPGRADE_SQL = r"""
DO $$
DECLARE
    manifests_id_type text;
    iti_battery_type text;
    mi_battery_type text;
    mi_manifest_type text;
    needs_work boolean := false;
    fk_rec RECORD;
BEGIN
    -- Bail if none of the target tables exist (should never happen in prod).
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables
                   WHERE table_name = 'inventory_transfer_items')
       AND NOT EXISTS (SELECT 1 FROM information_schema.tables
                       WHERE table_name = 'manifests')
    THEN
        RETURN;
    END IF;

    -- Inspect current column types; any still-INT column means there's work.
    SELECT data_type INTO manifests_id_type
    FROM information_schema.columns
    WHERE table_name = 'manifests' AND column_name = 'id';

    SELECT data_type INTO iti_battery_type
    FROM information_schema.columns
    WHERE table_name = 'inventory_transfer_items' AND column_name = 'battery_id';

    SELECT data_type INTO mi_battery_type
    FROM information_schema.columns
    WHERE table_name = 'manifest_items' AND column_name = 'battery_id';

    SELECT data_type INTO mi_manifest_type
    FROM information_schema.columns
    WHERE table_name = 'manifest_items' AND column_name = 'manifest_id';

    IF manifests_id_type  IS NOT NULL AND manifests_id_type  NOT IN ('character varying', 'text')
       OR iti_battery_type IS NOT NULL AND iti_battery_type NOT IN ('character varying', 'text')
       OR mi_battery_type  IS NOT NULL AND mi_battery_type  NOT IN ('character varying', 'text')
       OR mi_manifest_type IS NOT NULL AND mi_manifest_type NOT IN ('character varying', 'text')
    THEN
        needs_work := true;
    END IF;

    IF NOT needs_work THEN
        RETURN;
    END IF;

    -- 1. Drop every FK sitting on any column we're about to retype. We also
    --    drop FKs that *reference* manifests.id so the manifests.id cast is
    --    unblocked. Dynamic discovery handles whatever names SQLAlchemy
    --    auto-generated at create_table time.
    FOR fk_rec IN
        SELECT c.conname, cl.relname AS table_name
        FROM pg_constraint c
        JOIN pg_class cl ON cl.oid = c.conrelid
        JOIN pg_attribute a
            ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
        WHERE c.contype = 'f'
          AND (
              (cl.relname = 'inventory_transfer_items' AND a.attname = 'battery_id')
              OR (cl.relname = 'manifest_items'
                  AND a.attname IN ('battery_id', 'manifest_id'))
          )
    LOOP
        EXECUTE format('ALTER TABLE %I DROP CONSTRAINT %I',
                       fk_rec.table_name, fk_rec.conname);
    END LOOP;

    -- Also drop any FK pointing *at* manifests.id (belt & braces — normally
    -- manifest_items.manifest_id caught above is the only one, but this
    -- matches wave 3's structure for symmetry and future-proofing).
    FOR fk_rec IN
        SELECT c.conname, cl.relname AS table_name
        FROM pg_constraint c
        JOIN pg_class cl ON cl.oid = c.conrelid
        JOIN pg_class rcl ON rcl.oid = c.confrelid
        WHERE c.contype = 'f' AND rcl.relname = 'manifests'
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %I DROP CONSTRAINT %I',
                           fk_rec.table_name, fk_rec.conname);
        EXCEPTION WHEN undefined_object THEN
            -- already dropped above
            NULL;
        END;
    END LOOP;

    -- 2. Drop the SERIAL default on manifests.id (sequence orphaned; dropped below).
    IF manifests_id_type IS NOT NULL
       AND manifests_id_type NOT IN ('character varying', 'text')
    THEN
        ALTER TABLE manifests ALTER COLUMN id DROP DEFAULT;
    END IF;

    -- 3. Cast the columns. Each ALTER is gated on the column still being
    --    non-text, so re-runs after partial success are no-ops.
    IF manifests_id_type IS NOT NULL
       AND manifests_id_type NOT IN ('character varying', 'text')
    THEN
        ALTER TABLE manifests
            ALTER COLUMN id TYPE VARCHAR USING id::VARCHAR;
    END IF;

    IF mi_manifest_type IS NOT NULL
       AND mi_manifest_type NOT IN ('character varying', 'text')
    THEN
        ALTER TABLE manifest_items
            ALTER COLUMN manifest_id TYPE VARCHAR USING manifest_id::VARCHAR;
    END IF;

    IF mi_battery_type IS NOT NULL
       AND mi_battery_type NOT IN ('character varying', 'text')
    THEN
        ALTER TABLE manifest_items
            ALTER COLUMN battery_id TYPE VARCHAR USING battery_id::VARCHAR;
    END IF;

    IF iti_battery_type IS NOT NULL
       AND iti_battery_type NOT IN ('character varying', 'text')
    THEN
        ALTER TABLE inventory_transfer_items
            ALTER COLUMN battery_id TYPE VARCHAR USING battery_id::VARCHAR;
    END IF;

    -- 4. Re-add the manifest_items -> manifests FK with CASCADE semantics
    --    preserved from f1e2d3c4b5a6 line 166. No re-add of the battery_id
    --    FKs — the ORM intentionally drops them in favour of battery_pk /
    --    battery_table_id for the INT reference to batteries.id.
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'manifest_items' AND column_name = 'manifest_id'
    ) AND NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_manifest_items_manifest_id'
    ) THEN
        ALTER TABLE manifest_items
            ADD CONSTRAINT fk_manifest_items_manifest_id
            FOREIGN KEY (manifest_id) REFERENCES manifests(id) ON DELETE CASCADE;
    END IF;

    -- 5. Drop the orphan sequence that backed the old SERIAL manifests.id.
    IF EXISTS (
        SELECT 1 FROM pg_class
        WHERE relkind = 'S' AND relname = 'manifests_id_seq'
    ) THEN
        DROP SEQUENCE manifests_id_seq CASCADE;
    END IF;
END $$;
"""


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name != "postgresql":
        return
    op.execute(sa.text(_UPGRADE_SQL))


def downgrade() -> None:
    # No-op by design. Reverting VARCHAR -> INTEGER would break on every
    # MAN-XXX / BAT-XXXX / WZ-... row that now lives in these columns.
    pass
