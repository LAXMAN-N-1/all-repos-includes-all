"""separate management and b2b identities

Revision ID: 0236f87096f4
Revises: 9ff739771d77
Create Date: 2025-12-30 18:14:55.597386

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0236f87096f4'
down_revision = '9ff739771d77'
branch_labels = None
depends_on = None


def upgrade():
    # 1. Add Auth to Customers
    op.add_column('customers', sa.Column('hashed_password', sa.String(length=255), nullable=True))
    op.add_column('customers', sa.Column('is_active', sa.Boolean(), nullable=True, server_default='true'))

    # 2. Clean up Users (Remove B2B stuff)
    op.drop_column('users', 'business_description')
    op.drop_column('users', 'business_phone')
    op.drop_column('users', 'business_address')
    op.drop_column('users', 'tax_id')
    op.drop_column('users', 'business_name')
    op.drop_column('users', 'parent_id')
    op.drop_column('users', 'customer_id')
    op.drop_column('users', 'is_org_head')


def downgrade():
    op.add_column('users', sa.Column('is_org_head', sa.BOOLEAN(), server_default=sa.text('false'), autoincrement=False, nullable=True))
    op.add_column('users', sa.Column('customer_id', sa.INTEGER(), autoincrement=False, nullable=True))
    op.add_column('users', sa.Column('parent_id', sa.INTEGER(), autoincrement=False, nullable=True))
    op.add_column('users', sa.Column('business_name', sa.VARCHAR(length=255), autoincrement=False, nullable=True))
    op.add_column('users', sa.Column('tax_id', sa.VARCHAR(length=100), autoincrement=False, nullable=True))
    op.add_column('users', sa.Column('business_address', sa.VARCHAR(length=500), autoincrement=False, nullable=True))
    op.add_column('users', sa.Column('business_phone', sa.VARCHAR(length=20), autoincrement=False, nullable=True))
    op.add_column('users', sa.Column('business_description', sa.VARCHAR(length=1000), autoincrement=False, nullable=True))
    
    op.drop_column('customers', 'is_active')
    op.drop_column('customers', 'hashed_password')
