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
        # Prevent reseeding
        if db.query(Organization).first():
            print("Database already seeded!")
            return

        print("🚀 Starting database seeding...")

        # ============================
        # Organization & Branch
        # ============================
        org = Organization(
            name="Evination",
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

        # ============================
        # Roles
        # ============================
        super_admin_role = Role(
            name="Super Admin",
            code="SUPERADMIN",
            description="Full system access",
            created_by="system",
        )
        admin_role = Role(name="Admin", code="ADMIN", created_by="system")
        vendor_role = Role(name="Vendor", code="VENDOR", created_by="system")
        customer_role = Role(name="Customer", code="CUSTOMER", description="End customer", created_by="system")

        db.add_all([super_admin_role, admin_role, vendor_role, customer_role])
        db.flush()

        # ============================
        # Menus with Hierarchy
        # ============================
        print("📋 Creating Menus with Hierarchy...")
        
        menu_objects = {}
        
        # MAIN MENUS (parent_id = NULL)
        main_menus = [
            {"name": "Dashboard", "code": "DASHBOARD", "icon": "dashboard", "route": "/dashboard", "sort_order": 1},
            {"name": "Organization", "code": "ORGANIZATION", "icon": "building", "route": "/organization", "sort_order": 2},
            {"name": "Vendors", "code": "VENDORS", "icon": "store", "route": "/vendors", "sort_order": 6},
            {"name": "Events", "code": "EVENTS", "icon": "calendar", "route": "/events", "sort_order": 7},
            {"name": "Bidding", "code": "BIDDING", "icon": "activity", "route": "/bidding", "sort_order": 8},
            {"name": "Orders", "code": "ORDERS", "icon": "shopping-cart", "route": "/orders", "sort_order": 9},
            {"name": "Reports", "code": "REPORTS", "icon": "bar-chart", "route": "/reports", "sort_order": 10},
        ]
        
        for data in main_menus:
            menu = Menu(**data, menu_type="main", parent_id=None, created_by="system")
            db.add(menu)
            db.flush()
            menu_objects[menu.code] = menu
            print(f"   ✓ Main Menu: {menu.name} (ID={menu.id})")
        
        # SUB MENUS (parent_id = Organization.id)
        organization_menu_id = menu_objects["ORGANIZATION"].id
        
        sub_menus = [
            {"name": "Branches", "code": "BRANCHES", "icon": "map-pin", "route": "/organization/branches", "sort_order": 1, "parent_id": organization_menu_id},
            {"name": "Roles", "code": "ROLES", "icon": "shield", "route": "/organization/roles", "sort_order": 2, "parent_id": organization_menu_id},
            {"name": "Users", "code": "USERS", "icon": "users", "route": "/organization/users", "sort_order": 3, "parent_id": organization_menu_id},
        ]
        
        # Events Sub-Menus
        events_menu_id = menu_objects["EVENTS"].id
        sub_menus.append(
            {"name": "Categories", "code": "EVENT_CATEGORIES", "icon": "grid", "route": "/categories", "sort_order": 1, "parent_id": events_menu_id}
        )

        
        for data in sub_menus:
            menu = Menu(**data, menu_type="sub", created_by="system")
            db.add(menu)
            db.flush()
            menu_objects[menu.code] = menu
            print(f"   ✓ Sub Menu: {menu.name} (ID={menu.id}, Parent={menu.parent_id})")

        # ============================
        # Permissions (Backend Actions)
        # ============================
        print("🔑 Creating Permissions...")
        permissions_data = [
            # Organization permissions
            {"code": "organization.view", "name": "View Organization", "module": "organization", "action": "view"},
            {"code": "organization.update", "name": "Update Organization", "module": "organization", "action": "update"},
            
            # Branch permissions
            {"code": "branch.view", "name": "View Branches", "module": "branch", "action": "view"},
            {"code": "branch.create", "name": "Create Branches", "module": "branch", "action": "create"},
            {"code": "branch.update", "name": "Update Branches", "module": "branch", "action": "update"},
            {"code": "branch.delete", "name": "Delete Branches", "module": "branch", "action": "delete"},
            
            # User permissions
            {"code": "user.view", "name": "View Users", "module": "user", "action": "view"},
            {"code": "user.create", "name": "Create Users", "module": "user", "action": "create"},
            {"code": "user.update", "name": "Update Users", "module": "user", "action": "update"},
            {"code": "user.delete", "name": "Delete Users", "module": "user", "action": "delete"},

            # Role permissions
            {"code": "role.view", "name": "View Roles", "module": "role", "action": "view"},
            {"code": "role.create", "name": "Create Roles", "module": "role", "action": "create"},
            {"code": "role.update", "name": "Update Roles", "module": "role", "action": "update"},
            {"code": "role.delete", "name": "Delete Roles", "module": "role", "action": "delete"},
            {"code": "role.manage", "name": "Manage Role Permissions", "module": "role", "action": "manage"},

            # Vendor permissions
            {"code": "vendor.view", "name": "View Vendors", "module": "vendor", "action": "view"},
            {"code": "vendor.create", "name": "Create Vendors", "module": "vendor", "action": "create"},
            {"code": "vendor.update", "name": "Update Vendors", "module": "vendor", "action": "update"},
            {"code": "vendor.delete", "name": "Delete Vendors", "module": "vendor", "action": "delete"},

            # Event permissions
            {"code": "event.view", "name": "View Events", "module": "event", "action": "view"},
            {"code": "event.create", "name": "Create Events", "module": "event", "action": "create"},
            {"code": "event.update", "name": "Update Events", "module": "event", "action": "update"},
            {"code": "event.delete", "name": "Delete Events", "module": "event", "action": "delete"},
            
            # Booking permissions
            {"code": "booking.view", "name": "View Bookings", "module": "booking", "action": "view"},
            {"code": "booking.create", "name": "Create Bookings", "module": "booking", "action": "create"},
            {"code": "booking.update", "name": "Update Bookings", "module": "booking", "action": "update"},

            # Bidding permissions
            {"code": "bidding.view", "name": "View Bidding", "module": "bidding", "action": "view"},
            {"code": "bidding.create", "name": "Create Bids", "module": "bidding", "action": "create"},
            {"code": "bidding.update", "name": "Update Bids", "module": "bidding", "action": "update"},
            {"code": "bidding.delete", "name": "Delete Bids", "module": "bidding", "action": "delete"},

            # Order permissions
            {"code": "order.view", "name": "View Orders", "module": "order", "action": "view"},
            {"code": "order.create", "name": "Create Orders", "module": "order", "action": "create"},
            {"code": "order.update", "name": "Update Orders", "module": "order", "action": "update"},
            {"code": "order.delete", "name": "Delete Orders", "module": "order", "action": "delete"},
            
            # Report permissions
            {"code": "report.view", "name": "View Reports", "module": "report", "action": "view"},
            {"code": "report.export", "name": "Export Reports", "module": "report", "action": "export"},
            
            # Event Category permissions
            {"code": "event.category.view", "name": "View Event Categories", "module": "event", "action": "view"},
            {"code": "event.category.create", "name": "Create Event Categories", "module": "event", "action": "create"},
            {"code": "event.category.update", "name": "Update Event Categories", "module": "event", "action": "update"},
            {"code": "event.category.delete", "name": "Delete Event Categories", "module": "event", "action": "delete"},
    
            # Event Type permissions
            {"code": "event.type.view", "name": "View Event Types", "module": "event", "action": "view"},
            {"code": "event.type.create", "name": "Create Event Types", "module": "event", "action": "create"},
            {"code": "event.type.update", "name": "Update Event Types", "module": "event", "action": "update"},
            {"code": "event.type.delete", "name": "Delete Event Types", "module": "event", "action": "delete"},
    
            # Event Manager permissions
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

        # ============================
        # Menu-Permission Mapping
        # ============================
        print("🔗 Creating Menu-Permission Mappings...")
        menu_permission_mappings = [
            # Organization menu (main menu - view only)
            {"menu_code": "ORGANIZATION", "permission_code": "organization.view", "action_type": "view"},
            {"menu_code": "ORGANIZATION", "permission_code": "organization.update", "action_type": "edit"},
            
            # Branches sub-menu
            {"menu_code": "BRANCHES", "permission_code": "branch.view", "action_type": "view"},
            {"menu_code": "BRANCHES", "permission_code": "branch.create", "action_type": "create"},
            {"menu_code": "BRANCHES", "permission_code": "branch.update", "action_type": "edit"},
            {"menu_code": "BRANCHES", "permission_code": "branch.delete", "action_type": "delete"},
            
            # Users sub-menu
            {"menu_code": "USERS", "permission_code": "user.view", "action_type": "view"},
            {"menu_code": "USERS", "permission_code": "user.create", "action_type": "create"},
            {"menu_code": "USERS", "permission_code": "user.update", "action_type": "edit"},
            {"menu_code": "USERS", "permission_code": "user.delete", "action_type": "delete"},

            # Roles sub-menu
            {"menu_code": "ROLES", "permission_code": "role.view", "action_type": "view"},
            {"menu_code": "ROLES", "permission_code": "role.create", "action_type": "create"},
            {"menu_code": "ROLES", "permission_code": "role.update", "action_type": "edit"},
            {"menu_code": "ROLES", "permission_code": "role.delete", "action_type": "delete"},

            # Vendors main menu
            {"menu_code": "VENDORS", "permission_code": "vendor.view", "action_type": "view"},
            {"menu_code": "VENDORS", "permission_code": "vendor.create", "action_type": "create"},
            {"menu_code": "VENDORS", "permission_code": "vendor.update", "action_type": "edit"},
            {"menu_code": "VENDORS", "permission_code": "vendor.delete", "action_type": "delete"},

            # Events main menu
            {"menu_code": "EVENTS", "permission_code": "event.view", "action_type": "view"},
            {"menu_code": "EVENTS", "permission_code": "event.create", "action_type": "create"},
            {"menu_code": "EVENTS", "permission_code": "event.update", "action_type": "edit"},
            {"menu_code": "EVENTS", "permission_code": "event.delete", "action_type": "delete"},

            # Bidding main menu
            {"menu_code": "BIDDING", "permission_code": "bidding.view", "action_type": "view"},
            {"menu_code": "BIDDING", "permission_code": "bidding.create", "action_type": "create"},
            {"menu_code": "BIDDING", "permission_code": "bidding.update", "action_type": "edit"},
            {"menu_code": "BIDDING", "permission_code": "bidding.delete", "action_type": "delete"},

            # Orders main menu
            {"menu_code": "ORDERS", "permission_code": "order.view", "action_type": "view"},
            {"menu_code": "ORDERS", "permission_code": "order.create", "action_type": "create"},
            {"menu_code": "ORDERS", "permission_code": "order.update", "action_type": "edit"},
            {"menu_code": "ORDERS", "permission_code": "order.delete", "action_type": "delete"},
            
            # Reports main menu
            {"menu_code": "REPORTS", "permission_code": "report.view", "action_type": "view"},
            {"menu_code": "REPORTS", "permission_code": "report.export", "action_type": "create"},
            
            # Event Categories sub-menu
            {"menu_code": "EVENT_CATEGORIES", "permission_code": "event.category.view", "action_type": "view"},
            {"menu_code": "EVENT_CATEGORIES", "permission_code": "event.category.create", "action_type": "create"},
            {"menu_code": "EVENT_CATEGORIES", "permission_code": "event.category.update", "action_type": "edit"},
            {"menu_code": "EVENT_CATEGORIES", "permission_code": "event.category.delete", "action_type": "delete"},
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
        print(f"   ✓ {len(menu_permission_mappings)} mappings created")

        # ============================
        # Create SuperAdmin User
        # ============================
        print("👤 Creating SuperAdmin User...")
        admin_user = User(
            organization_id=org.id,
            branch_id=branch.id,
            role_id=super_admin_role.id,
            username="superadmin", # Changed from admin to distinct
            email="admin@evination.com",
            password_hash=hash_password("admin123"),
            first_name="Laxman",
            last_name="Admin",
            created_by="system",
        )
        db.add(admin_user)
        db.flush()

        # ============================
        # Assign ALL permissions to SuperAdmin
        # ============================
        print("🔐 Assigning SuperAdmin Permissions...")
        
        # UI Permissions (all menus including sub-menus)
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

        # Customer Permissions (Backend)
        customer_perms = [
            "event.category.view", 
            "booking.view", 
            "booking.create",
            "booking.update"
        ]
        
        # Vendor Permissions (Backend)
        vendor_perms = [
            "event.view",
            "bidding.view",
            "bidding.create",
            "bidding.update",
            "user.view" # To view their own profile
        ]
        
        for perm_code in vendor_perms:
            if perm_code in permission_objects:
                perm = permission_objects[perm_code]
                role_perm = RolePermission(
                    role_id=vendor_role.id,
                    permission_id=perm.id,
                    created_by="system",
                )
                db.add(role_perm)

        # SuperAdmin Backend permissions (ALL)
        for perm in permission_objects.values():
            role_perm = RolePermission(
                role_id=super_admin_role.id,
                permission_id=perm.id,
                created_by="system",
            )
            db.add(role_perm)

        # ============================
        # Create Customer User
        # ============================
        print("👤 Creating Customer User...")
        customer_user = User(
            organization_id=org.id,
            branch_id=branch.id,
            role_id=customer_role.id,
            username="mikeeyhen",
            email="mikeeyhen123@gmail.com",
            phone="9876543210",
            password_hash=hash_password("laxman123"),
            first_name="Mikeey",
            last_name="Hen",
            created_by="system",
        )
        db.add(customer_user)
        db.flush()
        
        # ============================
        # Create Vendor User & Profile
        # ============================
        print("👤 Creating Vendor User...")
        vendor_user = User(
            organization_id=org.id,
            branch_id=branch.id,
            role_id=vendor_role.id,
            username="laxmanvendor",
            email="laxman@gmail.com",
            phone="9888393339",
            password_hash=hash_password("laxman123"),
            first_name="Laxman",
            last_name="Vendor",
            created_by="system",
        )
        db.add(vendor_user)
        db.flush()
        
        # Vendor Profile
        from app.models.vendor_m import Vendor
        vendor_profile = Vendor(
            user_id=vendor_user.id,
            company_name="Laxman Events",
            company_type="Proprietorship",
            phone="9888393339",
            city="Hyderabad",
            status="approved", # Auto-approve for functionality
            is_verified=True,
            pan_number="ABCDE1234F", # Dummy for validation
            gst_number="36ABCDE1234F1Z5",
            created_by="system"
        )
        db.add(vendor_profile)

        db.commit()

        print("\n" + "="*60)
        print("✨ DATABASE SEEDED SUCCESSFULLY WITH PRODUCTION USERS!")
        print("="*60)
        print(f"🔐 Credentials Set:")
        print(f"   1. Super Admin: laxmanlaxman1629@gmail.com / laxman123")
        print(f"   2. Customer:    mikeeyhen123@gmail.com / laxman123")
        print(f"   3. Vendor:      laxman@gmail.com / laxman123")
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