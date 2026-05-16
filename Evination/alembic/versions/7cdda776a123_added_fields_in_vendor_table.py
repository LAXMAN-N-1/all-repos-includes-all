"""added fields in vendor table

Revision ID: 7cdda776a123
Revises: 70ec2eee52e8
Create Date: 2025-12-15 14:49:15.958549

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

# revision identifiers, used by Alembic.
revision: str = '7cdda776a123'
down_revision: Union[str, None] = '70ec2eee52e8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # --- Vendors ---
    op.add_column(
        'vendors',
        sa.Column('offered_services', sa.JSON(), nullable=True)
    )
    op.add_column(
        'vendors',
        sa.Column('portfolio_urls', sa.JSON(), nullable=True)
    )
    op.add_column(
        'vendors',
        sa.Column('rating', sa.Numeric(3, 2), nullable=False, server_default='0.0')
    )
    op.add_column(
        'vendors',
        sa.Column('total_reviews', sa.Integer(), nullable=False, server_default='0')
    )
    op.add_column(
        'vendors',
        sa.Column('completed_events', sa.Integer(), nullable=False, server_default='0')
    )
    op.add_column(
        'vendors',
        sa.Column('service_areas', sa.JSON(), nullable=True)
    )

    # --- Backfill JSON fields ---
    op.execute(
        "UPDATE vendors SET offered_services = JSON_ARRAY() WHERE offered_services IS NULL"
    )

    # --- Enforce NOT NULL after data exists ---
    op.alter_column(
        'vendors',
        'offered_services',
        existing_type=mysql.JSON(),
        nullable=False
    )

    # Remove server defaults (logic should live in app layer)
    op.alter_column('vendors', 'rating', server_default=None)
    op.alter_column('vendors', 'total_reviews', server_default=None)
    op.alter_column('vendors', 'completed_events', server_default=None)


def downgrade() -> None:
    op.drop_column('vendors', 'service_areas')
    op.drop_column('vendors', 'completed_events')
    op.drop_column('vendors', 'total_reviews')
    op.drop_column('vendors', 'rating')
    op.drop_column('vendors', 'portfolio_urls')
    op.drop_column('vendors', 'offered_services')
