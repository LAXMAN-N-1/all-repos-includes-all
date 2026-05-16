from typing import Any, List, Optional, TYPE_CHECKING
import sqlalchemy as sa
from sqlalchemy import event
from sqlmodel import SQLModel, Field, Relationship
from pydantic import field_validator
if TYPE_CHECKING:
    from app.models.user import User
    from app.models.role_right import RoleRight
from datetime import datetime, UTC

# Link Table for Role <-> Permission
class RolePermission(SQLModel, table=True):
    __tablename__ = "role_permissions"
    role_id: int = Field(foreign_key="roles.id", primary_key=True)
    permission_id: int = Field(foreign_key="permissions.id", primary_key=True)

# Link Table for AdminUser <-> Role
class AdminUserRole(SQLModel, table=True):
    __tablename__ = "admin_user_roles"
    admin_id: int = Field(foreign_key="admin_users.id", primary_key=True)
    role_id: int = Field(foreign_key="roles.id", primary_key=True)
    
    assigned_by: Optional[int] = Field(default=None, foreign_key="admin_users.id")
    assigned_at: datetime = Field(default_factory=lambda: datetime.now(UTC))


# Link Table for User <-> Role (Many-to-Many)
class UserRole(SQLModel, table=True):
    __tablename__ = "user_roles"
    user_id: int = Field(foreign_key="users.id", primary_key=True)
    role_id: int = Field(foreign_key="roles.id", primary_key=True)
    
    assigned_by: Optional[int] = Field(default=None, foreign_key="admin_users.id")
    assigned_by_user_id: Optional[int] = Field(default=None, foreign_key="users.id", index=True)
    assigned_by_subject: Optional[str] = Field(default=None, index=True)
    notes: Optional[str] = None
    effective_from: datetime = Field(default_factory=lambda: datetime.now(UTC))
    expires_at: Optional[datetime] = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))

class Permission(SQLModel, table=True):
    __tablename__ = "permissions"
    id: Optional[int] = Field(default=None, primary_key=True)
    slug: str = Field(unique=True, index=True)  # canonical form: "module:action:scope"
    module: str  # e.g., "battery", "station"
    resource_type: Optional[str] = None # e.g., "Battery", "StationSlot"
    action: str  # canonical action — one of CANONICAL_PERMISSION_ACTIONS
    scope: str = Field(default="global") # global, regional, organizational, own
    constraints: Optional[str] = None # JSON string for action-level rules
    description: Optional[str] = None

    roles: List["Role"] = Relationship(back_populates="permissions", link_model=RolePermission)

    @field_validator("slug", mode="before")
    @classmethod
    def _normalize_slug(cls, v: Any) -> Any:
        # Normalise at write time so the DB never stores legacy aliases.
        # read→view, edit→update, all→global  (mirrors canonicalize_permission_slug)
        if not isinstance(v, str):
            return v
        from app.core.rbac import canonicalize_permission_slug
        return canonicalize_permission_slug(v)

class Role(SQLModel, table=True):
    __tablename__ = "roles"
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(unique=True, index=True)
    description: Optional[str] = None
    category: str = Field(default="system") # powerfill_staff, vendor_staff, customer, system
    level: int = Field(default=0) # Hierarchy level (e.g. 100=Admin, 10=User)
    parent_id: Optional[int] = Field(default=None, foreign_key="roles.id")
    is_system_role: bool = Field(default=False)  # If True, cannot be deleted (e.g., Super Admin)
    is_custom_role: bool = Field(default=False)  # True for dealer-scoped runtime custom roles
    is_active: bool = Field(default=True)
    scope_owner: str = Field(default="global")  # global | dealer
    
    # Dealer Scoping (Phases 5/6)
    dealer_id: Optional[int] = Field(default=None, foreign_key="dealer_profiles.id", index=True)
    
    # UI Attributes
    icon: Optional[str] = Field(default="shield") # Lucide icon name
    color: Optional[str] = Field(default="#4CAF50") # HEX color
    
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    
    # Hierarchy relationships
    parent: Optional["Role"] = Relationship(
        sa_relationship_kwargs={
            "remote_side": "Role.id",
            "primaryjoin": "Role.parent_id==Role.id",
            "back_populates": "children"
        }
    )
    children: List["Role"] = Relationship(
        back_populates="parent",
        sa_relationship_kwargs={
            "primaryjoin": "Role.parent_id==Role.id"
        }
    )

    permissions: List[Permission] = Relationship(back_populates="roles", link_model=RolePermission)
    
    admin_users: List["AdminUser"] = Relationship(
        back_populates="roles",
        link_model=AdminUserRole,
        sa_relationship_kwargs={
            "primaryjoin": "Role.id==AdminUserRole.role_id",
            "secondaryjoin": "AdminUser.id==AdminUserRole.admin_id"
        }
    )

    # Change to One-to-Many to match User model
    users: List["User"] = Relationship(back_populates="role")
    
    # Merged from app/models/role.py (Legacy/Chandu branch)
    role_rights: List["RoleRight"] = Relationship(back_populates="role", sa_relationship_kwargs={"cascade": "all, delete-orphan"})

    @property
    def parent_role_id(self):
        return self.parent_id
    
    @parent_role_id.setter
    def parent_role_id(self, value):
        self.parent_id = value



# Data Scoping: Path Based Access
class UserAccessPath(SQLModel, table=True):
    __tablename__ = "user_access_paths"
    
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="users.id", index=True)
    
    # Path Pattern e.g. "Asia/India/Telangana/%"
    path_pattern: str = Field(index=True)
    
    # Access Level
    access_level: str = Field(default="view") # view, manage, admin
    
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    created_by: Optional[int] = Field(default=None, foreign_key="admin_users.id")
    
    # Relationships
    user: "User" = Relationship(back_populates="access_paths")


def _sync_primary_role_pointer(connection: sa.engine.Connection, user_id: Optional[int]) -> None:
    if user_id is None:
        return
    now = datetime.now(UTC)
    connection.execute(
        sa.text(
            """
            UPDATE users
            SET role_id = (
                SELECT ur.role_id
                FROM user_roles ur
                JOIN roles r ON r.id = ur.role_id
                WHERE ur.user_id = :user_id
                  AND ur.effective_from <= :now
                  AND (ur.expires_at IS NULL OR ur.expires_at >= :now)
                  AND r.is_active = TRUE
                ORDER BY r.level DESC, ur.effective_from DESC, ur.created_at DESC, ur.role_id ASC
                LIMIT 1
            )
            WHERE id = :user_id
            """
        ),
        {"user_id": int(user_id), "now": now},
    )


@event.listens_for(UserRole, "after_insert")
def _user_role_after_insert(mapper, connection, target) -> None:
    _sync_primary_role_pointer(connection, getattr(target, "user_id", None))


@event.listens_for(UserRole, "after_update")
def _user_role_after_update(mapper, connection, target) -> None:
    _sync_primary_role_pointer(connection, getattr(target, "user_id", None))


@event.listens_for(UserRole, "after_delete")
def _user_role_after_delete(mapper, connection, target) -> None:
    _sync_primary_role_pointer(connection, getattr(target, "user_id", None))


@event.listens_for(Role, "after_update")
def _role_after_update(mapper, connection, target) -> None:
    if getattr(target, "id", None) is None:
        return
    changed = sa.inspect(target).attrs
    if not (changed.is_active.history.has_changes() or changed.level.history.has_changes()):
        return
    user_ids = connection.execute(
        sa.text(
            """
            SELECT DISTINCT ur.user_id
            FROM user_roles ur
            WHERE ur.role_id = :role_id
            """
        ),
        {"role_id": int(target.id)},
    ).scalars().all()
    for user_id in user_ids:
        _sync_primary_role_pointer(connection, int(user_id))
