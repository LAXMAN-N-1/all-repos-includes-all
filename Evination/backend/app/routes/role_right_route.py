from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel
from app.database import get_db
from app.models.user_m import User
from app.dependencies import get_current_active_user, PermissionChecker
from app.services.role_service import RoleService

router = APIRouter(prefix="/role-rights", tags=["Role Rights"])

class RoleRightCreate(BaseModel):
    role_id: int
    menu_id: int
    can_view: bool = True
    can_create: bool = False
    can_edit: bool = False
    can_delete: bool = False

class RoleRightUpdate(BaseModel):
    can_view: bool = True
    can_create: bool = False
    can_edit: bool = False
    can_delete: bool = False

@router.post(
    "/",
    dependencies=[Depends(PermissionChecker(["role.manage"]))]
)
async def create_role_right(
    data: RoleRightCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    role_service = RoleService(db)
    rights = data.dict(exclude={'role_id', 'menu_id'})
    role_service.create_role_right(data.role_id, data.menu_id, rights, current_user.username)
    return {"message": "Role right created and permissions synced"}

@router.put(
    "/{role_right_id}",
    dependencies=[Depends(PermissionChecker(["role.manage"]))]
)
async def update_role_right(
    role_right_id: int,
    data: RoleRightUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    role_service = RoleService(db)
    role_service.update_role_right(role_right_id, data.dict(), current_user.username)
    return {"message": "Role right updated and permissions synced"}

@router.get("/{role_id}")
async def get_role_rights(
    role_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    role_service = RoleService(db)
    role_rights = role_service.get_role_rights(role_id)
    
    return [{
        "id": rr.id,
        "menu_id": rr.menu_id,
        "can_view": rr.can_view,
        "can_create": rr.can_create,
        "can_edit": rr.can_edit,
        "can_delete": rr.can_delete
    } for rr in role_rights]

class RoleRightBulkItem(BaseModel):
    menu_id: int
    can_view: bool = False
    can_create: bool = False
    can_edit: bool = False
    can_delete: bool = False

class RoleRightBulkRequest(BaseModel):
    role_id: int
    rights: List[RoleRightBulkItem]

@router.post(
    "/bulk",
    dependencies=[Depends(PermissionChecker(["role.manage"]))]
)
async def bulk_sync_role_rights(
    data: RoleRightBulkRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    role_service = RoleService(db)
    rights_list = [item.dict() for item in data.rights]
    role_service.sync_role_rights_bulk(data.role_id, rights_list, current_user.username)
    return {"message": "Role rights synchronized successfully"}