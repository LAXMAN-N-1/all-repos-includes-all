"""add manager_id to branches

Revision ID: 8541364149a0
Revises: 032a85acb166
Create Date: 2025-12-15 15:49:30.939999

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '8541364149a0'
down_revision: Union[str, None] = '032a85acb166'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with op.batch_alter_table('branches', schema=None) as batch_op:
        batch_op.add_column(sa.Column('manager_id', sa.Integer(), nullable=True))
        batch_op.create_foreign_key('fk_branches_manager_id_users', 'users', ['manager_id'], ['id'])


def downgrade() -> None:
    with op.batch_alter_table('branches', schema=None) as batch_op:
        batch_op.drop_constraint('fk_branches_manager_id_users', type_='foreignkey')
        batch_op.drop_column('manager_id')
