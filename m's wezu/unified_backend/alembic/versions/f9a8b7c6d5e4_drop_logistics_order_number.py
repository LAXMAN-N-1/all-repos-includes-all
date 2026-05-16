"""Drop redundant order_number column from logistics_orders

Revision ID: f9a8b7c6d5e4
Revises: c3d4e5f6g7h8
Create Date: 2026-04-20 03:30:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "f9a8b7c6d5e4"
down_revision: Union[str, None] = "c3d4e5f6g7h8"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    op.drop_column("logistics_orders", "order_number")

def downgrade() -> None:
    op.add_column("logistics_orders", sa.Column("order_number", sa.String(), nullable=True))
    op.create_index(op.f("ix_logistics_orders_order_number"), "logistics_orders", ["order_number"], unique=True)
