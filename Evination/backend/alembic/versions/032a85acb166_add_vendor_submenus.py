"""add_vendor_submenus

Revision ID: 032a85acb166
Revises: 5597cc2a28d9
Create Date: 2025-12-15 15:15:15.640757

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '032a85acb166'
down_revision: Union[str, None] = '5597cc2a28d9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    session = sa.orm.Session(bind=bind)
    
    # helper to process menus
    def upsert_menus(parent_code, menu_list):
        # Find Parent
        result = session.execute(sa.text("SELECT id FROM menus WHERE code = :code"), {"code": parent_code}).fetchone()
        if not result:
            print(f"{parent_code} menu not found. Skipping.")
            return
        parent_id = result[0]
        
        # Get SuperAdmin Role
        role_result = session.execute(sa.text("SELECT id FROM roles WHERE code = 'SUPERADMIN'")).fetchone()
        super_admin_role_id = role_result[0] if role_result else None

        for menu_data in menu_list:
            # Check exist
            exists = session.execute(
                sa.text("SELECT id FROM menus WHERE code = :code"), 
                {"code": menu_data["code"]}
            ).fetchone()
            
            menu_id = None
            if not exists:
                # Insert
                ins = session.execute(
                    sa.text("""
                        INSERT INTO menus (name, code, route, icon, sort_order, parent_id, menu_type, created_by, created_at, updated_at)
                        VALUES (:name, :code, :route, :icon, :sort_order, :parent_id, 'sub', 'system', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                        RETURNING id
                    """),
                    {**menu_data, "parent_id": parent_id}
                ).fetchone()
                menu_id = ins[0]
            else:
                menu_id = exists[0]
                # Ensure parent_id is correct (fix if previously flat)
                session.execute(
                    sa.text("UPDATE menus SET parent_id = :parent_id, menu_type = 'sub' WHERE id = :id"),
                    {"parent_id": parent_id, "id": menu_id}
                )

            # Ensure Permissions
            if super_admin_role_id and menu_id:
                has_perm = session.execute(
                    sa.text("SELECT 1 FROM role_rights WHERE role_id = :rid AND menu_id = :mid"),
                    {"rid": super_admin_role_id, "mid": menu_id}
                ).fetchone()
                
                if not has_perm:
                    session.execute(
                        sa.text("""
                            INSERT INTO role_rights (role_id, menu_id, can_view, can_create, can_edit, can_delete, created_by, created_at, updated_at)
                            VALUES (:rid, :mid, 1, 1, 1, 1, 'system', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                        """),
                        {"rid": super_admin_role_id, "mid": menu_id}
                    )

    # 1. Vendor Menus
    vendor_menus = [
        {"name": "Vendor Management", "code": "VENDOR_MGMT", "route": "/vendors/management", "icon": None, "sort_order": 1},
        {"name": "Vendor Categories", "code": "VENDOR_CATS", "route": "/vendors/categories", "icon": None, "sort_order": 2},
        {"name": "Vendor List", "code": "VENDOR_LIST", "route": "/vendors/list", "icon": None, "sort_order": 3},
        {"name": "Verified Vendors", "code": "VENDOR_VERIFIED", "route": "/vendors/verified", "icon": None, "sort_order": 4},
        {"name": "Vendor Onboarding", "code": "VENDOR_ONBOARDING", "route": "/vendors/onboarding", "icon": None, "sort_order": 5},
    ]
    upsert_menus("VENDORS", vendor_menus)

    # 2. Event Menus (Retry/Verify)
    event_menus = [
        {"name": "Event Categories", "code": "EVENT_CATEGORIES", "route": "/events/categories", "icon": None, "sort_order": 1},
        {"name": "Event Types", "code": "EVENT_TYPES", "route": "/events/types", "icon": None, "sort_order": 2},
        {"name": "Event List", "code": "EVENT_LIST", "route": "/events/list", "icon": None, "sort_order": 3},
        {"name": "Event Managers", "code": "EVENT_MANAGERS", "route": "/events/managers", "icon": None, "sort_order": 4},
    ]
    upsert_menus("EVENTS", event_menus)

    session.commit()


def downgrade() -> None:
    pass
