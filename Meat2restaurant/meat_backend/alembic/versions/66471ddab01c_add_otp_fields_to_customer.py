"""add otp fields to customer

Revision ID: 66471ddab01c
Revises: 074af9c03d9d
Create Date: 2026-01-07 17:06:40.620003

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '66471ddab01c'
down_revision = '074af9c03d9d'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('customers', sa.Column('otp_code', sa.String(length=10), nullable=True))
    op.add_column('customers', sa.Column('otp_expiry', sa.DateTime(), nullable=True))


def downgrade():
    op.drop_column('customers', 'otp_expiry')
    op.drop_column('customers', 'otp_code')
