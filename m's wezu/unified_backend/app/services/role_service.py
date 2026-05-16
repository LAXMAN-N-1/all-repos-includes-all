from datetime import UTC, datetime
from typing import Any, Dict, List, Optional, Sequence, Tuple

import sqlalchemy as sa
from sqlalchemy.orm import selectinload
from sqlmodel import Session, select

from app.core.rbac import canonicalize_permission_slug
from app.models.rbac import Permission, Role, RolePermission, UserRole
from app.schemas.role import RoleCreate, RoleUpdate


class RoleService:
    @staticmethod
    def _model_dump(model: Any, **kwargs: Any) -> dict:
        if hasattr(model, "model_dump"):
            return model.model_dump(**kwargs)
        if hasattr(model, "dict"):
            return model.dict(**kwargs)
        return dict(model)

    @staticmethod
    def get_role(db: Session, role_id: int) -> Optional[Role]:
        return db.get(Role, role_id)

    @staticmethod
    def get_role_by_name(db: Session, name: str) -> Optional[Role]:
        normalized = (name or "").strip()
        if not normalized:
            return None
        return db.exec(
            select(Role).where(sa.func.lower(Role.name) == normalized.lower())
        ).first()

    @staticmethod
    def list_permissions(db: Session) -> List[Permission]:
        return db.exec(select(Permission)).all()

    @staticmethod
    def _resolve_permission_ids(
        db: Session,
        *,
        permission_ids: Optional[Sequence[int]] = None,
        permission_slugs: Optional[Sequence[str]] = None,
    ) -> List[int]:
        resolved: set[int] = set()

        if permission_ids:
            for permission_id in permission_ids:
                if permission_id is not None:
                    resolved.add(int(permission_id))

        if permission_slugs:
            cleaned = [canonicalize_permission_slug(s) for s in permission_slugs if s and s.strip()]
            if cleaned:
                rows = db.exec(
                    select(Permission.id).where(Permission.slug.in_(cleaned))
                ).all()
                resolved.update(int(pid) for pid in rows if pid is not None)

        return sorted(resolved)

    @staticmethod
    def replace_role_permissions(
        db: Session,
        role_id: int,
        *,
        permission_ids: Optional[Sequence[int]] = None,
        permission_slugs: Optional[Sequence[str]] = None,
    ) -> List[int]:
        db.exec(
            sa.delete(RolePermission).where(RolePermission.role_id == role_id)
        )

        resolved_ids = RoleService._resolve_permission_ids(
            db,
            permission_ids=permission_ids,
            permission_slugs=permission_slugs,
        )
        for permission_id in resolved_ids:
            db.add(RolePermission(role_id=role_id, permission_id=permission_id))
        return resolved_ids

    @staticmethod
    def create_role_record(
        db: Session,
        *,
        role_data: dict[str, Any],
        permission_ids: Optional[Sequence[int]] = None,
        permission_slugs: Optional[Sequence[str]] = None,
    ) -> Role:
        role = Role(**role_data)
        db.add(role)
        db.commit()
        db.refresh(role)

        if permission_ids is not None or permission_slugs is not None:
            RoleService.replace_role_permissions(
                db,
                int(role.id),
                permission_ids=permission_ids,
                permission_slugs=permission_slugs,
            )
            db.commit()
            db.refresh(role)

        return role

    @staticmethod
    def get_roles(
        db: Session,
        skip: int = 0,
        limit: int = 100,
        *,
        category: Optional[str] = None,
        active_only: bool = False,
        include_permissions: bool = False,
    ) -> List[Role]:
        query = select(Role)
        if include_permissions:
            query = query.options(selectinload(Role.permissions))
        if category:
            query = query.where(Role.category == category)
        if active_only:
            query = query.where(Role.is_active == True)  # noqa: E712
        return db.exec(query.offset(skip).limit(limit)).all()

    @staticmethod
    def create_role(db: Session, role_in: RoleCreate) -> Role:
        role_data = RoleService._model_dump(
            role_in,
            exclude={"permissions", "permission_ids", "parent_role_id", "parent_id"},
            exclude_unset=True,
        )
        parent_id = getattr(role_in, "parent_role_id", None) or getattr(role_in, "parent_id", None)
        if parent_id is not None:
            role_data["parent_id"] = parent_id

        role_data.setdefault("name", role_in.name)
        role_data.setdefault("description", role_in.description)

        permission_slugs = list(getattr(role_in, "permissions", None) or [])
        permission_ids = list(getattr(role_in, "permission_ids", None) or [])

        return RoleService.create_role_record(
            db,
            role_data=role_data,
            permission_ids=permission_ids,
            permission_slugs=permission_slugs,
        )

    @staticmethod
    def update_role_fields(
        db: Session,
        role_id: int,
        *,
        update_data: dict[str, Any],
        permission_ids: Optional[Sequence[int]] = None,
        permission_slugs: Optional[Sequence[str]] = None,
    ) -> Optional[Role]:
        role = db.get(Role, role_id)
        if not role:
            return None

        for key, value in update_data.items():
            if key == "parent_role_id":
                setattr(role, "parent_id", value)
            elif hasattr(role, key):
                setattr(role, key, value)

        role.updated_at = datetime.now(UTC)
        db.add(role)

        if permission_ids is not None or permission_slugs is not None:
            RoleService.replace_role_permissions(
                db,
                role_id,
                permission_ids=permission_ids,
                permission_slugs=permission_slugs,
            )

        db.commit()
        db.refresh(role)
        return role

    @staticmethod
    def update_role(db: Session, role_id: int, role_in: RoleUpdate) -> Optional[Role]:
        role_data = RoleService._model_dump(role_in, exclude_unset=True)
        permission_slugs = role_data.pop("permissions", None)
        return RoleService.update_role_fields(
            db,
            role_id,
            update_data=role_data,
            permission_slugs=permission_slugs,
        )

    @staticmethod
    def get_role_user_counts(
        db: Session,
        role_ids: Sequence[int],
    ) -> Tuple[Dict[int, int], Dict[int, int]]:
        if not role_ids:
            return {}, {}

        total_rows = db.exec(
            select(UserRole.role_id, sa.func.count(UserRole.user_id))
            .where(UserRole.role_id.in_(list(role_ids)))
            .group_by(UserRole.role_id)
        ).all()
        total_counts = {int(role_id): int(count or 0) for role_id, count in total_rows}

        now = datetime.now(UTC)
        active_rows = db.exec(
            select(UserRole.role_id, sa.func.count(UserRole.user_id))
            .where(
                UserRole.role_id.in_(list(role_ids)),
                UserRole.effective_from <= now,
                ((UserRole.expires_at == None) | (UserRole.expires_at >= now)),  # noqa: E711
            )
            .group_by(UserRole.role_id)
        ).all()
        active_counts = {int(role_id): int(count or 0) for role_id, count in active_rows}
        return total_counts, active_counts

    @staticmethod
    def soft_delete_role(db: Session, role_id: int) -> bool:
        role = db.get(Role, role_id)
        if not role:
            return False
        role.is_active = False
        role.updated_at = datetime.now(UTC)
        db.add(role)
        db.commit()
        return True

    @staticmethod
    def delete_role(db: Session, role_id: int) -> bool:
        role = db.get(Role, role_id)
        if not role:
            return False
        db.delete(role)
        db.commit()
        return True


role_service = RoleService()
