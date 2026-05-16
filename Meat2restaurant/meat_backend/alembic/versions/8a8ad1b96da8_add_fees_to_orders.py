"""add fees to orders

Revision ID: 8a8ad1b96da8
Revises: 6e2d6fbd2ab7
Create Date: 2026-02-11 12:00:34.456403

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '8a8ad1b96da8'
down_revision = '6e2d6fbd2ab7'
branch_labels = None
depends_on = None


def upgrade():
    # Add missing columns to orders table
    op.add_column('orders', sa.Column('delivery_fee', sa.Float(), nullable=True, server_default='0'))
    op.add_column('orders', sa.Column('platform_fee', sa.Float(), nullable=True, server_default='0'))


def downgrade():
    op.drop_column('orders', 'platform_fee')
    op.drop_column('orders', 'delivery_fee')
