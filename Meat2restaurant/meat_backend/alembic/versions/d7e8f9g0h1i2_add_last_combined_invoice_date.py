"""Add last_combined_invoice_date to customers

Revision ID: d7e8f9g0h1i2
Revises: c1a2b3c4d5e6
Create Date: 2026-01-23 14:25:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'd7e8f9g0h1i2'
down_revision = 'c1a2b3c4d5e6'
branch_labels = None
depends_on = None


def upgrade():
    # Add last_combined_invoice_date to customers table
    op.add_column('customers', sa.Column('last_combined_invoice_date', sa.Date(), nullable=True))


def downgrade():
    # Remove last_combined_invoice_date from customers table
    op.drop_column('customers', 'last_combined_invoice_date')
