from sqlalchemy.orm import Session
from typing import Optional, List, TYPE_CHECKING
from typing import Optional, List, TYPE_CHECKING
from app.models.role import Role, role_permissions
from app.models.permission import Permission
from app.models.audit_log import AuditActionType
from app.schemas.role_schema import RoleCreate, RoleUpdate

if TYPE_CHECKING:
    from app.services.audit_service import AuditService


class RoleService:
    """Service for role and permission management"""
    
    def __init__(self, db: Session, audit_service: "AuditService"):
        self.db = db
        self.audit_service = audit_service
    
    def create_role(self, data: RoleCreate, created_by: int) -> Role:
        """Create a new custom role"""
        # Check for duplicate name
        existing_name = self.db.query(Role).filter(Role.name == data.name).first()
        if existing_name:
            raise ValueError(f"Role with name {data.name} already exists")
        
        # Check for duplicate code
        existing_code = self.db.query(Role).filter(Role.code == data.code).first()
        if existing_code:
            raise ValueError(f"Role with code {data.code} already exists")
        
        # Create role
        role = Role(
            name=data.name,
            code=data.code,
            description=data.description,
            is_system_role=False,
            created_by=created_by
        )
        self.db.add(role)
        self.db.flush()  # Get the role ID
        
        # Assign permissions if provided
        if data.permission_ids:
            permissions = self.db.query(Permission).filter(
                Permission.id.in_(data.permission_ids)
            ).all()
            role.permissions = permissions
        
        self.db.commit()
        self.db.refresh(role)
        
        # Log the action
        self.audit_service.log_action(
            user_id=created_by,
            action=AuditActionType.CREATE,
            entity_type="Role",
            entity_id=role.id,
            new_values={"name": role.name, "code": role.code}
        )
        
        return role
    
    def get_role(self, role_id: int) -> Optional[Role]:
        """Get a single role by ID"""
        return self.db.query(Role).filter(
            Role.id == role_id,
            Role.inactive == False
        ).first()
    
    def get_role_by_code(self, code: str) -> Optional[Role]:
        """Get a role by code"""
        return self.db.query(Role).filter(
            Role.code == code,
            Role.inactive == False
        ).first()
    
    def get_roles(self) -> List[Role]:
        """Get all roles"""
        return self.db.query(Role).filter(Role.inactive == False).order_by(Role.name).all()
    
    def update_role(
        self,
        role_id: int,
        data: RoleUpdate,
        modified_by: int
    ) -> Optional[Role]:
        """Update a role"""
        role = self.get_role(role_id)
        if not role:
            return None
        
        # System roles can only have description updated
        if role.is_system_role and data.name:
            raise ValueError("Cannot modify name of system role")
        
        old_values = {"name": role.name, "description": role.description}
        
        # Update fields
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(role, field, value)
        
        role.modified_by = modified_by
        self.db.commit()
        self.db.refresh(role)
        
        # Log the action
        self.audit_service.log_action(
            user_id=modified_by,
            action=AuditActionType.UPDATE,
            entity_type="Role",
            entity_id=role.id,
            old_values=old_values,
            new_values=update_data
        )
        
        return role
    
    def delete_role(self, role_id: int, deleted_by: int) -> bool:
        """Delete a role (not allowed for system roles)"""
        role = self.get_role(role_id)
        if not role:
            return False
        
        if role.is_system_role:
            raise ValueError("Cannot delete system role")
        
        role.soft_delete(deleted_by)
        self.db.commit()
        
        # Log the action
        self.audit_service.log_action(
            user_id=deleted_by,
            action=AuditActionType.DELETE,
            entity_type="Role",
            entity_id=role.id
        )
        
        return True
    
    def assign_permissions(
        self,
        role_id: int,
        permission_ids: List[int],
        modified_by: int
    ) -> Optional[Role]:
        """Assign permissions to a role"""
        role = self.get_role(role_id)
        if not role:
            return None
        
        old_permission_ids = [str(p.id) for p in role.permissions]
        
        # Get permissions
        permissions = self.db.query(Permission).filter(
            Permission.id.in_(permission_ids)
        ).all()
        
        role.permissions = permissions
        role.modified_by = modified_by
        self.db.commit()
        self.db.refresh(role)
        
        # Log the action
        self.audit_service.log_action(
            user_id=modified_by,
            action=AuditActionType.UPDATE,
            entity_type="Role",
            entity_id=role.id,
            old_values={"permission_ids": old_permission_ids},
            new_values={"permission_ids": [str(p.id) for p in permissions]},
            description="Permissions updated"
        )
        
        return role
    
    def get_permissions(self) -> List[Permission]:
        """Get all available permissions"""
        return self.db.query(Permission).order_by(Permission.resource, Permission.action).all()
    
    def get_permission(self, permission_id: int) -> Optional[Permission]:
        """Get a single permission by ID"""
        return self.db.query(Permission).filter(Permission.id == permission_id).first()
    
