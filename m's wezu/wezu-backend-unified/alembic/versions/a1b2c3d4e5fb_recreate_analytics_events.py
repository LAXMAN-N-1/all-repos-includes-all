"""recreate analytics activity events table to align with ORM

Revision ID: a1b2c3d4e5fb
Revises: a1b2c3d4e5fa
Create Date: 2026-04-20 20:50:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5fb'
down_revision: Union[str, Sequence[str], None] = 'a1b2c3d4e5fa'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    conn = op.get_bind()
    
    inspector = sa.inspect(conn)
    if inspector.has_table('analytics_activity_events'):
        op.drop_table('analytics_activity_events')
    
    op.create_table(
        'analytics_activity_events',
        sa.Column('id', sa.String(), nullable=False, primary_key=True),
        sa.Column('event_type', sa.String(), nullable=False),
        sa.Column('title', sa.String(), nullable=False),
        sa.Column('event_timestamp', sa.DateTime(), nullable=False),
        sa.Column('reference_id', sa.String(), nullable=True),
        sa.Column('meta_json', sa.String(), nullable=True),
        sa.Column('source', sa.String(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False)
    )
    
    op.create_index(op.f('ix_analytics_activity_events_event_type'), 'analytics_activity_events', ['event_type'], unique=False)
    op.create_index(op.f('ix_analytics_activity_events_event_timestamp'), 'analytics_activity_events', ['event_timestamp'], unique=False)
    op.create_index(op.f('ix_analytics_activity_events_reference_id'), 'analytics_activity_events', ['reference_id'], unique=False)


def downgrade() -> None:
    pass
