from sqlalchemy.orm import Session
from app.models.menu import Menu
from app.models.role import Role, role_menus
from sqlalchemy import insert, update, and_

def seed_menus(db: Session):
    """Seed default system menus and assign to roles"""
    
    # Define menus and their access roles
    # HQ_ADMIN gets everything by default usually, but we define explicitly
    menus_data = [
        {
            "name": "Dashboard",
            "code": "dashboard",
            "icon": "dashboard",
            "route": "/dashboard",
            "sequence": 1,
            "roles": ["HQ_ADMIN", "STORE_ADMIN", "PHARMACIST"]
        },
        {
            "name": "Inventory",
            "code": "inventory",
            "icon": "inventory",
            "route": "/inventory",
            "sequence": 2,
            "roles": ["HQ_ADMIN", "STORE_ADMIN", "PHARMACIST"],
            "children": [
                 {"name": "Medicines", "code": "inventory-medicines", "route": "/inventory/medicines", "roles": ["HQ_ADMIN", "STORE_ADMIN", "PHARMACIST"]},
                 {"name": "Stock Adjustment", "code": "inventory-adjustment", "route": "/inventory/adjustment", "roles": ["HQ_ADMIN", "STORE_ADMIN"]},
                 {"name": "Suppliers", "code": "inventory-suppliers", "route": "/inventory/suppliers", "roles": ["HQ_ADMIN", "STORE_ADMIN"]},
            ]
        },
        {
            "name": "POS / Sales",
            "code": "pos",
            "icon": "point_of_sale",
            "route": "/pos",
            "sequence": 3,
            "roles": ["HQ_ADMIN", "STORE_ADMIN", "PHARMACIST"]
        },
        {
            "name": "Orders",
            "code": "orders",
            "icon": "shopping_cart",
            "route": "/orders",
            "sequence": 4,
            "roles": ["HQ_ADMIN", "STORE_ADMIN", "PHARMACIST"]
        },
        {
            "name": "Prescriptions",
            "code": "prescriptions",
            "icon": "prescription",
            "route": "/prescriptions",
            "sequence": 5,
            "roles": ["HQ_ADMIN", "STORE_ADMIN", "PHARMACIST"]
        },
        {
            "name": "Organization",
            "code": "organization",
            "icon": "business",
            "route": "/organization",
            "sequence": 6,
            "roles": ["HQ_ADMIN"],
            "children": [
                {"name": "Stores", "code": "org-stores", "route": "/organization/stores", "roles": ["HQ_ADMIN"]},
                {"name": "Users", "code": "org-users", "route": "/organization/users", "roles": ["HQ_ADMIN"]},
                {"name": "Roles", "code": "org-roles", "route": "/organization/roles", "roles": ["HQ_ADMIN"]},
            ]
        },
        {
            "name": "Reports",
            "code": "reports",
            "icon": "assessment",
            "route": "/reports",
            "sequence": 7,
            "roles": ["HQ_ADMIN", "STORE_ADMIN"]
        },
        {
            "name": "Settings",
            "code": "settings",
            "icon": "settings",
            "route": "/settings",
            "sequence": 99,
            "roles": ["HQ_ADMIN", "STORE_ADMIN"]
        }
    ]

    print("Seeding Menus...")
    
    for menu_item in menus_data:
        # Create Parent
        parent = upsert_menu(db, menu_item)
        assign_roles(db, parent, menu_item.get("roles", []))
        
        # Create Children
        if "children" in menu_item:
            for child_item in menu_item["children"]:
                child = upsert_menu(db, child_item, parent_id=parent.id, level=2)
                assign_roles(db, child, child_item.get("roles", []))
    
    db.commit()
    print("  [OK] Menus seeded and assigned")

def upsert_menu(db: Session, data: dict, parent_id=None, level=1):
    menu = db.query(Menu).filter(Menu.code == data["code"]).first()
    if not menu:
        menu = Menu(
            name=data["name"],
            code=data["code"],
            icon=data.get("icon"),
            route=data.get("route"),
            sequence=data.get("sequence", 0),
            parent_id=parent_id,
            level=level,
            is_visible=True
        )
        db.add(menu)
        db.flush() # Flush to get ID
    else:
        # Update existing fields if needed
        menu.name = data["name"]
        menu.route = data.get("route")
        menu.parent_id = parent_id
        db.add(menu)
        db.flush()
    return menu

def assign_roles(db: Session, menu: Menu, role_codes: list):
    if not role_codes:
        return
        
    roles = db.query(Role).filter(Role.code.in_(role_codes)).all()
    
    # We need to manage the many-to-many relationship
    # Simple approach: ensure all requested roles are in menu.roles
    # Note: This doesn't remove roles if removed from list, but good for seeding
    
    current_role_ids = {r.id for r in menu.roles}
    
    for role in roles:
        # Determine strict permissions
        is_hq = (role.code == "HQ_ADMIN")
        # For Store Admin, allow create/update mostly? Let's restrict to HQ for now or defined logic.
        # But we MUST give HQ_ADMIN full access.
        
        can_view = True
        can_create = is_hq
        can_update = is_hq
        can_delete = is_hq
        
        # Check existence and upsert
        exists = db.query(role_menus).filter(
            and_(role_menus.c.role_id == role.id, role_menus.c.menu_id == menu.id)
        ).first()
        
        if not exists:
            stmt = insert(role_menus).values(
                role_id=role.id,
                menu_id=menu.id,
                can_view=can_view,
                can_create=can_create,
                can_update=can_update,
                can_delete=can_delete
            )
            db.execute(stmt)
        else:
            # Enforce HQ_ADMIN full permissions on existing records
            if is_hq:
                stmt = update(role_menus).where(
                    and_(role_menus.c.role_id == role.id, role_menus.c.menu_id == menu.id)
                ).values(
                    can_create=True,
                    can_update=True,
                    can_delete=True
                )
                db.execute(stmt)
