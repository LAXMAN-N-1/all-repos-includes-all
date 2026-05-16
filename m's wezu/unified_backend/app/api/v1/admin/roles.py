from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session
from typing import List
from app.api import deps
from app.services.role_service import role_service
from app.schemas.rbac import RoleCreate, RoleUpdate, RoleResponse, PermissionResponse
from app.models.rbac import Role
from app.models.user import User

router = APIRouter()

@router.get("/", response_model=List[RoleResponse])
async def list_roles(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
):
    """List all available roles and their permissions"""
    return role_service.get_roles(db, include_permissions=True)

@router.get("/permissions", response_model=List[PermissionResponse])
async def list_permissions(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
):
    """List all available permissions in the system"""
    return role_service.list_permissions(db)

@router.post("/", response_model=RoleResponse, status_code=status.HTTP_201_CREATED)
async def create_role(
    role_in: RoleCreate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
):
    """Create a new custom role with permissions"""
    if role_service.get_role_by_name(db, role_in.name):
        raise HTTPException(status_code=400, detail="Role already exists")
    
    role = Role(
        name=role_in.name,
        description=role_in.description,
        category=role_in.category,
        level=role_in.level,
        is_system_role=False
    )
    role_data = {
        "name": role.name,
        "description": role.description,
        "category": role.category,
        "level": role.level,
        "is_system_role": role.is_system_role,
        "is_custom_role": role.is_custom_role,
        "scope_owner": role.scope_owner,
        "is_active": role.is_active,
        "icon": role.icon,
        "color": role.color,
        "dealer_id": role.dealer_id,
    }
    return role_service.create_role_record(
        db,
        role_data=role_data,
        permission_ids=role_in.permission_ids,
    )

@router.put("/{id}", response_model=RoleResponse)
async def update_role(
    id: int,
    role_in: RoleUpdate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
):
    """Update a role's metadata and permissions"""
    update_data = role_in.model_dump(exclude={"permission_ids"}, exclude_unset=True)
    role = role_service.update_role_fields(
        db,
        id,
        update_data=update_data,
        permission_ids=role_in.permission_ids,
    )
    if not role:
        raise HTTPException(status_code=404, detail="Role not found")
    return role
