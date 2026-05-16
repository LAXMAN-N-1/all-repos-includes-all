"""Add missing fields to membership models manually

Revision ID: b6a3bb9aa70a
Revises: 31f0758d55ab
Create Date: 2026-01-06 15:24:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'b6a3bb9aa70a'
down_revision = '31f0758d55ab'
branch_labels = None
depends_on = None


def upgrade():
    # --- membership_plans ---
    op.add_column('membership_plans', sa.Column('description', sa.String(length=500), nullable=True))
    op.add_column('membership_plans', sa.Column('is_active', sa.Boolean(), nullable=True))
    op.add_column('membership_plans', sa.Column('created_at', sa.DateTime(), nullable=True))
    op.add_column('membership_plans', sa.Column('updated_at', sa.DateTime(), nullable=True))
    
    # Set default values for existing rows
    op.execute("UPDATE membership_plans SET is_active = true, created_at = NOW(), updated_at = NOW()")
    
    # --- memberships ---
    op.add_column('memberships', sa.Column('created_at', sa.DateTime(), nullable=True))
    op.add_column('memberships', sa.Column('updated_at', sa.DateTime(), nullable=True))
    
    # Set default values for existing rows
    op.execute("UPDATE memberships SET created_at = NOW(), updated_at = NOW()")


def downgrade():
    op.drop_column('memberships', 'updated_at')
    op.drop_column('memberships', 'created_at')
    
    op.drop_column('membership_plans', 'updated_at')
    op.drop_column('membership_plans', 'created_at')
    op.drop_column('membership_plans', 'is_active')
    op.drop_column('membership_plans', 'description')
