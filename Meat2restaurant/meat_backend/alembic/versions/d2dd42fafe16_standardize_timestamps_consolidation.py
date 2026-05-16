"""standardize_timestamps_consolidation

Revision ID: d2dd42fafe16
Revises: f7a2b8575c1a
Create Date: 2026-02-26 00:58:32.077992

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'd2dd42fafe16'
down_revision = 'f7a2b8575c1a'
branch_labels = None
depends_on = None


def upgrade():
    """
    Finalize standardization for remaining tables and update version.
    """
    from sqlalchemy import inspect, text
    
    conn = op.get_bind()
    inspector = inspect(conn)
    
    # We've already done most tables. Focus on the ones that were potentially locking
    # or just do a quick pass to ensure everything is correct as a final check.
    tables = ['web_pages', 'web_page_versions']

    for table in tables:
        columns = [c['name'] for c in inspector.get_columns(table)]
        
        # Standardize created_at
        if 'created_at' not in columns:
            op.add_column(table, sa.Column('created_at', sa.DateTime(), server_default=sa.func.now(), nullable=False))
        else:
            op.execute(text(f"ALTER TABLE {table} ALTER COLUMN created_at SET NOT NULL"))
            op.execute(text(f"ALTER TABLE {table} ALTER COLUMN created_at SET DEFAULT now()"))

        # Standardize updated_at
        if 'updated_at' not in columns:
            op.add_column(table, sa.Column('updated_at', sa.DateTime(), server_default=sa.func.now(), nullable=False))
        else:
            op.execute(text(f"ALTER TABLE {table} ALTER COLUMN updated_at SET NOT NULL"))
            op.execute(text(f"ALTER TABLE {table} ALTER COLUMN updated_at SET DEFAULT now()"))


def downgrade():
    """No-op downgrade to avoid destructive data loss on primary timestamp columns."""
    pass
