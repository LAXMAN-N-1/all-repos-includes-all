from __future__ import annotations

from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select

from app.api import deps
from app.models.admin_user import AdminUser
from app.models.rbac import Permission, Role
from app.models.user import User
from app.schemas.menu import MenuCreate, MenuRead, MenuUpdate
from app.schemas.rbac import (
    AccessPathCreate,
    AccessPathRead,
    AccessPathUpdate,
    BulkRoleAssignRequest,
    BulkRoleAssignResponse,
    ModulePermission,
    PermissionCheckResponse,
    PermissionCreate,
    PermissionListResponse,
    PermissionMatrix,
    PermissionRead,
    RoleCreate,
    RoleDuplicate,
    RoleHierarchy,
    RolePermissionsResponse,
    RolePermissionAssign,
    RolePermissionUpdateResponse,
    RoleRead,
    RoleTransferRequest,
    RoleTransferResponse,
    RoleUpdate,
    RoleUsersListResponse,
    RoleAuditLog,
    UserRoleAssign,
    UserRoleAssignmentResponse,
    UserRoleDetail,
)
from app.schemas.role_right import RoleRightCreate, RoleRightRead, RoleRightUpdate
from app.services.access_control_service import access_control_service
from app.services.role_service import role_service

router = APIRouter()


@router.get("/roles", response_model=List[RoleRead])
def list_roles(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:read")),
):
    roles = access_control_service.list_roles(
        db,
        context,
        skip=skip,
        limit=limit,
        active_only=active_only,
    )
    role_ids = [role.id for role in roles if role.id is not None]
    user_counts, active_user_counts = role_service.get_role_user_counts(db, role_ids)

    result: list[RoleRead] = []
    for role in roles:
        item = RoleRead.model_validate(role)
        item.permission_count = len(role.permissions or [])
        item.user_count = user_counts.get(role.id or 0, 0)
        item.active_user_count = active_user_counts.get(role.id or 0, 0)
        result.append(item)
    return result


@router.get("/roles/{role_id}", response_model=RoleRead)
def get_role(
    role_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:read")),
):
    role = db.exec(select(Role).where(Role.id == role_id)).first()
    if not role:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
    if context.scope == "tenant" and role.dealer_id != (context.dealer_id or context.tenant_id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="rbac_scope_forbidden")
    item = RoleRead.model_validate(role)
    item.permission_count = len(role.permissions or [])
    user_counts, active_user_counts = role_service.get_role_user_counts(db, [role_id])
    item.user_count = user_counts.get(role_id, 0)
    item.active_user_count = active_user_counts.get(role_id, 0)
    return item


@router.post("/roles", response_model=RoleRead, status_code=status.HTTP_201_CREATED)
def create_role(
    role_in: RoleCreate,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:write")),
):
    role = access_control_service.create_role(db, context, role_in)
    item = RoleRead.model_validate(role)
    item.permission_count = len(role.permissions or [])
    return item


@router.put("/roles/{role_id}", response_model=RoleRead)
def update_role(
    role_id: int,
    role_in: RoleUpdate,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:write")),
):
    role = access_control_service.update_role(db, context, role_id, role_in)
    if not role:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
    item = RoleRead.model_validate(role)
    item.permission_count = len(role.permissions or [])
    return item


@router.delete("/roles/{role_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_role(
    role_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:write")),
):
    deleted = access_control_service.delete_role(db, context, role_id)
    if not deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
    return None


@router.get("/permissions", response_model=List[PermissionRead])
def list_permissions(
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:permissions:read")),
):
    _ = context
    return access_control_service.list_permissions(db)


@router.post("/permissions", response_model=PermissionRead, status_code=status.HTTP_201_CREATED)
def create_permission(
    payload: PermissionCreate,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(
        deps.require_rbac_permission("rbac:permissions:write", require_global=True)
    ),
):
    _ = context
    existing = db.exec(select(Permission).where(Permission.slug == payload.slug)).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="permission_exists")
    permission = Permission.model_validate(payload)
    return access_control_service.create_permission(db, permission)


@router.get("/permissions/modules", response_model=List[ModulePermission])
def list_permission_modules(
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:permissions:read")),
):
    _ = context
    return access_control_service.list_permission_modules(db)


@router.get("/roles/{role_id}/permissions", response_model=RolePermissionsResponse)
def get_role_permissions(
    role_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:read")),
):
    return access_control_service.get_role_permissions(db, context, role_id)


@router.post("/roles/{role_id}/permissions", response_model=RolePermissionUpdateResponse)
def assign_role_permissions(
    role_id: int,
    payload: RolePermissionAssign,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:write")),
):
    return access_control_service.assign_role_permissions(
        db,
        context,
        role_id=role_id,
        permissions=payload.permissions,
        mode=payload.mode,
    )


@router.get("/assignments/users/{user_id}/roles", response_model=List[UserRoleDetail])
def list_user_roles(
    user_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:assignments:read")),
):
    links = access_control_service.list_user_roles(db, context, user_id)
    admin_ids = list({link.assigned_by for link in links if link.assigned_by is not None})
    actor_user_ids = list(
        {link.assigned_by_user_id for link in links if link.assigned_by_user_id is not None}
    )
    admins_map = (
        {admin.id: admin for admin in db.exec(select(AdminUser).where(AdminUser.id.in_(admin_ids))).all()}
        if admin_ids
        else {}
    )
    users_map = (
        {user.id: user for user in db.exec(select(User).where(User.id.in_(actor_user_ids))).all()}
        if actor_user_ids
        else {}
    )
    details: list[UserRoleDetail] = []
    for link in links:
        role = db.get(Role, link.role_id)
        if not role:
            continue
        assigned_by_name = None
        if link.assigned_by is not None and link.assigned_by in admins_map:
            admin = admins_map[link.assigned_by]
            assigned_by_name = admin.full_name or admin.email
        elif link.assigned_by_user_id is not None and link.assigned_by_user_id in users_map:
            actor = users_map[link.assigned_by_user_id]
            assigned_by_name = actor.full_name or actor.email
        details.append(
            UserRoleDetail(
                role_id=role.id or link.role_id,
                role_name=role.name,
                role_description=role.description,
                assigned_at=link.created_at,
                assigned_by=link.assigned_by,
                assigned_by_user_id=link.assigned_by_user_id,
                assigned_by_subject=link.assigned_by_subject,
                assigned_by_name=assigned_by_name,
                effective_from=link.effective_from,
                expires_at=link.expires_at,
                notes=link.notes,
                is_active=bool(role.is_active),
            )
        )
    return details


@router.post("/assignments/users/{user_id}/roles", response_model=UserRoleAssignmentResponse)
def assign_user_role(
    user_id: int,
    payload: UserRoleAssign,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:assignments:write")),
):
    link = access_control_service.assign_role_to_user(
        db,
        context,
        user_id=user_id,
        payload=payload,
    )
    return UserRoleAssignmentResponse(
        success=True,
        user_id=link.user_id,
        role_id=link.role_id,
        message="role_assigned",
    )


@router.delete("/assignments/users/{user_id}/roles/{role_id}", response_model=UserRoleAssignmentResponse)
def unassign_user_role(
    user_id: int,
    role_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:assignments:write")),
):
    removed = access_control_service.remove_role_from_user(db, context, user_id, role_id)
    if not removed:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="assignment_not_found")
    return UserRoleAssignmentResponse(success=True, user_id=user_id, role_id=role_id, message="role_unassigned")


@router.post("/assignments/bulk", response_model=BulkRoleAssignResponse)
def bulk_assign_roles(
    payload: BulkRoleAssignRequest,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:assignments:write")),
):
    return access_control_service.bulk_assign_roles(
        db,
        context,
        role_id=payload.role_id,
        user_ids=payload.user_ids,
    )


@router.post("/assignments/users/{source_user_id}/transfer", response_model=RoleTransferResponse)
def transfer_role_assignment(
    source_user_id: int,
    payload: RoleTransferRequest,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:assignments:write")),
):
    return access_control_service.transfer_role_assignment(
        db,
        context,
        source_user_id=source_user_id,
        new_user_id=payload.new_user_id,
        role_id=payload.role_id,
        reason=payload.reason,
    )


@router.get("/menus", response_model=List[MenuRead])
def list_menus(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:menus:read")),
):
    _ = context
    return access_control_service.list_menus(db, skip=skip, limit=limit)


@router.post("/menus", response_model=MenuRead, status_code=status.HTTP_201_CREATED)
def create_menu(
    payload: MenuCreate,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(
        deps.require_rbac_permission("rbac:menus:write", require_global=True)
    ),
):
    _ = context
    return access_control_service.create_menu(db, payload)


@router.put("/menus/{menu_id}", response_model=MenuRead)
def update_menu(
    menu_id: int,
    payload: MenuUpdate,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(
        deps.require_rbac_permission("rbac:menus:write", require_global=True)
    ),
):
    _ = context
    menu = access_control_service.update_menu(db, menu_id, payload)
    if not menu:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="menu_not_found")
    return menu


@router.delete("/menus/{menu_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_menu(
    menu_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(
        deps.require_rbac_permission("rbac:menus:write", require_global=True)
    ),
):
    _ = context
    deleted = access_control_service.delete_menu(db, menu_id)
    if not deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="menu_not_found")
    return None


@router.get("/role-rights/role/{role_id}", response_model=List[RoleRightRead])
def list_role_rights(
    role_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:role_rights:read")),
):
    return access_control_service.list_role_rights(db, context, role_id)


@router.post("/role-rights", response_model=RoleRightRead, status_code=status.HTTP_201_CREATED)
def create_role_right(
    payload: RoleRightCreate,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:role_rights:write")),
):
    return access_control_service.create_or_update_role_right(db, context, payload)


@router.put("/role-rights/{right_id}", response_model=RoleRightRead)
def update_role_right(
    right_id: int,
    payload: RoleRightUpdate,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:role_rights:write")),
):
    right = access_control_service.update_role_right(db, context, right_id, payload)
    if not right:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_right_not_found")
    return right


@router.get("/roles/{role_id}/users", response_model=RoleUsersListResponse)
def list_users_by_role(
    role_id: int,
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:read")),
):
    return access_control_service.list_role_users(
        db,
        context,
        role_id=role_id,
        skip=skip,
        limit=limit,
        active_only=active_only,
    )


@router.post("/roles/{role_id}/duplicate", response_model=RoleRead)
def duplicate_role(
    role_id: int,
    payload: RoleDuplicate,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:write")),
):
    role = access_control_service.duplicate_role(
        db,
        context,
        role_id=role_id,
        new_name=payload.new_name,
        description=payload.description,
    )
    item = RoleRead.model_validate(role)
    item.permission_count = len(role.permissions or [])
    return item


@router.get("/hierarchy", response_model=List[RoleHierarchy])
def get_role_hierarchy(
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:read")),
):
    return access_control_service.get_role_hierarchy(db, context)


@router.get("/matrix", response_model=PermissionMatrix)
def get_permission_matrix(
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:read")),
):
    return access_control_service.get_permission_matrix(db, context)


@router.get("/roles/{role_id}/audit-log", response_model=List[RoleAuditLog])
def get_role_audit_log(
    role_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:roles:read")),
):
    return access_control_service.list_role_audit_logs(db, context, role_id=role_id)


@router.get("/users/{user_id}/permissions", response_model=PermissionListResponse)
def get_user_permissions(
    user_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:assignments:read")),
):
    return access_control_service.get_user_permissions(db, context, user_id=user_id)


@router.get("/users/{user_id}/permissions/check", response_model=PermissionCheckResponse)
def check_user_permission(
    user_id: int,
    permission: str,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:assignments:read")),
):
    return access_control_service.check_user_permission(
        db,
        context,
        user_id=user_id,
        permission_slug=permission,
    )


@router.post("/access-paths/users/{user_id}", response_model=AccessPathRead, status_code=status.HTTP_201_CREATED)
def create_access_path(
    user_id: int,
    payload: AccessPathCreate,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:access_paths:write")),
):
    return access_control_service.create_access_path(
        db,
        context,
        user_id=user_id,
        path_pattern=payload.path_pattern,
        access_level=payload.access_level,
    )


@router.get("/access-paths/users/{user_id}", response_model=List[AccessPathRead])
def list_access_paths(
    user_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:access_paths:read")),
):
    return access_control_service.list_access_paths(db, context, user_id)


@router.put("/access-paths/users/{user_id}/{path_id}", response_model=AccessPathRead)
def update_access_path(
    user_id: int,
    path_id: int,
    payload: AccessPathUpdate,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:access_paths:write")),
):
    if payload.access_level is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="access_level_required")
    updated = access_control_service.update_access_path(
        db,
        context,
        user_id=user_id,
        path_id=path_id,
        access_level=payload.access_level,
    )
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="access_path_not_found")
    return updated


@router.delete("/access-paths/users/{user_id}/{path_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_access_path(
    user_id: int,
    path_id: int,
    db: Session = Depends(deps.get_db),
    context: deps.RBACScopeContext = Depends(deps.require_rbac_permission("rbac:access_paths:write")),
):
    deleted = access_control_service.delete_access_path(
        db,
        context,
        user_id=user_id,
        path_id=path_id,
    )
    if not deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="access_path_not_found")
    return None
