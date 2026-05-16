from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from typing import Optional
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.inventory_service import InventoryService
from app.dependencies import get_inventory_service
from app.schemas.inventory_schema import (
    InventoryBatchCreate, InventoryBatchUpdate, StockAdjustment,
    InventoryBatchResponse, InventoryAlertResponse, InventoryListResponse,
    InventoryFilters
)
from datetime import date

router = APIRouter(prefix="/api/v1/inventory", tags=["Inventory"])



@router.get("/", response_model=InventoryListResponse)
async def list_inventory_batches(
    store_id: Optional[int] = Query(None),
    medicine_id: Optional[int] = Query(None),
    product_name: Optional[str] = Query(None),
    batch_number: Optional[str] = Query(None),
    low_stock_only: bool = Query(False),
    expiring_within_days: Optional[int] = Query(None),
    expired_only: bool = Query(False),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: InventoryService = Depends(get_inventory_service)
):
    """
    List inventory batches with filters.
    - HQ Admin: Can see all stores
    - Store Admin/Pharmacist: Only assigned stores
    """
    # Build filters
    filters = InventoryFilters(
        store_id=store_id,
        medicine_id=medicine_id,
        product_name=product_name,
        batch_number=batch_number,
        low_stock_only=low_stock_only,
        expiring_within_days=expiring_within_days,
        expired_only=expired_only
    )
    
    # Apply store access control
    if current_user.role.code != UserRole.HQ_ADMIN.value:
        assigned_store_ids = [str(s.id) for s in current_user.assigned_stores]
        if store_id and str(store_id) not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        if not store_id and assigned_store_ids:
            filters.store_id = int(assigned_store_ids[0])
    
    batches, total = service.get_batches(filters, page, page_size)
    
    # Build response
    items = []
    for batch in batches:
        days_until = (batch.expiry_date - date.today()).days if batch.expiry_date else 0
        items.append(InventoryBatchResponse(
            id=batch.id,
            store_id=batch.store_id,
            medicine_id=batch.medicine_id,
            product_name=batch.product_name,
            batch_number=batch.batch_number,
            expiry_date=batch.expiry_date,
            manufacture_date=batch.manufacture_date,
            quantity=batch.quantity,
            quantity_reserved=batch.quantity_reserved,
            quantity_available=batch.quantity - batch.quantity_reserved,
            reorder_level=batch.reorder_level,
            cost_price=batch.cost_price,
            selling_price=batch.selling_price,
            mrp=batch.mrp,
            supplier_invoice=batch.supplier_invoice,
            supplier_batch=batch.supplier_batch,
            rack_location=batch.rack_location,
            is_low_stock=batch.quantity <= batch.reorder_level,
            days_until_expiry=days_until,
            created_at=batch.created_at,
            updated_at=batch.updated_at
        ))
    
    total_pages = (total + page_size - 1) // page_size
    
    return InventoryListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )


@router.post("/", response_model=InventoryBatchResponse, status_code=status.HTTP_201_CREATED)
async def create_inventory_batch(
    data: InventoryBatchCreate,
    current_user: User = Depends(get_current_user),
    service: InventoryService = Depends(get_inventory_service)
):
    """Create a new inventory batch. Requires Store Admin or HQ Admin role."""
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Verify store access
    if current_user.role.code == UserRole.STORE_ADMIN.value:
        assigned_store_ids = [str(s.id) for s in current_user.assigned_stores]
        if str(data.store_id) not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
    
    batch = service.create_batch(data, current_user.id)
    
    days_until = (batch.expiry_date - date.today()).days if batch.expiry_date else 0
    return InventoryBatchResponse(
        id=batch.id,
        store_id=batch.store_id,
        medicine_id=batch.medicine_id,
        product_name=batch.product_name,
        batch_number=batch.batch_number,
        expiry_date=batch.expiry_date,
        manufacture_date=batch.manufacture_date,
        quantity=batch.quantity,
        quantity_reserved=batch.quantity_reserved or 0,
        quantity_available=batch.quantity - (batch.quantity_reserved or 0),
        reorder_level=batch.reorder_level,
        cost_price=batch.cost_price,
        selling_price=batch.selling_price,
        mrp=batch.mrp,
        supplier_invoice=batch.supplier_invoice,
        supplier_batch=batch.supplier_batch,
        rack_location=batch.rack_location,
        is_low_stock=batch.quantity <= batch.reorder_level,
        days_until_expiry=days_until,
        created_at=batch.created_at,
        updated_at=batch.updated_at
    )


@router.get("/alerts", response_model=InventoryAlertResponse)
async def get_inventory_alerts(
    store_id: Optional[int] = Query(None),
    current_user: User = Depends(get_current_user),
    service: InventoryService = Depends(get_inventory_service)
):
    """Get inventory alerts (low stock, expiring soon, expired)."""
    # Apply store access control
    if current_user.role.code != UserRole.HQ_ADMIN.value:
        assigned_store_ids = [str(s.id) for s in current_user.assigned_stores]
        if store_id and str(store_id) not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        if not store_id and assigned_store_ids:
            store_id = int(assigned_store_ids[0])
    
    return service.get_inventory_alerts(store_id)


@router.get("/{batch_id}", response_model=InventoryBatchResponse)
async def get_inventory_batch(
    batch_id: int,
    current_user: User = Depends(get_current_user),
    service: InventoryService = Depends(get_inventory_service)
):
    """Get a single inventory batch by ID."""
    batch = service.get_batch(batch_id)
    if not batch:
        raise HTTPException(status_code=404, detail="Inventory batch not found")
    
    # Verify store access
    if current_user.role.code != UserRole.HQ_ADMIN.value:
        assigned_store_ids = [str(s.id) for s in current_user.assigned_stores]
        if str(batch.store_id) not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
    
    days_until = (batch.expiry_date - date.today()).days if batch.expiry_date else 0
    return InventoryBatchResponse(
        id=batch.id,
        store_id=batch.store_id,
        medicine_id=batch.medicine_id,
        product_name=batch.product_name,
        batch_number=batch.batch_number,
        expiry_date=batch.expiry_date,
        manufacture_date=batch.manufacture_date,
        quantity=batch.quantity,
        quantity_reserved=batch.quantity_reserved or 0,
        quantity_available=batch.quantity - (batch.quantity_reserved or 0),
        reorder_level=batch.reorder_level,
        cost_price=batch.cost_price,
        selling_price=batch.selling_price,
        mrp=batch.mrp,
        supplier_invoice=batch.supplier_invoice,
        supplier_batch=batch.supplier_batch,
        rack_location=batch.rack_location,
        is_low_stock=batch.quantity <= batch.reorder_level,
        days_until_expiry=days_until,
        created_at=batch.created_at,
        updated_at=batch.updated_at
    )


@router.put("/{batch_id}", response_model=InventoryBatchResponse)
async def update_inventory_batch(
    batch_id: int,
    data: InventoryBatchUpdate,
    current_user: User = Depends(get_current_user),
    service: InventoryService = Depends(get_inventory_service)
):
    """Update an inventory batch."""
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    batch = service.update_batch(batch_id, data, current_user.id)
    if not batch:
        raise HTTPException(status_code=404, detail="Inventory batch not found")
    
    days_until = (batch.expiry_date - date.today()).days if batch.expiry_date else 0
    return InventoryBatchResponse(
        id=batch.id,
        store_id=batch.store_id,
        medicine_id=batch.medicine_id,
        product_name=batch.product_name,
        batch_number=batch.batch_number,
        expiry_date=batch.expiry_date,
        manufacture_date=batch.manufacture_date,
        quantity=batch.quantity,
        quantity_reserved=batch.quantity_reserved or 0,
        quantity_available=batch.quantity - (batch.quantity_reserved or 0),
        reorder_level=batch.reorder_level,
        cost_price=batch.cost_price,
        selling_price=batch.selling_price,
        mrp=batch.mrp,
        supplier_invoice=batch.supplier_invoice,
        supplier_batch=batch.supplier_batch,
        rack_location=batch.rack_location,
        is_low_stock=batch.quantity <= batch.reorder_level,
        days_until_expiry=days_until,
        created_at=batch.created_at,
        updated_at=batch.updated_at
    )


@router.delete("/{batch_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_inventory_batch(
    batch_id: int,
    current_user: User = Depends(get_current_user),
    service: InventoryService = Depends(get_inventory_service)
):
    """Soft delete an inventory batch."""
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    success = service.delete_batch(batch_id, current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Inventory batch not found")


@router.post("/adjust")
async def adjust_stock(
    data: StockAdjustment,
    current_user: User = Depends(get_current_user),
    service: InventoryService = Depends(get_inventory_service)
):
    """
    Adjust stock quantity with audit logging.
    Use positive adjustment_quantity to increase, negative to decrease.
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value, UserRole.PHARMACIST.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    try:
        batch = service.adjust_stock(data, current_user.id)
        if not batch:
            raise HTTPException(status_code=404, detail="Inventory batch not found")
        
        return {
            "message": "Stock adjusted successfully",
            "batch_id": str(batch.id),
            "new_quantity": batch.quantity
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
