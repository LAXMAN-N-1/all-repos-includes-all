from __future__ import annotations

from datetime import UTC, datetime
from typing import Any, Optional

from fastapi import HTTPException, status
import sqlalchemy as sa
from sqlalchemy import func
from sqlalchemy.orm import selectinload
from sqlmodel import Session, col, select

from app.api.deps import RBACScopeContext
from app.models.admin_user import AdminUser
from app.models.audit_log import AuditLog
from app.models.dealer import DealerProfile
from app.models.menu import Menu
from app.models.rbac import Permission, Role, RolePermission, UserAccessPath, UserRole
from app.models.role_right import RoleRight
from app.models.user import User
from app.schemas import rbac as rbac_schema
from app.schemas.menu import MenuCreate, MenuUpdate
from app.schemas.rbac import RoleCreate, RoleUpdate, UserRoleAssign
from app.schemas.role_right import RoleRightCreate, RoleRightUpdate
from app.services.audit_service import AuditService
from app.services.auth_service import AuthService
from app.services.menu_service import menu_service
from app.services.role_right_service import role_right_service
from app.services.role_service import role_service
from app.core.rbac import canonicalize_permission_set


class AccessControlService:
    @staticmethod
    def _forbidden(detail: str = "insufficient_permissions") -> HTTPException:
        return HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=detail)

    @staticmethod
    def _resolve_assigned_by_admin_id(db: Session, actor: User) -> Optional[int]:
        actor_id = getattr(actor, "id", None)
        if actor_id is not None:
            admin_by_id = db.get(AdminUser, actor_id)
            if admin_by_id:
                return admin_by_id.id
        actor_email = getattr(actor, "email", None)
        if isinstance(actor_email, str) and actor_email.strip():
            admin_by_email = db.exec(
                select(AdminUser).where(func.lower(AdminUser.email) == actor_email.strip().lower())
            ).first()
            if admin_by_email:
                return admin_by_email.id
        return None

    @staticmethod
    def _resolve_assignment_actor(
        db: Session,
        *,
        context: RBACScopeContext,
    ) -> tuple[Optional[int], Optional[int], Optional[str]]:
        assigned_by_admin_id = AccessControlService._resolve_assigned_by_admin_id(db, context.user)
        assigned_by_user_id = getattr(context.user, "id", None)
        assigned_by_subject = getattr(context, "auth_subject", None)
        if isinstance(assigned_by_user_id, int):
            user_id = assigned_by_user_id
        else:
            user_id = None
        subject = str(assigned_by_subject) if assigned_by_subject is not None else None
        return assigned_by_admin_id, user_id, subject

    @staticmethod
    def _audit_action(
        db: Session,
        *,
        context: RBACScopeContext,
        action: str,
        resource_type: str,
        resource_id: Optional[str] = None,
        details: Optional[str] = None,
        target_id: Optional[int] = None,
        old_value: Optional[dict[str, Any]] = None,
        new_value: Optional[dict[str, Any]] = None,
    ) -> None:
        try:
            AuditService.log_action(
                db=db,
                user_id=getattr(context.user, "id", None),
                action=action,
                resource_type=resource_type,
                resource_id=resource_id,
                target_id=target_id,
                details=details,
                old_value=old_value,
                new_value=new_value,
            )
        except Exception:
            # Audit logging must not break core request flow.
            pass

    @staticmethod
    def _iter_role_chain(db: Session, role: Role):
        current = role
        while current:
            yield current
            parent_id = getattr(current, "parent_id", None)
            if parent_id is None:
                break
            current = db.get(Role, parent_id)

    @staticmethod
    def _to_permission_item(permission: Permission) -> rbac_schema.PermissionItem:
        label = permission.slug.split(":")[-1].replace("_", " ").title()
        description = permission.description or f"Access to {permission.action} {permission.module}"
        return rbac_schema.PermissionItem(
            id=permission.slug,
            label=label,
            description=description,
            resource=permission.module,
            action=permission.action,
            scope=permission.scope or "global",
        )

    @staticmethod
    def _assert_role_scope(role: Role, context: RBACScopeContext) -> None:
        if context.scope == "global":
            return
        dealer_scope_id = context.dealer_id or context.tenant_id
        if dealer_scope_id is None or role.dealer_id != dealer_scope_id:
            raise AccessControlService._forbidden("rbac_scope_forbidden")

    @staticmethod
    def _user_belongs_to_tenant(db: Session, user_id: int, tenant_id: int) -> bool:
        user = db.get(User, user_id)
        if not user:
            return False
        if user.created_by_dealer_id == tenant_id:
            return True
        dealer_profile = db.exec(
            select(DealerProfile).where(DealerProfile.user_id == user_id)
        ).first()
        return bool(dealer_profile and dealer_profile.id == tenant_id)

    @staticmethod
    def list_roles(
        db: Session,
        context: RBACScopeContext,
        *,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> list[Role]:
        stmt = select(Role).options(selectinload(Role.permissions)).offset(skip).limit(limit)
        if active_only:
            stmt = stmt.where(Role.is_active == True)  # noqa: E712
        if context.scope == "tenant":
            stmt = stmt.where(Role.dealer_id == (context.dealer_id or context.tenant_id))
        return db.exec(stmt).all()

    @staticmethod
    def create_role(db: Session, context: RBACScopeContext, role_in: RoleCreate) -> Role:
        role_data = role_in.model_dump(
            exclude={"permissions", "permission_ids", "parent_role_id"},
            exclude_unset=True,
            by_alias=False,
        )
        parent_id = role_in.parent_role_id
        if parent_id is not None:
            role_data["parent_id"] = parent_id

        if context.scope == "tenant":
            role_data["dealer_id"] = context.dealer_id or context.tenant_id
            role_data["scope_owner"] = "dealer"
            role_data["is_custom_role"] = True
            role_data["is_system_role"] = False

        return role_service.create_role_record(
            db,
            role_data=role_data,
            permission_ids=role_in.permission_ids or None,
            permission_slugs=role_in.permissions or None,
        )

    @staticmethod
    def update_role(db: Session, context: RBACScopeContext, role_id: int, role_in: RoleUpdate) -> Optional[Role]:
        role = role_service.get_role(db, role_id)
        if not role:
            return None
        AccessControlService._assert_role_scope(role, context)

        update_data = role_in.model_dump(exclude_unset=True, by_alias=False)
        permission_slugs = update_data.pop("permissions", None)
        parent_id = update_data.pop("parent_role_id", None)
        if parent_id is not None:
            update_data["parent_id"] = parent_id

        if context.scope == "tenant":
            update_data["dealer_id"] = context.dealer_id or context.tenant_id
            update_data["scope_owner"] = "dealer"
            update_data["is_custom_role"] = True

        return role_service.update_role_fields(
            db,
            role_id,
            update_data=update_data,
            permission_slugs=permission_slugs,
        )

    @staticmethod
    def delete_role(db: Session, context: RBACScopeContext, role_id: int) -> bool:
        role = role_service.get_role(db, role_id)
        if not role:
            return False
        AccessControlService._assert_role_scope(role, context)
        if role.is_system_role:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="system_role_immutable")
        return role_service.soft_delete_role(db, role_id)

    @staticmethod
    def list_permissions(db: Session) -> list[Permission]:
        return role_service.list_permissions(db)

    @staticmethod
    def create_permission(db: Session, permission_in: Permission) -> Permission:
        db.add(permission_in)
        db.commit()
        db.refresh(permission_in)
        return permission_in

    @staticmethod
    def list_permission_modules(db: Session) -> list[rbac_schema.ModulePermission]:
        permissions = db.exec(select(Permission)).all()
        grouped: dict[str, set[str]] = {}
        for permission in permissions:
            grouped.setdefault(permission.module, set()).add(permission.action)
        return [
            rbac_schema.ModulePermission(module=module, permissions=sorted(actions))
            for module, actions in sorted(grouped.items())
        ]

    @staticmethod
    def get_role_permissions(
        db: Session,
        context: RBACScopeContext,
        role_id: int,
    ) -> rbac_schema.RolePermissionsResponse:
        role = db.get(Role, role_id)
        if not role:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
        AccessControlService._assert_role_scope(role, context)

        direct_permissions = [AccessControlService._to_permission_item(p) for p in role.permissions]
        inherited_permissions: list[rbac_schema.InheritedPermissions] = []
        all_permissions: dict[str, rbac_schema.PermissionItem] = {
            item.id: item for item in direct_permissions
        }

        current = role
        while getattr(current, "parent_id", None):
            parent = db.get(Role, current.parent_id)
            if not parent:
                break
            AccessControlService._assert_role_scope(parent, context)
            parent_items = [AccessControlService._to_permission_item(p) for p in parent.permissions]
            if parent_items:
                inherited_permissions.append(
                    rbac_schema.InheritedPermissions(
                        source_role_id=parent.id,
                        source_role_name=parent.name,
                        permissions=parent_items,
                    )
                )
            for item in parent_items:
                all_permissions.setdefault(item.id, item)
            current = parent

        grouped: dict[str, list[rbac_schema.PermissionItem]] = {}
        for item in all_permissions.values():
            grouped.setdefault(item.resource, []).append(item)
        grouped_modules = [
            rbac_schema.PermissionModule(
                module=module,
                label=module.replace("_", " ").title(),
                permissions=items,
            )
            for module, items in sorted(grouped.items())
        ]

        return rbac_schema.RolePermissionsResponse(
            direct_permissions=direct_permissions,
            inherited_permissions=inherited_permissions,
            all_permissions_grouped=grouped_modules,
        )

    @staticmethod
    def assign_role_permissions(
        db: Session,
        context: RBACScopeContext,
        *,
        role_id: int,
        permissions: list[str],
        mode: str,
    ) -> rbac_schema.RolePermissionUpdateResponse:
        role = db.get(Role, role_id)
        if not role:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
        AccessControlService._assert_role_scope(role, context)

        requested = canonicalize_permission_set(permissions)
        found = db.exec(select(Permission).where(col(Permission.slug).in_(requested))).all() if requested else []
        found_by_slug = {perm.slug: perm for perm in found}
        missing = sorted(requested - set(found_by_slug))
        if missing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"invalid_permission_slugs:{','.join(missing)}",
            )

        if mode == "overwrite":
            role.permissions = found
        elif mode == "append":
            existing_ids = {permission.id for permission in role.permissions}
            for permission in found:
                if permission.id not in existing_ids:
                    role.permissions.append(permission)
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="invalid_mode")

        db.add(role)
        db.commit()
        db.refresh(role)

        affected_user_ids = db.exec(
            select(UserRole.user_id).where(UserRole.role_id == role.id)
        ).all()
        for user_id in affected_user_ids:
            AuthService.revoke_all_user_sessions(db, user_id)

        AccessControlService._audit_action(
            db,
            context=context,
            action="rbac_role_permissions_updated",
            resource_type="RBAC_ROLE",
            resource_id=str(role.id),
            details=f"Updated permissions for role '{role.name}' using mode '{mode}'",
            new_value={"permissions": sorted([perm.slug for perm in role.permissions])},
        )

        return rbac_schema.RolePermissionUpdateResponse(
            role_id=role.id,
            users_affected=len(set(affected_user_ids)),
            active_permissions=sorted([perm.slug for perm in role.permissions]),
        )

    @staticmethod
    def list_role_users(
        db: Session,
        context: RBACScopeContext,
        *,
        role_id: int,
        skip: int = 0,
        limit: int = 100,
        active_only: bool = False,
    ) -> rbac_schema.RoleUsersListResponse:
        role = db.get(Role, role_id)
        if not role:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
        AccessControlService._assert_role_scope(role, context)

        query = (
            select(User, UserRole)
            .join(UserRole, UserRole.user_id == User.id)
            .where(UserRole.role_id == role_id)
        )
        if active_only:
            query = query.where(User.status == "ACTIVE")

        dealer_scope_id = context.dealer_id or context.tenant_id
        if context.scope == "tenant" and dealer_scope_id is not None:
            query = query.where(
                (User.created_by_dealer_id == dealer_scope_id)
                | (
                    User.id.in_(
                        select(DealerProfile.user_id).where(DealerProfile.id == dealer_scope_id)
                    )
                )
            )

        total = db.exec(select(func.count()).select_from(query.subquery())).one()
        rows = db.exec(query.offset(skip).limit(limit)).all()
        items = [
            rbac_schema.RoleUserListItem(
                id=user.id,
                full_name=user.full_name,
                email=user.email,
                phone_number=user.phone_number,
                is_active=user.is_active,
                assigned_at=user_role.created_at,
                assigned_by=user_role.assigned_by,
                assigned_by_user_id=user_role.assigned_by_user_id,
                expires_at=user_role.expires_at,
            )
            for user, user_role in rows
        ]
        return rbac_schema.RoleUsersListResponse(
            total=int(total or 0),
            items=items,
            role_name=role.name,
            skip=skip,
            limit=limit,
        )

    @staticmethod
    def bulk_assign_roles(
        db: Session,
        context: RBACScopeContext,
        *,
        role_id: int,
        user_ids: list[int],
    ) -> rbac_schema.BulkRoleAssignResponse:
        role = db.get(Role, role_id)
        if not role:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
        AccessControlService._assert_role_scope(role, context)

        assigned_by_admin_id, assigned_by_user_id, assigned_by_subject = (
            AccessControlService._resolve_assignment_actor(db, context=context)
        )
        users = db.exec(select(User).where(User.id.in_(user_ids))).all()
        users_map = {user.id: user for user in users}
        existing = db.exec(
            select(UserRole).where(
                UserRole.user_id.in_(user_ids),
                UserRole.role_id == role_id,
            )
        ).all()
        existing_user_ids = {link.user_id for link in existing}

        results: list[rbac_schema.BulkAssignmentResult] = []
        success_count = 0
        fail_count = 0
        for user_id in user_ids:
            user = users_map.get(user_id)
            if not user:
                results.append(
                    rbac_schema.BulkAssignmentResult(
                        user_id=user_id,
                        success=False,
                        message="user_not_found",
                    )
                )
                fail_count += 1
                continue
            dealer_scope_id = context.dealer_id or context.tenant_id
            if context.scope == "tenant" and dealer_scope_id is not None:
                if not AccessControlService._user_belongs_to_tenant(db, user_id, dealer_scope_id):
                    results.append(
                        rbac_schema.BulkAssignmentResult(
                            user_id=user_id,
                            success=False,
                            message="rbac_scope_forbidden",
                        )
                    )
                    fail_count += 1
                    continue

            if user_id not in existing_user_ids:
                db.add(
                    UserRole(
                        user_id=user_id,
                        role_id=role_id,
                        assigned_by=assigned_by_admin_id,
                        assigned_by_user_id=assigned_by_user_id,
                        assigned_by_subject=assigned_by_subject,
                        effective_from=datetime.now(UTC),
                    )
                )
            AuthService.revoke_all_user_sessions(db, user_id)
            results.append(
                rbac_schema.BulkAssignmentResult(
                    user_id=user_id,
                    success=True,
                    message="assigned",
                )
            )
            success_count += 1

        db.commit()
        AccessControlService._audit_action(
            db,
            context=context,
            action="rbac_bulk_assignment",
            resource_type="RBAC_ROLE",
            resource_id=str(role_id),
            details=f"Bulk role assignment executed for {len(user_ids)} users",
            new_value={"success": success_count, "failed": fail_count},
        )
        return rbac_schema.BulkRoleAssignResponse(
            total_requested=len(user_ids),
            total_success=success_count,
            total_failed=fail_count,
            results=results,
        )

    @staticmethod
    def transfer_role_assignment(
        db: Session,
        context: RBACScopeContext,
        *,
        source_user_id: int,
        new_user_id: int,
        role_id: int,
        reason: Optional[str] = None,
    ) -> rbac_schema.RoleTransferResponse:
        role = db.get(Role, role_id)
        if not role:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
        AccessControlService._assert_role_scope(role, context)

        source_user = db.get(User, source_user_id)
        target_user = db.get(User, new_user_id)
        if not source_user or not target_user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="user_not_found")

        dealer_scope_id = context.dealer_id or context.tenant_id
        if context.scope == "tenant" and dealer_scope_id is not None:
            if not AccessControlService._user_belongs_to_tenant(db, source_user_id, dealer_scope_id):
                raise AccessControlService._forbidden("rbac_scope_forbidden")
            if not AccessControlService._user_belongs_to_tenant(db, new_user_id, dealer_scope_id):
                raise AccessControlService._forbidden("rbac_scope_forbidden")

        source_link = db.exec(
            select(UserRole).where(
                UserRole.user_id == source_user_id,
                UserRole.role_id == role_id,
            )
        ).first()
        if not source_link:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="source_user_missing_role")

        target_existing = db.exec(
            select(UserRole).where(
                UserRole.user_id == new_user_id,
                UserRole.role_id == role_id,
            )
        ).first()
        if target_existing:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="target_user_already_has_role")

        db.delete(source_link)
        assigned_by_admin_id, assigned_by_user_id, assigned_by_subject = (
            AccessControlService._resolve_assignment_actor(db, context=context)
        )
        db.add(
            UserRole(
                user_id=new_user_id,
                role_id=role_id,
                assigned_by=assigned_by_admin_id,
                assigned_by_user_id=assigned_by_user_id,
                assigned_by_subject=assigned_by_subject,
                notes=f"Transferred from user {source_user_id}. Reason: {reason or 'n/a'}",
                effective_from=datetime.now(UTC),
            )
        )

        AuthService.revoke_all_user_sessions(db, source_user_id)
        AuthService.revoke_all_user_sessions(db, new_user_id)
        db.commit()
        AccessControlService._audit_action(
            db,
            context=context,
            action="rbac_role_transfer",
            resource_type="RBAC_ROLE",
            resource_id=str(role_id),
            details=f"Transferred role from user {source_user_id} to user {new_user_id}",
        )
        return rbac_schema.RoleTransferResponse(
            success=True,
            message="role_transferred",
            old_assignment_id=None,
            new_assignment_id=None,
        )

    @staticmethod
    def get_user_permissions(
        db: Session,
        context: RBACScopeContext,
        *,
        user_id: int,
    ) -> rbac_schema.PermissionListResponse:
        user = db.get(User, user_id)
        if not user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="user_not_found")
        dealer_scope_id = context.dealer_id or context.tenant_id
        if context.scope == "tenant" and dealer_scope_id is not None:
            if not AccessControlService._user_belongs_to_tenant(db, user_id, dealer_scope_id):
                raise AccessControlService._forbidden("rbac_scope_forbidden")

        links = db.exec(select(UserRole).where(UserRole.user_id == user_id)).all()
        role_ids = [link.role_id for link in links]
        roles = db.exec(
            select(Role).where(Role.id.in_(role_ids)).options(selectinload(Role.permissions))
        ).all() if role_ids else []

        unique_permissions: dict[str, Permission] = {}
        for role in roles:
            for current in AccessControlService._iter_role_chain(db, role):
                AccessControlService._assert_role_scope(current, context)
                for permission in current.permissions:
                    unique_permissions.setdefault(permission.slug, permission)

        grouped: dict[str, list[rbac_schema.PermissionItem]] = {}
        for permission in unique_permissions.values():
            item = AccessControlService._to_permission_item(permission)
            grouped.setdefault(item.resource, []).append(item)
        modules = [
            rbac_schema.PermissionModule(
                module=module,
                label=module.replace("_", " ").title(),
                permissions=items,
            )
            for module, items in sorted(grouped.items())
        ]
        return rbac_schema.PermissionListResponse(modules=modules)

    @staticmethod
    def check_user_permission(
        db: Session,
        context: RBACScopeContext,
        *,
        user_id: int,
        permission_slug: str,
    ) -> rbac_schema.PermissionCheckResponse:
        permissions = AccessControlService.get_user_permissions(db, context, user_id=user_id)
        for module in permissions.modules:
            for item in module.permissions:
                if item.id == permission_slug:
                    return rbac_schema.PermissionCheckResponse(
                        has_permission=True,
                        granted_by_role=None,
                        scope=item.scope,
                    )
        return rbac_schema.PermissionCheckResponse(has_permission=False, granted_by_role=None, scope=None)

    @staticmethod
    def duplicate_role(
        db: Session,
        context: RBACScopeContext,
        *,
        role_id: int,
        new_name: str,
        description: Optional[str] = None,
    ) -> Role:
        source_role = db.get(Role, role_id)
        if not source_role:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
        AccessControlService._assert_role_scope(source_role, context)
        if role_service.get_role_by_name(db, new_name):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="role_name_exists")

        new_role = Role(
            name=new_name,
            description=description or source_role.description,
            category=source_role.category,
            level=source_role.level,
            parent_id=source_role.parent_id,
            is_system_role=False,
            is_custom_role=True if context.scope == "tenant" else source_role.is_custom_role,
            scope_owner="dealer" if context.scope == "tenant" else source_role.scope_owner,
            dealer_id=(context.dealer_id or context.tenant_id) if context.scope == "tenant" else source_role.dealer_id,
            icon=source_role.icon,
            color=source_role.color,
            is_active=True,
        )
        db.add(new_role)
        db.commit()
        db.refresh(new_role)
        for permission in source_role.permissions:
            db.add(RolePermission(role_id=new_role.id, permission_id=permission.id))
        db.commit()
        db.refresh(new_role)
        AccessControlService._audit_action(
            db,
            context=context,
            action="rbac_role_duplicated",
            resource_type="RBAC_ROLE",
            resource_id=str(new_role.id),
            details=f"Duplicated role '{source_role.name}' into '{new_name}'",
        )
        return new_role

    @staticmethod
    def get_role_hierarchy(db: Session, context: RBACScopeContext) -> list[rbac_schema.RoleHierarchy]:
        stmt = select(Role).where(Role.is_active == True)  # noqa: E712
        if context.scope == "tenant":
            stmt = stmt.where(Role.dealer_id == (context.dealer_id or context.tenant_id))
        roles = db.exec(stmt).all()
        role_map: dict[int, rbac_schema.RoleHierarchy] = {}
        roots: list[rbac_schema.RoleHierarchy] = []
        for role in roles:
            item = rbac_schema.RoleHierarchy.model_validate(role)
            item.permission_count = len(role.permissions or [])
            item.children = []
            if role.id is not None:
                role_map[int(role.id)] = item
        for role in roles:
            role_id = int(role.id or 0)
            parent_id = getattr(role, "parent_id", None)
            node = role_map.get(role_id)
            if node is None:
                continue
            if parent_id and parent_id in role_map:
                role_map[parent_id].children.append(node)
            else:
                roots.append(node)
        return roots

    @staticmethod
    def get_permission_matrix(db: Session, context: RBACScopeContext) -> rbac_schema.PermissionMatrix:
        stmt = select(Role).where(Role.is_active == True)  # noqa: E712
        if context.scope == "tenant":
            dealer_scope_id = context.dealer_id or context.tenant_id
            stmt = stmt.where(
                (Role.dealer_id == dealer_scope_id)
                | ((Role.dealer_id == None) & (Role.is_system_role == True))  # noqa: E711, E712
            )
        roles = db.exec(stmt).all()
        permissions = db.exec(select(Permission)).all()
        modules: dict[str, set[str]] = {}
        for permission in permissions:
            modules.setdefault(permission.module, set()).add(permission.action)

        matrix: dict[str, dict[str, list[str]]] = {}
        for role in roles:
            role_key = role.name
            matrix[role_key] = {}
            for permission in role.permissions:
                module_name = permission.module.title()
                matrix[role_key].setdefault(module_name, []).append(permission.action.capitalize())

        return rbac_schema.PermissionMatrix(
            roles=[role.name for role in roles],
            modules=[
                rbac_schema.ModulePermission(module=name.title(), permissions=sorted(actions))
                for name, actions in sorted(modules.items())
            ],
            matrix=matrix,
        )

    @staticmethod
    def list_role_audit_logs(
        db: Session,
        context: RBACScopeContext,
        *,
        role_id: int,
    ) -> list[rbac_schema.RoleAuditLog]:
        role = db.get(Role, role_id)
        if not role:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
        AccessControlService._assert_role_scope(role, context)

        logs = db.exec(
            select(AuditLog)
            .where(AuditLog.resource_type == "ROLE")
            .where(AuditLog.target_id == role_id)
            .order_by(AuditLog.timestamp.desc())
        ).all()
        user_ids = list({log.user_id for log in logs if log.user_id})
        users = db.exec(select(User).where(User.id.in_(user_ids))).all() if user_ids else []
        user_map = {user.id: user for user in users}

        return [
            rbac_schema.RoleAuditLog(
                action=log.action,
                user_name=(user_map.get(log.user_id).full_name if user_map.get(log.user_id) else "System"),
                timestamp=log.timestamp,
                details=log.details,
            )
            for log in logs
        ]

    @staticmethod
    def list_user_roles(db: Session, context: RBACScopeContext, user_id: int) -> list[UserRole]:
        if context.scope == "tenant":
            dealer_scope_id = context.dealer_id or context.tenant_id
            if dealer_scope_id is None or not AccessControlService._user_belongs_to_tenant(db, user_id, dealer_scope_id):
                raise AccessControlService._forbidden("rbac_scope_forbidden")
        return db.exec(select(UserRole).where(UserRole.user_id == user_id)).all()

    @staticmethod
    def assign_role_to_user(
        db: Session,
        context: RBACScopeContext,
        *,
        user_id: int,
        payload: UserRoleAssign,
    ) -> UserRole:
        user = db.get(User, user_id)
        if not user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="user_not_found")

        role = db.get(Role, payload.role_id)
        if not role:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")

        AccessControlService._assert_role_scope(role, context)
        if context.scope == "tenant":
            dealer_scope_id = context.dealer_id or context.tenant_id
            if dealer_scope_id is None or not AccessControlService._user_belongs_to_tenant(db, user_id, dealer_scope_id):
                raise AccessControlService._forbidden("rbac_scope_forbidden")

        link = db.exec(
            select(UserRole).where(
                UserRole.user_id == user_id,
                UserRole.role_id == payload.role_id,
            )
        ).first()
        if not link:
            assigned_by_admin_id, assigned_by_user_id, assigned_by_subject = (
                AccessControlService._resolve_assignment_actor(db, context=context)
            )
            link = UserRole(
                user_id=user_id,
                role_id=payload.role_id,
                assigned_by=assigned_by_admin_id,
                assigned_by_user_id=assigned_by_user_id,
                assigned_by_subject=assigned_by_subject,
                effective_from=payload.effective_from or datetime.now(UTC),
                expires_at=payload.expires_at,
                notes=payload.notes,
            )
        else:
            if payload.effective_from is not None:
                link.effective_from = payload.effective_from
            link.expires_at = payload.expires_at
            link.notes = payload.notes
            assigned_by_admin_id, assigned_by_user_id, assigned_by_subject = (
                AccessControlService._resolve_assignment_actor(db, context=context)
            )
            link.assigned_by = assigned_by_admin_id
            link.assigned_by_user_id = assigned_by_user_id
            link.assigned_by_subject = assigned_by_subject

        db.add(link)
        db.commit()
        db.refresh(link)
        return link

    @staticmethod
    def remove_role_from_user(db: Session, context: RBACScopeContext, user_id: int, role_id: int) -> bool:
        role = db.get(Role, role_id)
        if role:
            AccessControlService._assert_role_scope(role, context)

        if context.scope == "tenant":
            dealer_scope_id = context.dealer_id or context.tenant_id
            if dealer_scope_id is None or not AccessControlService._user_belongs_to_tenant(db, user_id, dealer_scope_id):
                raise AccessControlService._forbidden("rbac_scope_forbidden")

        link = db.exec(
            select(UserRole).where(
                UserRole.user_id == user_id,
                UserRole.role_id == role_id,
            )
        ).first()
        if not link:
            return False
        db.delete(link)

        db.commit()
        return True

    @staticmethod
    def list_menus(db: Session, *, skip: int = 0, limit: int = 100) -> list[Menu]:
        return menu_service.get_menus(db, skip=skip, limit=limit)

    @staticmethod
    def create_menu(db: Session, menu_in: MenuCreate) -> Menu:
        return menu_service.create_menu(db, menu_in)

    @staticmethod
    def update_menu(db: Session, menu_id: int, menu_in: MenuUpdate) -> Optional[Menu]:
        return menu_service.update_menu(db, menu_id, menu_in)

    @staticmethod
    def delete_menu(db: Session, menu_id: int) -> bool:
        return menu_service.delete_menu(db, menu_id)

    @staticmethod
    def list_role_rights(db: Session, context: RBACScopeContext, role_id: int) -> list[RoleRight]:
        role = db.get(Role, role_id)
        if not role:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
        AccessControlService._assert_role_scope(role, context)
        return role_right_service.get_role_rights(db, role_id)

    @staticmethod
    def create_or_update_role_right(
        db: Session,
        context: RBACScopeContext,
        payload: RoleRightCreate,
    ) -> RoleRight:
        role = db.get(Role, payload.role_id)
        if not role:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="role_not_found")
        AccessControlService._assert_role_scope(role, context)
        return role_right_service.create_or_update_role_right(db, payload)

    @staticmethod
    def update_role_right(
        db: Session,
        context: RBACScopeContext,
        right_id: int,
        payload: RoleRightUpdate,
    ) -> Optional[RoleRight]:
        right = role_right_service.get_role_right(db, right_id)
        if not right:
            return None
        role = db.get(Role, right.role_id)
        if role:
            AccessControlService._assert_role_scope(role, context)
        return role_right_service.update_role_right(db, right_id, payload)

    @staticmethod
    def create_access_path(
        db: Session,
        context: RBACScopeContext,
        *,
        user_id: int,
        path_pattern: str,
        access_level: str,
        ) -> UserAccessPath:
        if context.scope == "tenant":
            dealer_scope_id = context.dealer_id or context.tenant_id
            if dealer_scope_id is None or not AccessControlService._user_belongs_to_tenant(db, user_id, dealer_scope_id):
                raise AccessControlService._forbidden("rbac_scope_forbidden")
        access_path = UserAccessPath(
            user_id=user_id,
            path_pattern=path_pattern,
            access_level=access_level,
        )
        db.add(access_path)
        db.commit()
        db.refresh(access_path)
        return access_path

    @staticmethod
    def list_access_paths(db: Session, context: RBACScopeContext, user_id: int) -> list[UserAccessPath]:
        if context.scope == "tenant":
            dealer_scope_id = context.dealer_id or context.tenant_id
            if dealer_scope_id is None or not AccessControlService._user_belongs_to_tenant(db, user_id, dealer_scope_id):
                raise AccessControlService._forbidden("rbac_scope_forbidden")
        return db.exec(select(UserAccessPath).where(UserAccessPath.user_id == user_id)).all()

    @staticmethod
    def update_access_path(
        db: Session,
        context: RBACScopeContext,
        *,
        user_id: int,
        path_id: int,
        access_level: str,
    ) -> Optional[UserAccessPath]:
        access_path = db.get(UserAccessPath, path_id)
        if not access_path or access_path.user_id != user_id:
            return None
        if context.scope == "tenant":
            dealer_scope_id = context.dealer_id or context.tenant_id
            if dealer_scope_id is None or not AccessControlService._user_belongs_to_tenant(db, user_id, dealer_scope_id):
                raise AccessControlService._forbidden("rbac_scope_forbidden")
        access_path.access_level = access_level
        db.add(access_path)
        db.commit()
        db.refresh(access_path)
        return access_path

    @staticmethod
    def delete_access_path(db: Session, context: RBACScopeContext, *, user_id: int, path_id: int) -> bool:
        access_path = db.get(UserAccessPath, path_id)
        if not access_path or access_path.user_id != user_id:
            return False
        if context.scope == "tenant":
            dealer_scope_id = context.dealer_id or context.tenant_id
            if dealer_scope_id is None or not AccessControlService._user_belongs_to_tenant(db, user_id, dealer_scope_id):
                raise AccessControlService._forbidden("rbac_scope_forbidden")
        db.delete(access_path)
        db.commit()
        return True


access_control_service = AccessControlService()
