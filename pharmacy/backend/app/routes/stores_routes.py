from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from typing import Optional
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.store_service import StoreService
from app.dependencies import get_store_service
from app.schemas.store_schema import (
    StoreCreate, StoreUpdate, StoreResponse, StoreDetailResponse,
    StoreListResponse, StoreFilters, UserBasicResponse
)

router = APIRouter(prefix="/api/v1/stores", tags=["Stores"])



@router.get("/", response_model=StoreListResponse)
async def list_stores(
    city: Optional[str] = Query(None),
    state: Optional[str] = Query(None),
    inactive: Optional[bool] = Query(None),
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: StoreService = Depends(get_store_service)
):
    """
    List stores with filters.
    - HQ Admin: Can see all stores in organization
    - Store Admin/Pharmacist: Only their assigned stores
    """
    # Build filters
    filters = StoreFilters(
        city=city,
        state=state,
        inactive=inactive,
        search=search
    )
    
    # Non-HQ Admin users can only see their assigned stores
    if current_user.role.code != UserRole.HQ_ADMIN:
        assigned_store_ids = [s.id for s in current_user.assigned_stores]
        stores = [s for s in current_user.assigned_stores if s.inactive == False]
        
        # Apply additional filters manually
        if city:
            stores = [s for s in stores if city.lower() in s.city.lower()]
        if state:
            stores = [s for s in stores if state.lower() in s.state.lower()]
        if inactive is not None:
            stores = [s for s in stores if s.inactive == inactive]
        if search:
            search_lower = search.lower()
            stores = [s for s in stores if search_lower in s.name.lower() or search_lower in s.code.lower()]
        
        total = len(stores)
        offset = (page - 1) * page_size
        stores = stores[offset:offset + page_size]
    else:
        stores, total = service.get_stores(filters, page, page_size)
    
    # Build response
    items = []
    for store in stores:
        user_count = service.get_user_count(store.id)
        items.append(StoreResponse(
            id=store.id,
            organization_id=store.organization_id,
            name=store.name,
            code=store.code,
            address=store.address,
            city=store.city,
            state=store.state,
            postal_code=store.postal_code,
            phone=store.phone,
            email=store.email,
            operating_hours=store.operating_hours,
            license_number=store.license_number,
            license_expiry=store.license_expiry,
            inactive=store.inactive,
            user_count=user_count,
            created_at=store.created_at,
            updated_at=store.updated_at
        ))
    
    total_pages = (total + page_size - 1) // page_size if total > 0 else 1
    
    return StoreListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )


@router.post("/", response_model=StoreResponse, status_code=status.HTTP_201_CREATED)
async def create_store(
    data: StoreCreate,
    current_user: User = Depends(get_current_user),
    service: StoreService = Depends(get_store_service)
):
    """Create a new store. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can create stores")
    
    
    try:
        store = service.create_store(data, current_user.id)
        
        return StoreResponse(
            id=store.id,
            organization_id=store.organization_id,
            name=store.name,
            code=store.code,
            address=store.address,
            city=store.city,
            state=store.state,
            postal_code=store.postal_code,
            phone=store.phone,
            email=store.email,
            operating_hours=store.operating_hours,
            license_number=store.license_number,
            license_expiry=store.license_expiry,
            inactive=store.inactive,
            user_count=0,
            created_at=store.created_at,
            updated_at=store.updated_at
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{store_id}", response_model=StoreDetailResponse)
async def get_store(
    store_id: int,
    current_user: User = Depends(get_current_user),
    service: StoreService = Depends(get_store_service)
):
    """Get a single store by ID with assigned users."""
    store = service.get_store(store_id)
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")
    
    # Verify access
    if current_user.role.code != UserRole.HQ_ADMIN:
        assigned_store_ids = [s.id for s in current_user.assigned_stores]
        if store_id not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
    
    # Get assigned users
    users = service.get_store_users(store_id)
    
    return StoreDetailResponse(
        id=store.id,
        organization_id=store.organization_id,
        name=store.name,
        code=store.code,
        address=store.address,
        city=store.city,
        state=store.state,
        postal_code=store.postal_code,
        phone=store.phone,
        email=store.email,
        operating_hours=store.operating_hours,
        license_number=store.license_number,
        license_expiry=store.license_expiry,
        inactive=store.inactive,
        user_count=len(users),
        created_at=store.created_at,
        updated_at=store.updated_at,
        assigned_users=[
            UserBasicResponse(
                id=u.id,
                full_name=u.full_name,
                email=u.email,
                role=u.role.code
            ) for u in users
        ]
    )


@router.put("/{store_id}", response_model=StoreResponse)
async def update_store(
    store_id: int,
    data: StoreUpdate,
    current_user: User = Depends(get_current_user),
    service: StoreService = Depends(get_store_service)
):
    """Update a store. Requires HQ Admin or Store Admin role."""
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Store Admin can only update their assigned stores
    if current_user.role.code == UserRole.STORE_ADMIN:
        assigned_store_ids = [s.id for s in current_user.assigned_stores]
        if store_id not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
    
    store = service.update_store(store_id, data, current_user.id)
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")
    
    user_count = service.get_user_count(store_id)
    
    return StoreResponse(
        id=store.id,
        organization_id=store.organization_id,
        name=store.name,
        code=store.code,
        address=store.address,
        city=store.city,
        state=store.state,
        postal_code=store.postal_code,
        phone=store.phone,
        email=store.email,
        operating_hours=store.operating_hours,
        license_number=store.license_number,
        license_expiry=store.license_expiry,
        inactive=store.inactive,
        user_count=user_count,
        created_at=store.created_at,
        updated_at=store.updated_at
    )


@router.delete("/{store_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_store(
    store_id: int,
    current_user: User = Depends(get_current_user),
    service: StoreService = Depends(get_store_service)
):
    """Soft delete a store. Requires HQ Admin role."""
    if current_user.role.code != UserRole.HQ_ADMIN:
        raise HTTPException(status_code=403, detail="Only HQ Admin can delete stores")
    
    success = service.delete_store(store_id, current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Store not found")


@router.get("/{store_id}/users")
async def get_store_users(
    store_id: int,
    current_user: User = Depends(get_current_user),
    service: StoreService = Depends(get_store_service)
):
    """Get all users assigned to a store."""
    # Verify access
    if current_user.role.code != UserRole.HQ_ADMIN:
        assigned_store_ids = [s.id for s in current_user.assigned_stores]
        if store_id not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
    
    store = service.get_store(store_id)
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")
    
    users = service.get_store_users(store_id)
    
    return {
        "store_id": str(store_id),
        "store_name": store.name,
        "users": [
            UserBasicResponse(
                id=u.id,
                full_name=u.full_name,
                email=u.email,
                role=u.role.code
            ) for u in users
        ],
        "total": len(users)
    }
