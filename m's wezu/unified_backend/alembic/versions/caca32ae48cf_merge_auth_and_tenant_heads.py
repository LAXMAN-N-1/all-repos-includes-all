"""merge auth and tenant heads

Revision ID: caca32ae48cf
Revises: e0a1b2c3d4e9, fc2d3e4f5a6
Create Date: 2026-04-22 15:55:51.065120

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'caca32ae48cf'
down_revision: Union[str, None] = ('e0a1b2c3d4e9', 'fc2d3e4f5a6')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
