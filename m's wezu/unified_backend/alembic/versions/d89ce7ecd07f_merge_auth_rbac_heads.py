"""merge_auth_rbac_heads

Revision ID: d89ce7ecd07f
Revises: c5d6e7f8a9b0, fb1c2d3e4f5a
Create Date: 2026-04-22 01:48:53.185781

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'd89ce7ecd07f'
down_revision: Union[str, None] = ('c5d6e7f8a9b0', 'fb1c2d3e4f5a')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
