"""add_menu_table

Revision ID: 497e6a26975c
Revises: 6ec9086be16b
Create Date: 2026-01-02 10:11:13.128673

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '497e6a26975c'
down_revision = '6ec9086be16b'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        'menus',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('title', sa.String(length=255), nullable=False),
        sa.Column('path', sa.String(length=500), nullable=True),
        sa.Column('icon', sa.String(length=100), nullable=True),
        sa.Column('parent_id', sa.Integer(), nullable=True),
        sa.Column('sort_order', sa.Integer(), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=True),
        sa.Column('required_permission', sa.String(length=100), nullable=True),
        sa.ForeignKeyConstraint(['parent_id'], ['menus.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_menus_id'), 'menus', ['id'], unique=False)
    op.create_index(op.f('ix_menus_title'), 'menus', ['title'], unique=False)


def downgrade():
    op.drop_index(op.f('ix_menus_title'), table_name='menus')
    op.drop_index(op.f('ix_menus_id'), table_name='menus')
    op.drop_table('menus')
