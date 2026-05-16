"""
Admin Roles & Permissions API
"""
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session

from app.api import deps
from app.models.user import User
from app.models.admin_models import AdminRole, AdminRolePermission, AdminActivityLog
from app.schemas.admin_schemas import RoleCreate, RoleUpdate, RoleOut, ModuleInfo

router = APIRouter()

# Master module list — drives the permission matrix UI
MODULES = [
    {"key": "dashboard",       "label": "Dashboard",              "icon": "dashboard"},
    {"key": "customers",       "label": "Customers",              "icon": "people"},
    {"key": "orders",          "label": "Orders",                 "icon": "receipt"},
    {"key": "products",        "label": "Products",               "icon": "inventory_2"},
    {"key": "inventory",       "label": "Inventory",              "icon": "warehouse"},
    {"key": "invoices",        "label": "Invoices & Billing",     "icon": "receipt_long"},
    {"key": "delivery",        "label": "Delivery",               "icon": "local_shipping"},
    {"key": "reports",         "label": "Reports & Analytics",    "icon": "analytics"},
    {"key": "store_locations", "label": "Store Locations",        "icon": "store"},
    {"key": "support",         "label": "Support & Tickets",      "icon": "support_agent"},
    {"key": "promotions",      "label": "Promotions & Marketing", "icon": "campaign"},
    {"key": "admin_users",     "label": "Admin Users",            "icon": "admin_panel_settings"},
]


def _role_to_dict(role: AdminRole, db: Session) -> dict:
    user_count = db.query(User).filter(User.role_id == role.id, User.is_deleted == False).count()
    return {
        "id": role.id,
        "name": role.name,
        "display_name": role.display_name,
        "description": role.description,
        "color": role.color,
        "is_system_role": role.is_system_role,
        "is_active": role.is_active,
        "user_count": user_count,
        "permissions": [
            {
                "id": p.id, "module": p.module,
                "can_view": p.can_view, "can_create": p.can_create,
                "can_edit": p.can_edit, "can_delete": p.can_delete,
                "can_export": p.can_export,
            }
            for p in role.permissions
        ],
    }


# ─── Module List ─────────────────────────────────────────────────
@router.get("/modules")
def get_modules(current_user: User = Depends(deps.get_current_active_staff)):
    return MODULES


# ─── List Roles ──────────────────────────────────────────────────
@router.get("/")
def list_roles(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    roles = db.query(AdminRole).filter(AdminRole.is_active == True).order_by(AdminRole.id).all()
    return [_role_to_dict(r, db) for r in roles]


# ─── Get Role ────────────────────────────────────────────────────
@router.get("/{role_id}")
def get_role(
    role_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    role = db.query(AdminRole).filter(AdminRole.id == role_id).first()
    if not role:
        raise HTTPException(404, "Role not found")
    return _role_to_dict(role, db)


# ─── Create Role ─────────────────────────────────────────────────
@router.post("/")
def create_role(
    body: RoleCreate,
    request: Request,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    # Check unique name
    if db.query(AdminRole).filter(AdminRole.name == body.name).first():
        raise HTTPException(409, "Role name already exists")

    role = AdminRole(
        name=body.name,
        display_name=body.display_name,
        description=body.description,
        color=body.color,
    )
    db.add(role)
    db.flush()

    # Add permissions
    for p in body.permissions:
        perm = AdminRolePermission(
            role_id=role.id, module=p.module,
            can_view=p.can_view, can_create=p.can_create,
            can_edit=p.can_edit, can_delete=p.can_delete,
            can_export=p.can_export,
        )
        db.add(perm)

    db.commit()
    db.refresh(role)

    # Audit log
    log = AdminActivityLog(
        admin_user_id=current_user.id, module="admin_users", action_type="create",
        action_label=f"Created role '{body.display_name}'",
        target_id=str(role.id), target_label=body.display_name,
        ip_address=request.client.host if request.client else None,
    )
    db.add(log)
    db.commit()

    return _role_to_dict(role, db)


# ─── Update Role ─────────────────────────────────────────────────
@router.put("/{role_id}")
def update_role(
    role_id: int,
    body: RoleUpdate,
    request: Request,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    role = db.query(AdminRole).filter(AdminRole.id == role_id).first()
    if not role:
        raise HTTPException(404, "Role not found")

    before = _role_to_dict(role, db)

    # Update metadata
    if body.name is not None:
        role.name = body.name
    if body.display_name is not None:
        role.display_name = body.display_name
    if body.description is not None:
        role.description = body.description
    if body.color is not None:
        role.color = body.color

    # If permissions provided, delete-and-reinsert
    if body.permissions is not None:
        db.query(AdminRolePermission).filter(AdminRolePermission.role_id == role_id).delete()
        for p in body.permissions:
            perm = AdminRolePermission(
                role_id=role_id, module=p.module,
                can_view=p.can_view, can_create=p.can_create,
                can_edit=p.can_edit, can_delete=p.can_delete,
                can_export=p.can_export,
            )
            db.add(perm)

    db.commit()
    db.refresh(role)

    after = _role_to_dict(role, db)

    log = AdminActivityLog(
        admin_user_id=current_user.id, module="admin_users", action_type="update",
        action_label=f"Updated role '{role.display_name}'",
        target_id=str(role.id), target_label=role.display_name,
        before_data=before, after_data=after,
        ip_address=request.client.host if request.client else None,
    )
    db.add(log)
    db.commit()

    return _role_to_dict(role, db)


# ─── Delete Role ─────────────────────────────────────────────────
@router.delete("/{role_id}")
def delete_role(
    role_id: int,
    request: Request,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_staff),
):
    role = db.query(AdminRole).filter(AdminRole.id == role_id).first()
    if not role:
        raise HTTPException(404, "Role not found")
    if role.is_system_role:
        raise HTTPException(400, "Cannot delete a system role")

    assigned = db.query(User).filter(User.role_id == role_id, User.is_deleted == False).count()
    if assigned > 0:
        raise HTTPException(409, f"Cannot delete: {assigned} user(s) are assigned to this role")

    role_name = role.display_name
    db.delete(role)
    db.commit()

    log = AdminActivityLog(
        admin_user_id=current_user.id, module="admin_users", action_type="delete",
        action_label=f"Deleted role '{role_name}'",
        target_id=str(role_id), target_label=role_name,
        ip_address=request.client.host if request.client else None,
    )
    db.add(log)
    db.commit()

    return {"message": f"Role '{role_name}' deleted"}
