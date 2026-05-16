from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.role_schema import RoleCreate, RoleUpdate, RoleResponse
from app.models.user_m import User
from app.dependencies import get_current_active_user, PermissionChecker
from app.services.role_service import RoleService

router = APIRouter(prefix="/roles", tags=["Roles"])

@router.post(
    "/",
    response_model=RoleResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["role.create"]))]
)
async def create_role(
    role: RoleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    role_service = RoleService(db)
    return role_service.create_role(role, current_user.username)

@router.get(
    "/",
    response_model=List[RoleResponse],
    dependencies=[Depends(PermissionChecker(["role.view"]))]
)
async def get_roles(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    role_service = RoleService(db)
    return role_service.get_roles(skip, limit)

@router.get(
    "/{role_id}",
    response_model=RoleResponse,
    dependencies=[Depends(PermissionChecker(["role.view"]))]
)
async def get_role(
    role_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    role_service = RoleService(db)
    return role_service.get_role(role_id)

@router.put(
    "/{role_id}",
    response_model=RoleResponse,
    dependencies=[Depends(PermissionChecker(["role.update"]))]
)
async def update_role(
    role_id: int,
    role_update: RoleUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    role_service = RoleService(db)
    return role_service.update_role(role_id, role_update, current_user.username)

@router.delete(
    "/{role_id}",
    dependencies=[Depends(PermissionChecker(["role.delete"]))]
)
async def delete_role(
    role_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    role_service = RoleService(db)
    role_service.delete_role(role_id, current_user.username)
    return {"message": "Role deleted successfully"}