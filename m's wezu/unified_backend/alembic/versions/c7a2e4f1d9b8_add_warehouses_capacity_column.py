"""add_warehouses_capacity_column

Revision ID: c7a2e4f1d9b8
Revises: d4f8c1a9b2e3
Create Date: 2026-04-18 00:00:00.000000

Adds the ``capacity`` column to the ``warehouses`` table.

Root cause
----------
The ``Warehouse`` SQLModel defines ``capacity: int = Field(default=100)``
but the original ``7272fc017d9d_initial_migration`` never included that
column in its ``CREATE TABLE`` DDL. Any query that SELECTs the full model
(e.g. ``GET /api/v1/warehouse/``) fails at runtime with:

    psycopg2.errors.UndefinedColumn:
        column warehouses.capacity does not exist

Fix
---
``ALTER TABLE ... ADD COLUMN IF NOT EXISTS`` with the same default (100)
so existing warehouse rows get a sensible value immediately and no
application-level backfill is needed. The ``IF NOT EXISTS`` guard makes
the migration safe to run twice.
"""
from typing import Union, Sequence

from alembic import op
import sqlalchemy as sa


revision: str = "c7a2e4f1d9b8"
down_revision: Union[str, None] = "d4f8c1a9b2e3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name != "postgresql":
        return  # SQLite/dev: SQLModel.create_all() handles this

    op.execute(sa.text(
        "ALTER TABLE warehouses ADD COLUMN IF NOT EXISTS capacity INTEGER NOT NULL DEFAULT 100"
    ))


def downgrade() -> None:
    bind = op.get_bind()
    if bind.dialect.name != "postgresql":
        return
    op.execute(sa.text(
        "ALTER TABLE warehouses DROP COLUMN IF EXISTS capacity"
    ))
