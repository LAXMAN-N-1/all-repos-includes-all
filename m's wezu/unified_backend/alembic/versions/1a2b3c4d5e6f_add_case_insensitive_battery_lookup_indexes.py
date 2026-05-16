"""add case insensitive battery lookup indexes

Revision ID: 1a2b3c4d5e6f
Revises: 0f4a5b6c7d8e
Create Date: 2026-04-24 01:15:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op


revision: str = "1a2b3c4d5e6f"
down_revision: Union[str, None] = "0f4a5b6c7d8e"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    statements = (
        "CREATE INDEX IF NOT EXISTS ix_batteries_serial_number_upper ON batteries (upper(serial_number))",
        "CREATE INDEX IF NOT EXISTS ix_shelf_batteries_battery_id_upper ON shelf_batteries (upper(battery_id))",
        "CREATE INDEX IF NOT EXISTS ix_inventory_transfer_items_battery_id_upper "
        "ON inventory_transfer_items (upper(battery_id))",
        "CREATE INDEX IF NOT EXISTS ix_logistics_order_batteries_battery_id_upper "
        "ON logistics_order_batteries (upper(battery_id))",
    )
    for statement in statements:
        op.execute(statement)


def downgrade() -> None:
    statements = (
        "DROP INDEX IF EXISTS ix_logistics_order_batteries_battery_id_upper",
        "DROP INDEX IF EXISTS ix_inventory_transfer_items_battery_id_upper",
        "DROP INDEX IF EXISTS ix_shelf_batteries_battery_id_upper",
        "DROP INDEX IF EXISTS ix_batteries_serial_number_upper",
    )
    for statement in statements:
        op.execute(statement)
