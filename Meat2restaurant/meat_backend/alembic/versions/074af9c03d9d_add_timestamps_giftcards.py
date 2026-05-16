"""Add timestamps to gift cards and shipments

Revision ID: 074af9c03d9d
Revises: b6a3bb9aa70a
Create Date: 2026-01-06 16:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '074af9c03d9d'
down_revision = 'b6a3bb9aa70a'
branch_labels = None
depends_on = None


def upgrade():
    # --- gift_cards ---
    op.add_column('gift_cards', sa.Column('created_at', sa.DateTime(), nullable=True))
    op.add_column('gift_cards', sa.Column('updated_at', sa.DateTime(), nullable=True))
    op.execute("UPDATE gift_cards SET created_at = NOW(), updated_at = NOW()")
    
    # --- shipments ---
    op.add_column('shipments', sa.Column('created_at', sa.DateTime(), nullable=True))
    op.add_column('shipments', sa.Column('updated_at', sa.DateTime(), nullable=True))
    op.execute("UPDATE shipments SET created_at = NOW(), updated_at = NOW()")


def downgrade():
    op.drop_column('shipments', 'updated_at')
    op.drop_column('shipments', 'created_at')
    
    op.drop_column('gift_cards', 'updated_at')
    op.drop_column('gift_cards', 'created_at')
