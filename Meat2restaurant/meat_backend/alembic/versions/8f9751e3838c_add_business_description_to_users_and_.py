"""add business_description to users and customers

Revision ID: 8f9751e3838c
Revises: f5ca179270e1
Create Date: 2025-12-30 16:56:30.483141

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '8f9751e3838c'
down_revision = 'f5ca179270e1'
branch_labels = None
depends_on = None


def upgrade():
    # Add business_description to users
    op.add_column('users', sa.Column('business_description', sa.String(length=1000), nullable=True))
    # Add business_description to customers
    op.add_column('customers', sa.Column('business_description', sa.Text(), nullable=True))


def downgrade():
    op.drop_column('customers', 'business_description')
    op.drop_column('users', 'business_description')
