"""normalize_settlement_dealer_keys

Revision ID: e0a1b2c3d4e7
Revises: e0a1b2c3d4e6
Create Date: 2026-04-22 23:05:00.000000
"""

from __future__ import annotations

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "e0a1b2c3d4e7"
down_revision: Union[str, None] = "e0a1b2c3d4e6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _table_exists(inspector: sa.Inspector, table_name: str) -> bool:
    try:
        return inspector.has_table(table_name)
    except Exception:
        return False


def upgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    if not _table_exists(inspector, "settlements") or not _table_exists(inspector, "dealer_profiles"):
        return

    # Canonical ownership key for settlements is dealer_profiles.id.
    # Normalize legacy rows that stored dealer owner users.id.
    bind.execute(
        sa.text(
            """
            UPDATE settlements AS s
            SET dealer_id = dp.id
            FROM dealer_profiles AS dp
            WHERE s.dealer_id = dp.user_id
              AND s.dealer_id IS NOT NULL
            """
        )
    )


def downgrade() -> None:
    bind = op.get_bind()
    inspector = sa.inspect(bind)
    if not _table_exists(inspector, "settlements") or not _table_exists(inspector, "dealer_profiles"):
        return

    # Revert normalized rows back to dealer owner users.id.
    bind.execute(
        sa.text(
            """
            UPDATE settlements AS s
            SET dealer_id = dp.user_id
            FROM dealer_profiles AS dp
            WHERE s.dealer_id = dp.id
              AND s.dealer_id IS NOT NULL
            """
        )
    )
