"""extend vendor_bids for admin bidding system

Revision ID: e1449e23b30c
Revises: da72f0b49991
Create Date: 2025-12-11 11:28:31.662961

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'e1449e23b30c'
down_revision: Union[str, None] = 'da72f0b49991'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
