"""add due_date to combined_invoices

Revision ID: 02c54783fda4
Revises: d7e8f9g0h1i2
Create Date: 2026-01-23 16:53:53.003801

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '02c54783fda4'
down_revision = 'd7e8f9g0h1i2'
branch_labels = None
depends_on = None


def upgrade():
    # Add due_date to combined_invoices
    op.add_column('combined_invoices', sa.Column('due_date', sa.DateTime(), nullable=True))


def downgrade():
    # Remove due_date from combined_invoices
    op.drop_column('combined_invoices', 'due_date')
