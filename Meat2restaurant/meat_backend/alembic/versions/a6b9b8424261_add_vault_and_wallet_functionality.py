"""Add Vault and Wallet functionality

Revision ID: a6b9b8424261
Revises: ea27b19bb99c
Create Date: 2026-01-20 17:22:26.993714

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = 'a6b9b8424261'
down_revision = 'ea27b19bb99c'
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    
    # 1. Add wallet_balance to customers
    columns = [c['name'] for c in inspector.get_columns('customers')]
    if 'wallet_balance' not in columns:
        op.add_column('customers', sa.Column('wallet_balance', sa.Float(), nullable=True, server_default='0.0'))
    
    # 2. Add wallet_amount_used to orders
    columns = [c['name'] for c in inspector.get_columns('orders')]
    if 'wallet_amount_used' not in columns:
        op.add_column('orders', sa.Column('wallet_amount_used', sa.Float(), nullable=True, server_default='0.0'))
    
    # 3. Create wallet_transactions table
    tables = inspector.get_table_names()
    if 'wallet_transactions' not in tables:
        op.create_table('wallet_transactions',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('customer_id', sa.Integer(), nullable=True),
            sa.Column('amount', sa.Float(), nullable=False),
            sa.Column('transaction_type', sa.String(length=50), nullable=False),
            sa.Column('reference_id', sa.String(length=100), nullable=True),
            sa.Column('notes', sa.String(length=500), nullable=True),
            sa.Column('created_at', sa.DateTime(), nullable=True),
            sa.ForeignKeyConstraint(['customer_id'], ['customers.id'], ),
            sa.PrimaryKeyConstraint('id')
        )
        op.create_index(op.f('ix_wallet_transactions_customer_id'), 'wallet_transactions', ['customer_id'], unique=False)
        op.create_index(op.f('ix_wallet_transactions_id'), 'wallet_transactions', ['id'], unique=False)


def downgrade():
    op.drop_index(op.f('ix_wallet_transactions_id'), table_name='wallet_transactions')
    op.drop_index(op.f('ix_wallet_transactions_customer_id'), table_name='wallet_transactions')
    op.drop_table('wallet_transactions')
    op.drop_column('orders', 'wallet_amount_used')
    op.drop_column('customers', 'wallet_balance')
