from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from typing import Optional
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.user_service import UserService
from app.dependencies import get_user_service
from app.schemas.user_schema import (
    UserCreate, UserUpdate, UserResponse, UserListResponse,
    UserFilters, UserStoreAssign, UserPasswordUpdate, UserRoleEnum,
    StoreBasicResponse
)

router = APIRouter(prefix="/api/v1/users", tags=["Users"])



@router.get("/", response_model=UserListResponse)
async def list_users(
    role: Optional[UserRoleEnum] = Query(None),
    store_id: Optional[int] = Query(None),
    inactive: Optional[bool] = Query(None),
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: UserService = Depends(get_user_service)
):
    """
    List users with filters.
    - HQ Admin: Can see all users in organization
    - Store Admin: Only users assigned to their stores
    """
    # Build filters
    filters = UserFilters(
        role=role,
        store_id=store_id,
        inactive=inactive,
        search=search
    )
    
    # Store Admin can only see users in their assigned stores
    if current_user.role.code == UserRole.STORE_ADMIN:
        assigned_store_ids = [s.id for s in current_user.assigned_stores]
        if store_id and store_id not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        if not store_id and assigned_store_ids:
            filters.store_id = assigned_store_ids[0]
    
    users, total = service.get_users(filters, page, page_size)
    
    # Build response
    items = []
    for user in users:
        items.append(UserResponse(
            id=user.id,
            organization_id=user.organization_id,
            email=user.email,
            full_name=user.full_name,
            phone=user.phone,
            role=user.role,
            inactive=user.inactive,
            email_verified=user.email_verified or False,
            phone_verified=user.phone_verified or False,
            last_login_at=user.last_login_at,
            assigned_stores=[
                StoreBasicResponse(
                    id=s.id,
                    name=s.name,
                    code=s.code,
                    city=s.city
                ) for s in user.assigned_stores
            ],
            created_at=user.created_at,
            updated_at=user.updated_at
        ))
    
    total_pages = (total + page_size - 1) // page_size
    
    return UserListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )


@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    data: UserCreate,
    current_user: User = Depends(get_current_user),
    service: UserService = Depends(get_user_service)
):
    """Create a new user. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can create users")
    
    
    try:
        user = service.create_user(data, current_user.id)
        
        return UserResponse(
            id=user.id,
            organization_id=user.organization_id,
            email=user.email,
            full_name=user.full_name,
            phone=user.phone,
            role=user.role,
            inactive=user.inactive,
            email_verified=user.email_verified or False,
            phone_verified=user.phone_verified or False,
            last_login_at=user.last_login_at,
            assigned_stores=[
                StoreBasicResponse(
                    id=s.id,
                    name=s.name,
                    code=s.code,
                    city=s.city
                ) for s in user.assigned_stores
            ],
            created_at=user.created_at,
            updated_at=user.updated_at
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user)
):
    """Get current logged-in user profile."""
    return UserResponse(
        id=current_user.id,
        organization_id=current_user.organization_id,
        email=current_user.email,
        full_name=current_user.full_name,
        phone=current_user.phone,
        role=current_user.role,
        inactive=current_user.inactive,
        email_verified=current_user.email_verified or False,
        phone_verified=current_user.phone_verified or False,
        last_login_at=current_user.last_login_at,
        assigned_stores=[
            StoreBasicResponse(
                id=s.id,
                name=s.name,
                code=s.code,
                city=s.city
            ) for s in current_user.assigned_stores
        ],
        created_at=current_user.created_at,
        updated_at=current_user.updated_at
    )


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    current_user: User = Depends(get_current_user),
    service: UserService = Depends(get_user_service)
):
    """Get a single user by ID."""
    user = service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Verify access
    if current_user.role.code != UserRole.HQ_ADMIN:
        # Store Admin can only view users in their stores
        user_store_ids = {s.id for s in user.assigned_stores}
        current_store_ids = {s.id for s in current_user.assigned_stores}
        if not user_store_ids.intersection(current_store_ids):
            raise HTTPException(status_code=403, detail="Access denied")
    
    return UserResponse(
        id=user.id,
        organization_id=user.organization_id,
        email=user.email,
        full_name=user.full_name,
        phone=user.phone,
        role=user.role,
        inactive=user.inactive,
        email_verified=user.email_verified or False,
        phone_verified=user.phone_verified or False,
        last_login_at=user.last_login_at,
        assigned_stores=[
            StoreBasicResponse(
                id=s.id,
                name=s.name,
                code=s.code,
                city=s.city
            ) for s in user.assigned_stores
        ],
        created_at=user.created_at,
        updated_at=user.updated_at
    )


@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    data: UserUpdate,
    current_user: User = Depends(get_current_user),
    service: UserService = Depends(get_user_service)
):
    """Update a user. HQ Admin can update any user, others can only update themselves."""
    # Check permissions
    if current_user.role.code != UserRole.HQ_ADMIN and current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Non-admins cannot change their own role
    if current_user.role.code != UserRole.HQ_ADMIN and data.role_id is not None:
        raise HTTPException(status_code=403, detail="Cannot change your own role")
    
    user = service.update_user(user_id, data, current_user.id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserResponse(
        id=user.id,
        organization_id=user.organization_id,
        email=user.email,
        full_name=user.full_name,
        phone=user.phone,
        role=user.role,
        inactive=user.inactive,
        email_verified=user.email_verified or False,
        phone_verified=user.phone_verified or False,
        last_login_at=user.last_login_at,
        assigned_stores=[
            StoreBasicResponse(
                id=s.id,
                name=s.name,
                code=s.code,
                city=s.city
            ) for s in user.assigned_stores
        ],
        created_at=user.created_at,
        updated_at=user.updated_at
    )


@router.put("/{user_id}/password")
async def update_user_password(
    user_id: int,
    data: UserPasswordUpdate,
    current_user: User = Depends(get_current_user),
    service: UserService = Depends(get_user_service)
):
    """Update user password. Users can only update their own password."""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Can only update your own password")
    
    try:
        success = service.update_password(user_id, data, current_user.id)
        if not success:
            raise HTTPException(status_code=404, detail="User not found")
        return {"message": "Password updated successfully"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int,
    current_user: User = Depends(get_current_user),
    service: UserService = Depends(get_user_service)
):
    """Soft delete a user. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can delete users")
    
    # Prevent self-deletion
    if current_user.id == user_id:
        raise HTTPException(status_code=400, detail="Cannot delete yourself")
    
    success = service.delete_user(user_id, current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="User not found")


@router.post("/{user_id}/stores", response_model=UserResponse)
async def assign_stores_to_user(
    user_id: int,
    data: UserStoreAssign,
    current_user: User = Depends(get_current_user),
    service: UserService = Depends(get_user_service)
):
    """Assign stores to a user. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can assign stores")
    
    user = service.assign_stores(user_id, data.store_ids, current_user.id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserResponse(
        id=user.id,
        organization_id=user.organization_id,
        email=user.email,
        full_name=user.full_name,
        phone=user.phone,
        role=user.role,
        inactive=user.inactive,
        email_verified=user.email_verified or False,
        phone_verified=user.phone_verified or False,
        last_login_at=user.last_login_at,
        assigned_stores=[
            StoreBasicResponse(
                id=s.id,
                name=s.name,
                code=s.code,
                city=s.city
            ) for s in user.assigned_stores
        ],
        created_at=user.created_at,
        updated_at=user.updated_at
    )
