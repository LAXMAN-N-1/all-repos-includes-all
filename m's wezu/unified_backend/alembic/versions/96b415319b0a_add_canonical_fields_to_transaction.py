"""add canonical fields to transaction

Revision ID: 96b415319b0a
Revises: e7b3c8a5f2d1
Create Date: 2026-04-16 04:55:31.815629

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '96b415319b0a'
down_revision: Union[str, None] = 'e7b3c8a5f2d1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('transactions', sa.Column('type', sa.String(), nullable=True))
    op.create_index(op.f('ix_transactions_type'), 'transactions', ['type'], unique=False)

    op.add_column('transactions', sa.Column('category', sa.String(), nullable=True))
    op.create_index(op.f('ix_transactions_category'), 'transactions', ['category'], unique=False)

    op.add_column('transactions', sa.Column('balance_after', sa.Float(), nullable=True))

    op.add_column('transactions', sa.Column('reference_type', sa.String(), nullable=True))
    
    op.add_column('transactions', sa.Column('reference_id', sa.String(), nullable=True))
    op.create_index(op.f('ix_transactions_reference_id'), 'transactions', ['reference_id'], unique=False)

    op.add_column('transactions', sa.Column('razorpay_payment_id', sa.String(), nullable=True))
    op.create_index(op.f('ix_transactions_razorpay_payment_id'), 'transactions', ['razorpay_payment_id'], unique=False)

def downgrade() -> None:
    op.drop_index(op.f('ix_transactions_razorpay_payment_id'), table_name='transactions')
    op.drop_column('transactions', 'razorpay_payment_id')

    op.drop_index(op.f('ix_transactions_reference_id'), table_name='transactions')
    op.drop_column('transactions', 'reference_id')

    op.drop_column('transactions', 'reference_type')

    op.drop_column('transactions', 'balance_after')

    op.drop_index(op.f('ix_transactions_category'), table_name='transactions')
    op.drop_column('transactions', 'category')

    op.drop_index(op.f('ix_transactions_type'), table_name='transactions')
    op.drop_column('transactions', 'type')
