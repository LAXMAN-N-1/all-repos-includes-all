"""add_event_submenus

Revision ID: 5597cc2a28d9
Revises: 404ea9acd6c1
Create Date: 2025-12-15 15:12:53.914788

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '5597cc2a28d9'
down_revision: Union[str, None] = '404ea9acd6c1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Get database connection
    bind = op.get_bind()
    session = sa.orm.Session(bind=bind)
    
    # 2. Find Parent 'EVENTS' Menu
    result = session.execute(sa.text("SELECT id FROM menus WHERE code = 'EVENTS'")).fetchone()
    if not result:
        print("EVENTS menu not found. Skipping migration.")
        return
    events_menu_id = result[0]

    # 3. Define Sub-Menus
    sub_menus = [
        {"name": "Event Categories", "code": "EVENT_CATEGORIES", "route": "/events/categories", "icon": None, "sort_order": 1},
        {"name": "Event Types", "code": "EVENT_TYPES", "route": "/events/types", "icon": None, "sort_order": 2},
        {"name": "Event List", "code": "EVENT_LIST", "route": "/events/list", "icon": None, "sort_order": 3},
        {"name": "Event Managers", "code": "EVENT_MANAGERS", "route": "/events/managers", "icon": None, "sort_order": 4},
    ]

    # 4. Insert Sub-Menus and existing Role Rights
    # Get Super Admin Role ID
    role_result = session.execute(sa.text("SELECT id FROM roles WHERE code = 'SUPERADMIN'")).fetchone()
    super_admin_role_id = role_result[0] if role_result else None

    for menu_data in sub_menus:
        # Check if exists
        exists = session.execute(
            sa.text("SELECT id FROM menus WHERE code = :code"), 
            {"code": menu_data["code"]}
        ).fetchone()
        
        if not exists:
            # Insert Menu
            insert_result = session.execute(
                sa.text("""
                    INSERT INTO menus (name, code, route, icon, sort_order, parent_id, menu_type, created_by, created_at, updated_at)
                    VALUES (:name, :code, :route, :icon, :sort_order, :parent_id, 'sub', 'system', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                    RETURNING id
                """),
                {
                    **menu_data, 
                    "parent_id": events_menu_id
                }
            ).fetchone()
            
            new_menu_id = insert_result[0]
            
            # Grant access to Super Admin (if exists)
            if super_admin_role_id:
                session.execute(
                    sa.text("""
                        INSERT INTO role_rights (role_id, menu_id, can_view, can_create, can_edit, can_delete, created_by, created_at, updated_at)
                        VALUES (:role_id, :menu_id, 1, 1, 1, 1, 'system', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                    """),
                    {"role_id": super_admin_role_id, "menu_id": new_menu_id}
                )

    session.commit()


def downgrade() -> None:
    bind = op.get_bind()
    session = sa.orm.Session(bind=bind)
    
    # Delete sub-menus (cascade should handle role_rights usually, but manual cleanup is safer)
    codes = ['EVENT_CATEGORIES', 'EVENT_TYPES', 'EVENT_LIST', 'EVENT_MANAGERS']
    for code in codes:
        session.execute(sa.text("DELETE FROM menus WHERE code = :code"), {"code": code})
    
    session.commit()
