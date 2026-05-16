"""add color to roles

Revision ID: f553750c5c54
Revises: 8541364149a0
Create Date: 2025-12-15 15:54:10.509427

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f553750c5c54'
down_revision: Union[str, None] = '8541364149a0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with op.batch_alter_table('roles', schema=None) as batch_op:
        batch_op.add_column(sa.Column('color', sa.String(length=50), nullable=True, server_default='gray'))


def downgrade() -> None:
    with op.batch_alter_table('roles', schema=None) as batch_op:
        batch_op.drop_column('color')
