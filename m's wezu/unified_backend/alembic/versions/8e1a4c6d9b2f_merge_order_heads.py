"""merge order-related migration heads

Revision ID: 8e1a4c6d9b2f
Revises: 3c8d1a2b4e7f, d60b6a9b242e
Create Date: 2026-04-23 11:10:00.000000
"""

from typing import Sequence, Union


# revision identifiers, used by Alembic.
revision: str = "8e1a4c6d9b2f"
down_revision: Union[str, Sequence[str], None] = ("3c8d1a2b4e7f", "d60b6a9b242e")
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
