"""merge_all_heads_for_tenant_isolation

Revision ID: e0a1b2c3d4e5
Revises: a1b2c3d4e5f7, a1b2c3d4e5f9, a1b2c3d4e5fa, a1b2c3d4e5fb, b4e5f6a7b8c9,
    d1e2f3a4b5c7, d5e6f7a8b9c0, d89ce7ecd07f, fa9b8c7d6e5f
Create Date: 2026-04-22 22:10:00.000000
"""

from typing import Sequence, Union


revision: str = "e0a1b2c3d4e5"
down_revision: Union[str, None] = (
    "a1b2c3d4e5f7",
    "a1b2c3d4e5f9",
    "a1b2c3d4e5fa",
    "a1b2c3d4e5fb",
    "b4e5f6a7b8c9",
    "d1e2f3a4b5c7",
    "d5e6f7a8b9c0",
    "d89ce7ecd07f",
    "fa9b8c7d6e5f",
)
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
