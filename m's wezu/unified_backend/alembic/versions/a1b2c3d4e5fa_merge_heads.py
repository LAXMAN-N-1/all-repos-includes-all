"""Merge multiple heads

Revision ID: a1b2c3d4e5fa
Revises: a1b2c3d4e5f9, d1e2f3a4b5c7
Create Date: 2026-04-20 20:45:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5fa'
down_revision: Union[str, Sequence[str], None] = ('a1b2c3d4e5f9', 'd1e2f3a4b5c7')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
