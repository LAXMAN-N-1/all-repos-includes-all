from sqlalchemy.orm import Session
from app.models.role_right_m import RoleRight
from app.models.role_permission_m import RolePermission
from app.models.menu_permission_m import MenuPermission
from app.models.permission_m import Permission

class PermissionSyncService:
    """
    Service to automatically sync UI menu permissions (role_rights)
    with backend action permissions (role_permissions).
    """
    
    @staticmethod
    def sync_role_permissions(db: Session, role_id: int, menu_id: int, role_right: RoleRight):
        """
        When SuperAdmin updates role_rights, automatically update role_permissions.
        
        Args:
            db: Database session
            role_id: Role ID
            menu_id: Menu ID
            role_right: RoleRight object with can_view, can_create, can_edit, can_delete
        """
        
        # Get all menu_permissions for this menu
        menu_perms = db.query(MenuPermission).filter(
            MenuPermission.menu_id == menu_id,
            MenuPermission.inactive == False
        ).all()
        
        # Map action_type to role_right attribute
        action_map = {
            "view": role_right.can_view,
            "create": role_right.can_create,
            "edit": role_right.can_edit,
            "delete": role_right.can_delete
        }
        
        for menu_perm in menu_perms:
            permission_id = menu_perm.permission_id
            action_type = menu_perm.action_type
            
            # Check if this action is enabled in role_right
            is_enabled = action_map.get(action_type, False)
            
            # Check if role_permission already exists
            existing = db.query(RolePermission).filter(
                RolePermission.role_id == role_id,
                RolePermission.permission_id == permission_id
            ).first()
            
            if is_enabled:
                # Add or activate permission
                if existing:
                    existing.inactive = False
                    existing.modified_by = "system"
                else:
                    new_role_perm = RolePermission(
                        role_id=role_id,
                        permission_id=permission_id,
                        created_by="system"
                    )
                    db.add(new_role_perm)
            else:
                # Remove or deactivate permission
                if existing:
                    existing.inactive = True
                    existing.modified_by = "system"
        
        db.commit()
    
    @staticmethod
    def sync_all_role_permissions(db: Session, role_id: int):
        """
        Sync all menu permissions for a role.
        Useful when creating a new role or bulk updates.
        """
        role_rights = db.query(RoleRight).filter(
            RoleRight.role_id == role_id,
            RoleRight.inactive == False
        ).all()
        
        for role_right in role_rights:
            PermissionSyncService.sync_role_permissions(
                db, role_id, role_right.menu_id, role_right
            )