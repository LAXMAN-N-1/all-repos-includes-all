"""meat2restaurant_redesign_schema

Revision ID: 6b1ad6283675
Revises: 117888946753
Create Date: 2026-03-09 20:38:22.898614

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '6b1ad6283675'
down_revision = '117888946753'
branch_labels = None
depends_on = None


def upgrade():
    # 1. Add columns to orders table
    op.add_column('orders', sa.Column('pickup_time', sa.DateTime(), nullable=True))
    op.add_column('orders', sa.Column('delivery_type', sa.String(length=20), server_default='pickup', nullable=False))
    op.add_column('orders', sa.Column('delivery_address', sa.String(length=500), nullable=True))
    op.add_column('orders', sa.Column('reminder_30_sent', sa.Boolean(), server_default='0', nullable=False))
    op.add_column('orders', sa.Column('reminder_ready_sent', sa.Boolean(), server_default='0', nullable=False))

    # 2. Add columns to customers table
    op.add_column('customers', sa.Column('whatsapp_opted_in', sa.Boolean(), server_default='1', nullable=False))
    op.add_column('customers', sa.Column('preferred_location', sa.String(length=100), nullable=True))

    # 3. Create ratings table
    op.create_table('ratings',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('order_id', sa.Integer(), nullable=False),
        sa.Column('customer_id', sa.Integer(), nullable=False),
        sa.Column('stars', sa.Integer(), nullable=False),
        sa.Column('comment', sa.String(length=1000), nullable=True),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('CURRENT_TIMESTAMP'), nullable=False),
        sa.ForeignKeyConstraint(['customer_id'], ['customers.id'], ),
        sa.ForeignKeyConstraint(['order_id'], ['orders.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_ratings_id'), 'ratings', ['id'], unique=False)


def downgrade():
    op.drop_index(op.f('ix_ratings_id'), table_name='ratings')
    op.drop_table('ratings')
    op.drop_column('customers', 'preferred_location')
    op.drop_column('customers', 'whatsapp_opted_in')
    op.drop_column('orders', 'reminder_ready_sent')
    op.drop_column('orders', 'reminder_30_sent')
    op.drop_column('orders', 'delivery_address')
    op.drop_column('orders', 'delivery_type')
    op.drop_column('orders', 'pickup_time')
