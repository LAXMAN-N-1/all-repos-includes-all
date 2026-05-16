from sqlalchemy.orm import Session
from typing import List
from fastapi import HTTPException, status
from app.models.role_m import Role
from app.models.role_right_m import RoleRight
from app.schemas.role_schema import RoleCreate, RoleUpdate
from app.services.permission_sync_service import PermissionSyncService

class RoleService:
    def __init__(self, db: Session):
        self.db = db

    # Role CRUD
    def create_role(self, role: RoleCreate, created_by: str) -> Role:
        db_role = self.db.query(Role).filter(Role.code == role.code).first()
        if db_role:
            raise HTTPException(status_code=400, detail="Role code already exists")
        
        new_role = Role(**role.dict(), created_by=created_by)
        self.db.add(new_role)
        self.db.commit()
        self.db.refresh(new_role)
        return new_role

    def get_roles(self, skip: int = 0, limit: int = 100) -> List[Role]:
        from sqlalchemy.orm import joinedload
        return self.db.query(Role).options(
            joinedload(Role.role_rights).joinedload(RoleRight.menu)
        ).filter(Role.inactive == False).offset(skip).limit(limit).all()

    def get_role(self, role_id: int) -> Role:
        from sqlalchemy.orm import joinedload
        role = self.db.query(Role).options(
            joinedload(Role.role_rights).joinedload(RoleRight.menu)
        ).filter(Role.id == role_id, Role.inactive == False).first()
        if not role:
            raise HTTPException(status_code=404, detail="Role not found")
        return role

    def update_role(self, role_id: int, role_update: RoleUpdate, modified_by: str) -> Role:
        role = self.get_role(role_id)
        for key, value in role_update.dict(exclude_unset=True).items():
            setattr(role, key, value)
        
        role.modified_by = modified_by
        self.db.commit()
        self.db.refresh(role)
        return role

    def delete_role(self, role_id: int, modified_by: str):
        role = self.get_role(role_id)
        role.inactive = True
        role.modified_by = modified_by
        self.db.commit()

    # Role Right Management
    def create_role_right(self, role_id: int, menu_id: int, rights: dict, created_by: str):
        # Check if already exists
        existing = self.db.query(RoleRight).filter(
            RoleRight.role_id == role_id,
            RoleRight.menu_id == menu_id
        ).first()
        
        if existing:
            raise HTTPException(status_code=400, detail="Role right already exists")
        
        role_right = RoleRight(
            role_id=role_id,
            menu_id=menu_id,
            **rights,
            created_by=created_by
        )
        self.db.add(role_right)
        self.db.flush()
        
        # Sync Permissions
        PermissionSyncService.sync_role_permissions(self.db, role_id, menu_id, role_right)
        self.db.commit()
        return role_right

    def update_role_right(self, role_right_id: int, rights: dict, modified_by: str):
        role_right = self.db.query(RoleRight).filter(RoleRight.id == role_right_id).first()
        if not role_right:
            raise HTTPException(status_code=404, detail="Role right not found")
        
        for key, value in rights.items():
            setattr(role_right, key, value)
            
        role_right.modified_by = modified_by
        self.db.flush()
        
        # Sync Permissions
        PermissionSyncService.sync_role_permissions(self.db, role_right.role_id, role_right.menu_id, role_right)
        self.db.commit()
        return role_right

    def get_role_rights(self, role_id: int) -> List[RoleRight]:
        return self.db.query(RoleRight).filter(
            RoleRight.role_id == role_id,
            RoleRight.inactive == False
        ).all()

    def sync_role_rights_bulk(self, role_id: int, rights_list: List[dict], modified_by: str):
        for item in rights_list:
            menu_id = item['menu_id']
            rights = {k: v for k, v in item.items() if k in ['can_view', 'can_create', 'can_edit', 'can_delete']}
            
            existing = self.db.query(RoleRight).filter(
                RoleRight.role_id == role_id,
                RoleRight.menu_id == menu_id
            ).first()
            
            if existing:
                for k, v in rights.items():
                    setattr(existing, k, v)
                existing.modified_by = modified_by
                # Permission sync call per item or bulk? Per item is safer for now.
                PermissionSyncService.sync_role_permissions(self.db, role_id, menu_id, existing)
            else:
                new_right = RoleRight(
                    role_id=role_id,
                    menu_id=menu_id,
                    **rights,
                    created_by=modified_by
                )
                self.db.add(new_right)
                self.db.flush() # get ID
                PermissionSyncService.sync_role_permissions(self.db, role_id, menu_id, new_right)
        
        self.db.commit()
