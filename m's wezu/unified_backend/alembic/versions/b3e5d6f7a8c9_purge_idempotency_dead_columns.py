"""Purge dead schema drift columns from idempotency_keys

Revision ID: b3e5d6f7a8c9
Revises: f9a8b7c6d5e4
Create Date: 2026-04-20 03:40:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = "b3e5d6f7a8c9"
down_revision: Union[str, None] = "f9a8b7c6d5e4"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    op.execute("ALTER TABLE idempotency_keys DROP COLUMN IF EXISTS key")
    op.execute("ALTER TABLE idempotency_keys DROP COLUMN IF EXISTS response_status")
    op.execute("ALTER TABLE idempotency_keys DROP COLUMN IF EXISTS response_body")

def downgrade() -> None:
    pass
