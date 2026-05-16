"""rebuild_enums_to_lowercase

Revision ID: c3d4e5f6g7h8
Revises: a1b2c3d4e5f8
Create Date: 2026-04-20 03:15:00.000000

"""
from alembic import op
import sqlalchemy as sa

revision = "c3d4e5f6g7h8"
down_revision = "d5e6f7a8b9c0"

def upgrade() -> None:
    bind = op.get_bind()
    dialect = bind.dialect.name
    if dialect != "postgresql":
        return

    op.execute("ALTER TABLE batteries ALTER COLUMN status DROP DEFAULT")
    op.execute("ALTER TABLE batteries ALTER COLUMN location_type DROP DEFAULT")
    
    op.execute("ALTER TYPE batterystatus RENAME TO batterystatus_legacy")
    op.execute("ALTER TYPE locationtype RENAME TO locationtype_legacy")
    
    sa.Enum("available", "rented", "maintenance", "charging", "retired", "deployed", "reserved", "in_transit", "faulty", "new", "ready", "decommissioned", name="batterystatus").create(op.get_bind())
    sa.Enum("station", "warehouse", "service_center", "recycling", "customer", "transit", "shelf", name="locationtype").create(op.get_bind())
    
    op.execute("ALTER TABLE batteries ALTER COLUMN status TYPE batterystatus USING lower(status::text)::batterystatus")
    op.execute("ALTER TABLE batteries ALTER COLUMN location_type TYPE locationtype USING lower(location_type::text)::locationtype")
    
    op.execute("DROP TYPE batterystatus_legacy")
    op.execute("DROP TYPE locationtype_legacy")

def downgrade() -> None:
    pass
