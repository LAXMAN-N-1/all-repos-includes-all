from sqlalchemy import Column, String, Text, Table, ForeignKey, Integer, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


# Association table for many-to-many relationship between roles and permissions
role_permissions = Table(
    'role_permissions',
    BaseModel.metadata,
    Column('role_id', Integer, ForeignKey('roles.id', ondelete='CASCADE'), primary_key=True),
    Column('permission_id', Integer, ForeignKey('permissions.id', ondelete='CASCADE'), primary_key=True),
    Column('created_at', DateTime(timezone=True), server_default=func.now())
)

# Association table for role-menu access
role_menus = Table(
    'role_menus',
    BaseModel.metadata,
    Column('role_id', Integer, ForeignKey('roles.id', ondelete='CASCADE'), primary_key=True),
    Column('menu_id', Integer, ForeignKey('menus.id', ondelete='CASCADE'), primary_key=True),
    Column('can_view', Boolean, default=True),
    Column('can_create', Boolean, default=False),
    Column('can_update', Boolean, default=False),
    Column('can_delete', Boolean, default=False),
    Column('created_at', DateTime(timezone=True), server_default=func.now())
)


class Role(BaseModel):
    """
    Role model for RBAC system.
    Defines what users can access and do in the system.
    """
    __tablename__ = "roles"

    name = Column(String(100), unique=True, nullable=False, index=True)
    code = Column(String(50), unique=True, nullable=False, index=True)
    description = Column(Text)
    
    # Is this a system role (cannot be deleted)
    is_system_role = Column(Boolean, default=False, nullable=False)
    
    # Relationships
    permissions = relationship("Permission", secondary=role_permissions, back_populates="roles")
    menus = relationship("Menu", secondary=role_menus, back_populates="roles")
    users = relationship("User", back_populates="role")

