from sqlalchemy.orm import Session
from app.models.permission import Permission
from app.models.role import Role

def seed_permissions(db: Session):
    """Seed default system permissions and assign to roles"""
    
    # Define resources and actions
    resources = [
        "users", "roles", "permissions", 
        "organizations", "stores",
        "inventory", "orders", "prescriptions",
        "reports", "settings"
    ]
    
    actions = ["view", "create", "update", "delete"]
    
    # Generate permission codes
    permissions_data = []
    for resource in resources:
        for action in actions:
            permissions_data.append({
                "name": f"{action.title()} {resource.title()}",
                "code": f"{resource}:{action}",
                "resource": resource,
                "action": action,
                "description": f"Allow {action} action on {resource}"
            })

    print(f"Seeding {len(permissions_data)} Permissions...")
    
    created_permissions = []
    for perm_data in permissions_data:
        perm = db.query(Permission).filter(Permission.code == perm_data["code"]).first()
        if not perm:
            perm = Permission(
                name=perm_data["name"],
                code=perm_data["code"],
                resource=perm_data["resource"],
                action=perm_data["action"],
                description=perm_data["description"]
            )
            db.add(perm)
            db.flush()
        created_permissions.append(perm)
    
    db.commit()
    
    # Assign permissions to roles
    assign_permissions(db, "HQ_ADMIN", created_permissions) # All permissions
    
    # Store Admin (Exclude global org/role management)
    store_admin_perms = [p for p in created_permissions if p.resource not in ["organizations", "roles", "permissions"]]
    assign_permissions(db, "STORE_ADMIN", store_admin_perms)
    
    # Pharmacist (Operational)
    pharmacist_resources = ["inventory", "orders", "prescriptions"]
    pharmacist_perms = [p for p in created_permissions if p.resource in pharmacist_resources]
    assign_permissions(db, "PHARMACIST", pharmacist_perms)
    
    print("  [OK] Permissions seeded and assigned")

def assign_permissions(db: Session, role_code: str, permissions: list):
    role = db.query(Role).filter(Role.code == role_code).first()
    if not role:
        return
        
    current_perm_ids = {p.id for p in role.permissions}
    for perm in permissions:
        if perm.id not in current_perm_ids:
            role.permissions.append(perm)
    db.commit()
