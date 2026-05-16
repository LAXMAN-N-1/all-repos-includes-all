"""add_zip_code_to_customers

Revision ID: b7d8c1e2f3a4
Revises: d2dd42fafe16
Create Date: 2026-03-02 19:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'b7d8c1e2f3a4'
down_revision = 'd2dd42fafe16'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('customers', sa.Column('zip_code', sa.String(length=20), nullable=True))


def downgrade():
    op.drop_column('customers', 'zip_code')
