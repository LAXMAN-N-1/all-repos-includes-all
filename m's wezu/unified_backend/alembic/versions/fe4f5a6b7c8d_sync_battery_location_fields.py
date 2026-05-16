"""sync battery location fields: repair station_id / location_type / location_id divergence

Revision ID: fe4f5a6b7c8d
Revises: fd3e4f5a6b7c
Create Date: 2026-04-25

Two location tracking systems exist on the batteries table:
  - station_id (FK to stations)
  - location_type + location_id (polymorphic)

They must always agree. This migration repairs all rows where they diverged.
"""
from alembic import op
import sqlalchemy as sa

revision = "fe4f5a6b7c8d"
down_revision = "2c4d6e8f0a1b"
branch_labels = None
depends_on = None


def upgrade() -> None:
    conn = op.get_bind()

    # 1. station_id set but location_type != 'station'
    #    station_id is the FK, treat it as authoritative.
    result = conn.execute(
        sa.text(
            "UPDATE batteries "
            "SET location_type = 'station', "
            "    location_id   = station_id, "
            "    updated_at    = NOW() "
            "WHERE station_id IS NOT NULL "
            "  AND (location_type != 'station' OR location_id IS NULL OR location_id != station_id) "
            "RETURNING id, serial_number"
        )
    )
    rows = result.fetchall()
    if rows:
        print(f"[migration] Repaired {len(rows)} batteries: station_id set, location fields wrong.")

    # 2. location_type='station' + location_id set, but station_id NULL
    result = conn.execute(
        sa.text(
            "UPDATE batteries "
            "SET station_id  = location_id, "
            "    updated_at  = NOW() "
            "WHERE station_id IS NULL "
            "  AND location_type = 'station' "
            "  AND location_id IS NOT NULL "
            "RETURNING id, serial_number"
        )
    )
    rows = result.fetchall()
    if rows:
        print(f"[migration] Repaired {len(rows)} batteries: location_type=station but station_id was NULL.")

    # 3. location_type != 'station' but station_id still set (e.g. transit batteries)
    #    These should have station_id NULL — clear it.
    result = conn.execute(
        sa.text(
            "UPDATE batteries "
            "SET station_id = NULL, "
            "    updated_at = NOW() "
            "WHERE station_id IS NOT NULL "
            "  AND location_type != 'station' "
            "RETURNING id, serial_number"
        )
    )
    rows = result.fetchall()
    if rows:
        print(f"[migration] Cleared station_id on {len(rows)} non-station batteries.")


def downgrade() -> None:
    # Data repair migrations are not reversible.
    pass
