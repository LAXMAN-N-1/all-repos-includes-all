
# ============================================
# COMPLETE UPDATED seed_data.py
# ============================================

from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import (
    Organization, Branch, Role, Menu, User,
    RoleRight, Permission, MenuPermission, RolePermission
)
from app.utils.password_utils import hash_password


def seed_database():
    db = SessionLocal()

    try:
        if db.query(Organization).first():
            print("Database already seeded!")
            return

        print("🚀 Starting database seeding...")

        # Organization & Branch
        org = Organization(
            name="Evenation",
            code="EVI",
            email="info@evi.com",
            phone="1234567890",
            created_by="system",
        )
        db.add(org)
        db.flush()

        branch = Branch(
            organization_id=org.id,
            name="Head Office",
            code="HO",
            is_head_office=1,
            city="Bangalore",
            created_by="system",
        )
        db.add(branch)
        db.flush()

        # Roles
        super_admin_role = Role(
            name="Super Admin",
            code="SUPERADMIN",
            description="Full system access",
            created_by="system",
        )
        admin_role = Role(name="Admin", code="ADMIN", created_by="system")
        vendor_role = Role(name="Vendor", code="VENDOR", created_by="system")
        consumer_role = Role(name="Consumer", code="CONSUMER", created_by="system")  # NEW

        db.add_all([super_admin_role, admin_role, vendor_role, consumer_role])
        db.flush()

        # Menus
        print("📋 Creating Menus with Hierarchy...")
        
        menu_objects = {}
        
        main_menus = [
            {"name": "Dashboard", "code": "DASHBOARD", "icon": "dashboard", "route": "/dashboard", "sort_order": 1},
            {"name": "Organization", "code": "ORGANIZATION", "icon": "building", "route": "/organization", "sort_order": 2},
            {"name": "Vendors", "code": "VENDORS", "icon": "store", "route": "/vendors", "sort_order": 6},
            {"name": "Events", "code": "EVENTS", "icon": "calendar", "route": "/events", "sort_order": 7},
            {"name": "Bidding", "code": "BIDDING", "icon": "activity", "route": "/bidding", "sort_order": 8},
            {"name": "Services", "code": "SERVICES", "icon": "briefcase", "route": "/services", "sort_order": 9},  # NEW
            {"name": "Orders", "code": "ORDERS", "icon": "shopping-cart", "route": "/orders", "sort_order": 10},
            {"name": "Reports", "code": "REPORTS", "icon": "bar-chart", "route": "/reports", "sort_order": 11},
        ]
        
        for data in main_menus:
            menu = Menu(**data, menu_type="main", parent_id=None, created_by="system")
            db.add(menu)
            db.flush()
            menu_objects[menu.code] = menu
            print(f"   ✓ Main Menu: {menu.name}")
        
        organization_menu_id = menu_objects["ORGANIZATION"].id
        
        sub_menus = [
            {"name": "Branches", "code": "BRANCHES", "icon": "map-pin", "route": "/organization/branches", "sort_order": 1, "parent_id": organization_menu_id},
            {"name": "Roles", "code": "ROLES", "icon": "shield", "route": "/organization/roles", "sort_order": 2, "parent_id": organization_menu_id},
            {"name": "Users", "code": "USERS", "icon": "users", "route": "/organization/users", "sort_order": 3, "parent_id": organization_menu_id},
        ]
        
        for data in sub_menus:
            menu = Menu(**data, menu_type="sub", created_by="system")
            db.add(menu)
            db.flush()
            menu_objects[menu.code] = menu
            print(f"   ✓ Sub Menu: {menu.name}")

        # Permissions
        print("🔑 Creating Permissions...")
        permissions_data = [
            # Organization
            {"code": "organization.view", "name": "View Organization", "module": "organization", "action": "view"},
            {"code": "organization.update", "name": "Update Organization", "module": "organization", "action": "update"},
            
            # Branch
            {"code": "branch.view", "name": "View Branches", "module": "branch", "action": "view"},
            {"code": "branch.create", "name": "Create Branches", "module": "branch", "action": "create"},
            {"code": "branch.update", "name": "Update Branches", "module": "branch", "action": "update"},
            {"code": "branch.delete", "name": "Delete Branches", "module": "branch", "action": "delete"},
            
            # User
            {"code": "user.view", "name": "View Users", "module": "user", "action": "view"},
            {"code": "user.create", "name": "Create Users", "module": "user", "action": "create"},
            {"code": "user.update", "name": "Update Users", "module": "user", "action": "update"},
            {"code": "user.delete", "name": "Delete Users", "module": "user", "action": "delete"},

            # Role
            {"code": "role.view", "name": "View Roles", "module": "role", "action": "view"},
            {"code": "role.create", "name": "Create Roles", "module": "role", "action": "create"},
            {"code": "role.update", "name": "Update Roles", "module": "role", "action": "update"},
            {"code": "role.delete", "name": "Delete Roles", "module": "role", "action": "delete"},
            {"code": "role.manage", "name": "Manage Role Permissions", "module": "role", "action": "manage"},

            # Vendor
            {"code": "vendor.view", "name": "View Vendors", "module": "vendor", "action": "view"},
            {"code": "vendor.create", "name": "Create Vendors", "module": "vendor", "action": "create"},
            {"code": "vendor.update", "name": "Update Vendors", "module": "vendor", "action": "update"},
            {"code": "vendor.delete", "name": "Delete Vendors", "module": "vendor", "action": "delete"},

            # Event
            {"code": "event.view", "name": "View Events", "module": "event", "action": "view"},
            {"code": "event.create", "name": "Create Events", "module": "event", "action": "create"},
            {"code": "event.update", "name": "Update Events", "module": "event", "action": "update"},
            {"code": "event.delete", "name": "Delete Events", "module": "event", "action": "delete"},

            # NEW: Service permissions
            {"code": "service.view", "name": "View Services", "module": "service", "action": "view"},
            {"code": "service.create", "name": "Create Services", "module": "service", "action": "create"},
            {"code": "service.update", "name": "Update Services", "module": "service", "action": "update"},
            {"code": "service.delete", "name": "Delete Services", "module": "service", "action": "delete"},

            # NEW: Bidding permissions
            {"code": "bidding.view", "name": "View Bids", "module": "bidding", "action": "view"},
            {"code": "bidding.update", "name": "Review & Shortlist Bids", "module": "bidding", "action": "update"},

            # Order
            {"code": "order.view", "name": "View Orders", "module": "order", "action": "view"},
            {"code": "order.create", "name": "Create Orders", "module": "order", "action": "create"},
            {"code": "order.update", "name": "Update Orders", "module": "order", "action": "update"},
            {"code": "order.delete", "name": "Delete Orders", "module": "order", "action": "delete"},
            
            # Report
            {"code": "report.view", "name": "View Reports", "module": "report", "action": "view"},
            {"code": "report.export", "name": "Export Reports", "module": "report", "action": "export"},
            
            # Event Category
            {"code": "event.category.view", "name": "View Event Categories", "module": "event", "action": "view"},
            {"code": "event.category.create", "name": "Create Event Categories", "module": "event", "action": "create"},
            {"code": "event.category.update", "name": "Update Event Categories", "module": "event", "action": "update"},
            {"code": "event.category.delete", "name": "Delete Event Categories", "module": "event", "action": "delete"},
    
            # Event Type
            {"code": "event.type.view", "name": "View Event Types", "module": "event", "action": "view"},
            {"code": "event.type.create", "name": "Create Event Types", "module": "event", "action": "create"},
            {"code": "event.type.update", "name": "Update Event Types", "module": "event", "action": "update"},
            {"code": "event.type.delete", "name": "Delete Event Types", "module": "event", "action": "delete"},
    
            # Event Manager
            {"code": "event.manager.view", "name": "View Event Managers", "module": "event", "action": "view"},
            {"code": "event.manager.create", "name": "Create Event Managers", "module": "event", "action": "create"},
            {"code": "event.manager.update", "name": "Update Event Managers", "module": "event", "action": "update"},
        ]

        permission_objects = {}
        for perm_data in permissions_data:
            perm = Permission(**perm_data, created_by="system")
            db.add(perm)
            db.flush()
            permission_objects[perm.code] = perm
        print(f"   ✓ {len(permission_objects)} permissions created")

        # Menu-Permission Mappings
        menu_permission_mappings = [
            {"menu_code": "ORGANIZATION", "permission_code": "organization.view", "action_type": "view"},
            {"menu_code": "ORGANIZATION", "permission_code": "organization.update", "action_type": "edit"},
            {"menu_code": "BRANCHES", "permission_code": "branch.view", "action_type": "view"},
            {"menu_code": "BRANCHES", "permission_code": "branch.create", "action_type": "create"},
            {"menu_code": "BRANCHES", "permission_code": "branch.update", "action_type": "edit"},
            {"menu_code": "BRANCHES", "permission_code": "branch.delete", "action_type": "delete"},
            {"menu_code": "USERS", "permission_code": "user.view", "action_type": "view"},
            {"menu_code": "USERS", "permission_code": "user.create", "action_type": "create"},
            {"menu_code": "USERS", "permission_code": "user.update", "action_type": "edit"},
            {"menu_code": "USERS", "permission_code": "user.delete", "action_type": "delete"},
            {"menu_code": "ROLES", "permission_code": "role.view", "action_type": "view"},
            {"menu_code": "ROLES", "permission_code": "role.create", "action_type": "create"},
            {"menu_code": "ROLES", "permission_code": "role.update", "action_type": "edit"},
            {"menu_code": "ROLES", "permission_code": "role.delete", "action_type": "delete"},
            {"menu_code": "VENDORS", "permission_code": "vendor.view", "action_type": "view"},
            {"menu_code": "VENDORS", "permission_code": "vendor.create", "action_type": "create"},
            {"menu_code": "VENDORS", "permission_code": "vendor.update", "action_type": "edit"},
            {"menu_code": "VENDORS", "permission_code": "vendor.delete", "action_type": "delete"},
            {"menu_code": "EVENTS", "permission_code": "event.view", "action_type": "view"},
            {"menu_code": "EVENTS", "permission_code": "event.create", "action_type": "create"},
            {"menu_code": "EVENTS", "permission_code": "event.update", "action_type": "edit"},
            {"menu_code": "EVENTS", "permission_code": "event.delete", "action_type": "delete"},
            {"menu_code": "BIDDING", "permission_code": "bidding.view", "action_type": "view"},
            {"menu_code": "BIDDING", "permission_code": "bidding.update", "action_type": "edit"},
            # NEW: Service menu
            {"menu_code": "SERVICES", "permission_code": "service.view", "action_type": "view"},
            {"menu_code": "SERVICES", "permission_code": "service.create", "action_type": "create"},
            {"menu_code": "SERVICES", "permission_code": "service.update", "action_type": "edit"},
            {"menu_code": "SERVICES", "permission_code": "service.delete", "action_type": "delete"},
            {"menu_code": "ORDERS", "permission_code": "order.view", "action_type": "view"},
            {"menu_code": "ORDERS", "permission_code": "order.create", "action_type": "create"},
            {"menu_code": "ORDERS", "permission_code": "order.update", "action_type": "edit"},
            {"menu_code": "ORDERS", "permission_code": "order.delete", "action_type": "delete"},
            {"menu_code": "REPORTS", "permission_code": "report.view", "action_type": "view"},
            {"menu_code": "REPORTS", "permission_code": "report.export", "action_type": "create"},
        ]

        for mapping in menu_permission_mappings:
            menu = menu_objects[mapping["menu_code"]]
            perm = permission_objects[mapping["permission_code"]]
            menu_perm = MenuPermission(
                menu_id=menu.id,
                permission_id=perm.id,
                action_type=mapping["action_type"],
                created_by="system",
            )
            db.add(menu_perm)

        db.flush()

        # Create SuperAdmin User
        admin_user = User(
            organization_id=org.id,
            branch_id=branch.id,
            role_id=super_admin_role.id,
            username="admin",
            email="admin@evenation.com",
            password_hash=hash_password("admin123"),
            first_name="Super",
            last_name="Admin",
            created_by="system",
        )
        db.add(admin_user)
        db.flush()

        # Assign ALL permissions to SuperAdmin
        for menu in menu_objects.values():
            role_right = RoleRight(
                role_id=super_admin_role.id,
                menu_id=menu.id,
                can_view=True,
                can_create=True,
                can_edit=True,
                can_delete=True,
                created_by="system",
            )
            db.add(role_right)

        for perm in permission_objects.values():
            role_perm = RolePermission(
                role_id=super_admin_role.id,
                permission_id=perm.id,
                created_by="system",
            )
            db.add(role_perm)

        db.commit()

        print("\n" + "="*60)
        print("✨ DATABASE SEEDED SUCCESSFULLY!")
        print("="*60)
        print(f"🔐 Login Credentials:")
        print(f"   Username: admin")
        print(f"   Password: admin123")
        print("="*60)

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()

    finally:
        db.close()


if __name__ == "__main__":
    seed_database()