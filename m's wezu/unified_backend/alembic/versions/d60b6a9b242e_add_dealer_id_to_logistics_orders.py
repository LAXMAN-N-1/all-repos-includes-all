"""Add dealer_id to logistics_orders

Revision ID: d60b6a9b242e
Revises: caca32ae48cf
Create Date: 2026-04-22 21:04:28.330218

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'd60b6a9b242e'
down_revision: Union[str, None] = 'caca32ae48cf'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('logistics_orders', sa.Column('dealer_id', sa.Integer(), nullable=True))
    op.create_index(op.f('ix_logistics_orders_dealer_id'), 'logistics_orders', ['dealer_id'], unique=False)
    op.create_foreign_key('fk_logistics_orders_dealer_id', 'logistics_orders', 'dealer_profiles', ['dealer_id'], ['id'])


def downgrade() -> None:
    op.drop_constraint('fk_logistics_orders_dealer_id', 'logistics_orders', type_='foreignkey')
    op.drop_index(op.f('ix_logistics_orders_dealer_id'), table_name='logistics_orders')
    op.drop_column('logistics_orders', 'dealer_id')
