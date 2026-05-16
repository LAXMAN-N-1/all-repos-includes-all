from typing import List
from sqlalchemy.orm import Session
from app.models.role_permission_m import RolePermission
from app.models.permission_m import Permission

def check_permission(db: Session, role_id: int, permission_code: str) -> bool:
    """
    Check if a role has a specific permission.
    
    Args:
        db: Database session
        role_id: Role ID
        permission_code: Permission code (e.g., "user.create")
    
    Returns:
        bool: True if role has permission, False otherwise
    """
    permission = db.query(Permission).filter(
        Permission.code == permission_code,
        Permission.inactive == False
    ).first()
    
    if not permission:
        return False
    
    role_permission = db.query(RolePermission).filter(
        RolePermission.role_id == role_id,
        RolePermission.permission_id == permission.id,
        RolePermission.inactive == False
    ).first()
    
    return role_permission is not None


def get_user_permissions(db: Session, role_id: int) -> List[str]:
    """
    Get all permission codes for a role.
    
    Args:
        db: Database session
        role_id: Role ID
    
    Returns:
        List of permission codes
    """
    role_permissions = db.query(RolePermission).filter(
        RolePermission.role_id == role_id,
        RolePermission.inactive == False
    ).all()
    
    permission_ids = [rp.permission_id for rp in role_permissions]
    
    permissions = db.query(Permission).filter(
        Permission.id.in_(permission_ids),
        Permission.inactive == False
    ).all()
    
    return [p.code for p in permissions]