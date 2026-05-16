"""recreate analytics jobs table to align with ORM

Revision ID: a1b2c3d4e5f9
Revises: a1b2c3d4e5f8
Create Date: 2026-04-20 20:38:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5f9'
down_revision: Union[str, None] = 'a1b2c3d4e5f8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


from alembic import context

def upgrade() -> None:
    conn = op.get_bind()
    
    inspector = sa.inspect(conn)
    if inspector.has_table('analytics_report_jobs'):
        op.drop_table('analytics_report_jobs')
    
    op.create_table(
        'analytics_report_jobs',
        sa.Column('report_id', sa.String(), nullable=False, primary_key=True),
        sa.Column('status', sa.String(), server_default='queued', nullable=False),
        sa.Column('report_format', sa.String(), server_default='csv', nullable=False),
        sa.Column('timezone', sa.String(), server_default='UTC', nullable=False),
        sa.Column('include_sections', sa.String(), server_default='[]', nullable=False),
        sa.Column('from_utc', sa.DateTime(), nullable=False),
        sa.Column('to_utc', sa.DateTime(), nullable=False),
        sa.Column('requested_by_user_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=True),
        sa.Column('file_path', sa.String(), nullable=True),
        sa.Column('file_url', sa.String(), nullable=True),
        sa.Column('expires_at', sa.DateTime(), nullable=True),
        sa.Column('detail', sa.String(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=False),
        sa.Column('started_at', sa.DateTime(), nullable=True),
        sa.Column('completed_at', sa.DateTime(), nullable=True)
    )
    op.create_index(op.f('ix_analytics_report_jobs_status'), 'analytics_report_jobs', ['status'], unique=False)
    op.create_index(op.f('ix_analytics_report_jobs_created_at'), 'analytics_report_jobs', ['created_at'], unique=False)
    op.create_index(op.f('ix_analytics_report_jobs_updated_at'), 'analytics_report_jobs', ['updated_at'], unique=False)


def downgrade() -> None:
    pass

