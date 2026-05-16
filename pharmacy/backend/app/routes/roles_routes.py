from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.role_service import RoleService
from app.dependencies import get_role_service
from app.schemas.role_schema import (
    RoleCreate, RoleUpdate, RoleResponse, RoleDetailResponse,
    RoleListResponse, RolePermissionAssign, PermissionResponse,
    PermissionListResponse
)

router = APIRouter(prefix="/api/v1/roles", tags=["Roles"])



@router.get("/", response_model=RoleListResponse)
async def list_roles(
    current_user: User = Depends(get_current_user),
    service: RoleService = Depends(get_role_service)
):
    """List all roles. Available to all authenticated users."""
    roles = service.get_roles()
    
    return RoleListResponse(
        items=[
            RoleResponse(
                id=role.id,
                name=role.name,
                code=role.code,
                description=role.description,
                is_system_role=role.is_system_role,
                created_at=role.created_at,
                updated_at=role.updated_at
            ) for role in roles
        ],
        total=len(roles)
    )


@router.post("/", response_model=RoleDetailResponse, status_code=status.HTTP_201_CREATED)
async def create_role(
    data: RoleCreate,
    current_user: User = Depends(get_current_user),
    service: RoleService = Depends(get_role_service)
):
    """Create a new custom role. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can create roles")
    
    try:
        role = service.create_role(data, current_user.id)
        
        return RoleDetailResponse(
            id=role.id,
            name=role.name,
            code=role.code,
            description=role.description,
            is_system_role=role.is_system_role,
            created_at=role.created_at,
            updated_at=role.updated_at,
            permissions=[
                PermissionResponse(
                    id=p.id,
                    name=p.name,
                    code=p.code,
                    resource=p.resource,
                    action=p.action,
                    description=p.description
                ) for p in role.permissions
            ]
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/permissions", response_model=PermissionListResponse)
async def list_permissions(
    current_user: User = Depends(get_current_user),
    service: RoleService = Depends(get_role_service)
):
    """List all available permissions. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can view permissions")
    
    permissions = service.get_permissions()
    
    return PermissionListResponse(
        items=[
            PermissionResponse(
                id=p.id,
                name=p.name,
                code=p.code,
                resource=p.resource,
                action=p.action,
                description=p.description
            ) for p in permissions
        ],
        total=len(permissions)
    )


@router.get("/{role_id}", response_model=RoleDetailResponse)
async def get_role(
    role_id: int,
    current_user: User = Depends(get_current_user),
    service: RoleService = Depends(get_role_service)
):
    """Get a single role by ID with its permissions."""
    role = service.get_role(role_id)
    if not role:
        raise HTTPException(status_code=404, detail="Role not found")
    
    return RoleDetailResponse(
        id=role.id,
        name=role.name,
        code=role.code,
        description=role.description,
        is_system_role=role.is_system_role,
        created_at=role.created_at,
        updated_at=role.updated_at,
        permissions=[
            PermissionResponse(
                id=p.id,
                name=p.name,
                code=p.code,
                resource=p.resource,
                action=p.action,
                description=p.description
            ) for p in role.permissions
        ]
    )


@router.put("/{role_id}", response_model=RoleResponse)
async def update_role(
    role_id: int,
    data: RoleUpdate,
    current_user: User = Depends(get_current_user),
    service: RoleService = Depends(get_role_service)
):
    """Update a role. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can update roles")
    
    try:
        role = service.update_role(role_id, data, current_user.id)
        if not role:
            raise HTTPException(status_code=404, detail="Role not found")
        
        return RoleResponse(
            id=role.id,
            name=role.name,
            code=role.code,
            description=role.description,
            is_system_role=role.is_system_role,
            created_at=role.created_at,
            updated_at=role.updated_at
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{role_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_role(
    role_id: int,
    current_user: User = Depends(get_current_user),
    service: RoleService = Depends(get_role_service)
):
    """Delete a role. Requires HQ Admin role. System roles cannot be deleted."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can delete roles")
    
    try:
        success = service.delete_role(role_id, current_user.id)
        if not success:
            raise HTTPException(status_code=404, detail="Role not found")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/{role_id}/permissions", response_model=RoleDetailResponse)
async def assign_permissions_to_role(
    role_id: int,
    data: RolePermissionAssign,
    current_user: User = Depends(get_current_user),
    service: RoleService = Depends(get_role_service)
):
    """Assign permissions to a role. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can assign permissions")
    
    role = service.assign_permissions(role_id, data.permission_ids, current_user.id)
    if not role:
        raise HTTPException(status_code=404, detail="Role not found")
    
    return RoleDetailResponse(
        id=role.id,
        name=role.name,
        code=role.code,
        description=role.description,
        is_system_role=role.is_system_role,
        created_at=role.created_at,
        updated_at=role.updated_at,
        permissions=[
            PermissionResponse(
                id=p.id,
                name=p.name,
                code=p.code,
                resource=p.resource,
                action=p.action,
                description=p.description
            ) for p in role.permissions
        ]
    )
