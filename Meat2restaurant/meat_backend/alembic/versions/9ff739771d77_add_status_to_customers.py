"""add status to customers

Revision ID: 9ff739771d77
Revises: 8f9751e3838c
Create Date: 2025-12-30 16:58:27.071073

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '9ff739771d77'
down_revision = '8f9751e3838c'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('customers', sa.Column('status', sa.String(length=50), nullable=True))


def downgrade():
    op.drop_column('customers', 'status')
