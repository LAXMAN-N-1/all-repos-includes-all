"""add transports_json to passkey_credentials

Revision ID: 8df773d90265
Revises: 8d7c6b5a4f3e
Create Date: 2026-04-15 21:05:49.268736

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '8df773d90265'
down_revision: Union[str, None] = '8d7c6b5a4f3e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('passkey_credentials', sa.Column('transports_json', sa.String(), nullable=True))


def downgrade() -> None:
    op.drop_column('passkey_credentials', 'transports_json')
