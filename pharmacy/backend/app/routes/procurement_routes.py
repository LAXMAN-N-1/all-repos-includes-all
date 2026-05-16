from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional, List
from typing import Optional, List
from datetime import datetime
from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.procurement_service import ProcurementService
from app.services.audit_service import AuditService
from app.services.inventory_service import InventoryService
from app.dependencies import get_inventory_service
from app.schemas.procurement_schema import (
    ProcurementOrderCreate, ProcurementOrderUpdate,
    ProcurementFilters, ProcurementStatusEnum,
    ProcurementOrderResponse, ProcurementOrderSummaryResponse,
    ProcurementOrderListResponse, ProcurementItemResponse,
    ProcurementSubmit, ProcurementApproval, ProcurementReceive
)

router = APIRouter(prefix="/api/v1/procurement", tags=["Procurement"])


def get_audit_service(db: Session = Depends(get_db)) -> AuditService:
    return AuditService(db)


def get_procurement_service(
    db: Session = Depends(get_db),
    audit_service: AuditService = Depends(get_audit_service),
    inventory_service: InventoryService = Depends(get_inventory_service)
) -> ProcurementService:
    return ProcurementService(db, audit_service, inventory_service)


def _get_user_store_ids(user: User) -> Optional[List[int]]:
    """Get store IDs accessible by user based on role"""
    if user.role.code == UserRole.HQ_ADMIN:
        return None  # Can see all
    elif user.role.code == UserRole.STORE_ADMIN:
        return [store.id for store in user.assigned_stores] if user.assigned_stores else []
    else:
        return []  # Other roles can't access


@router.get("/", response_model=ProcurementOrderListResponse)
async def list_procurement_orders(
    store_id: Optional[int] = Query(None),
    supplier_id: Optional[int] = Query(None),
    status: Optional[ProcurementStatusEnum] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
    po_number: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: ProcurementService = Depends(get_procurement_service)
):
    """
    List procurement orders with filters.
    - HQ Admin: Can see all stores
    - Store Admin: Only assigned stores
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    store_ids = _get_user_store_ids(current_user)
    
    filters = ProcurementFilters(
        store_id=store_id, supplier_id=supplier_id, status=status,
        date_from=date_from, date_to=date_to, po_number=po_number
    )
    orders, total = service.get_orders(filters, page, page_size, store_ids)
    
    items = [ProcurementOrderSummaryResponse(
        id=po.id, po_number=po.po_number,
        store_name=service.get_store_name(po.store_id),
        supplier_name=service.get_supplier_name(po.supplier_id),
        status=ProcurementStatusEnum(po.status.value),
        total_amount=po.total_amount,
        expected_delivery_date=po.expected_delivery_date,
        created_at=po.created_at
    ) for po in orders]
    
    return ProcurementOrderListResponse(
        items=items, total=total, page=page,
        page_size=page_size, total_pages=(total + page_size - 1) // page_size
    )


@router.post("/", response_model=ProcurementOrderResponse, status_code=status.HTTP_201_CREATED)
async def create_procurement_order(
    data: ProcurementOrderCreate,
    current_user: User = Depends(get_current_user),
    service: ProcurementService = Depends(get_procurement_service)
):
    """
    Create a new procurement order (Store Direct Purchase).
    Requires Store Admin or HQ Admin role.
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Store admins can only create for their stores
    if current_user.role.code == UserRole.STORE_ADMIN:
        store_ids = [store.id for store in current_user.assigned_stores] if current_user.assigned_stores else []
        if data.store_id not in store_ids:
            raise HTTPException(status_code=403, detail="Cannot create PO for this store")
    
    po = service.create_order(data, current_user.id)
    return _po_to_response(po, service)


@router.get("/{order_id}", response_model=ProcurementOrderResponse)
async def get_procurement_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    service: ProcurementService = Depends(get_procurement_service)
):
    """Get a single procurement order by ID."""
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    po = service.get_order(order_id)
    if not po:
        raise HTTPException(status_code=404, detail="Procurement order not found")
    
    # Check store access for store admins
    if current_user.role.code == UserRole.STORE_ADMIN:
        store_ids = [store.id for store in current_user.assigned_stores] if current_user.assigned_stores else []
        if po.store_id not in store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this PO")
    
    return _po_to_response(po, service)


@router.put("/{order_id}", response_model=ProcurementOrderResponse)
async def update_procurement_order(
    order_id: int,
    data: ProcurementOrderUpdate,
    current_user: User = Depends(get_current_user),
    service: ProcurementService = Depends(get_procurement_service)
):
    """Update a procurement order (only in DRAFT status)."""
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    try:
        po = service.update_order(order_id, data, current_user.id)
        if not po:
            raise HTTPException(status_code=404, detail="Procurement order not found")
        return _po_to_response(po, service)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/{order_id}/submit", response_model=ProcurementOrderResponse)
async def submit_for_approval(
    order_id: int,
    data: ProcurementSubmit = ProcurementSubmit(),
    current_user: User = Depends(get_current_user),
    service: ProcurementService = Depends(get_procurement_service)
):
    """Submit a draft PO for approval."""
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    try:
        po = service.submit_for_approval(order_id, current_user.id, data.internal_notes)
        if not po:
            raise HTTPException(status_code=404, detail="Procurement order not found")
        return _po_to_response(po, service)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/{order_id}/approve", response_model=ProcurementOrderResponse)
async def approve_or_reject(
    order_id: int,
    data: ProcurementApproval,
    current_user: User = Depends(get_current_user),
    service: ProcurementService = Depends(get_procurement_service)
):
    """Approve or reject a submitted PO. Requires HQ Admin role."""
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    try:
        po = service.approve_or_reject(order_id, current_user.id, data)
        if not po:
            raise HTTPException(status_code=404, detail="Procurement order not found")
        return _po_to_response(po, service)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/{order_id}/order", response_model=ProcurementOrderResponse)
async def mark_as_ordered(
    order_id: int,
    current_user: User = Depends(get_current_user),
    service: ProcurementService = Depends(get_procurement_service)
):
    """Mark an approved PO as ordered (sent to supplier)."""
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    try:
        po = service.mark_ordered(order_id, current_user.id)
        if not po:
            raise HTTPException(status_code=404, detail="Procurement order not found")
        return _po_to_response(po, service)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/{order_id}/receive", response_model=ProcurementOrderResponse)
async def receive_items(
    order_id: int,
    data: ProcurementReceive,
    current_user: User = Depends(get_current_user),
    service: ProcurementService = Depends(get_procurement_service)
):
    """
    Receive items against a PO and update inventory.
    Requires Store Admin or HQ Admin role.
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    try:
        po = service.receive_items(order_id, current_user.id, data)
        if not po:
            raise HTTPException(status_code=404, detail="Procurement order not found")
        return _po_to_response(po, service)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{order_id}", response_model=ProcurementOrderResponse)
async def cancel_procurement_order(
    order_id: int,
    reason: Optional[str] = Query(None),
    current_user: User = Depends(get_current_user),
    service: ProcurementService = Depends(get_procurement_service)
):
    """Cancel a procurement order."""
    if current_user.role.code not in [UserRole.HQ_ADMIN, UserRole.STORE_ADMIN]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    try:
        po = service.cancel_order(order_id, current_user.id, reason)
        if not po:
            raise HTTPException(status_code=404, detail="Procurement order not found")
        return _po_to_response(po, service)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


def _po_to_response(po, service: ProcurementService) -> ProcurementOrderResponse:
    """Convert ProcurementOrder model to response schema"""
    items = []
    if po.items:
        for item in po.items:
            # Safe casting for medicine_id (handles None and 'None' string)
            mid = item.get("medicine_id")
            medicine_id = int(mid) if mid is not None and str(mid) != 'None' else None
            
            items.append(ProcurementItemResponse(
                medicine_id=medicine_id,
                medicine_name=item["medicine_name"],
                quantity=item["quantity"],
                unit_price=item["unit_price"],
                total=item["total"]
            ))
    
    return ProcurementOrderResponse(
        id=po.id,
        po_number=po.po_number,
        store_id=po.store_id,
        store_name=service.get_store_name(po.store_id),
        supplier_id=po.supplier_id,
        supplier_name=service.get_supplier_name(po.supplier_id),
        status=ProcurementStatusEnum(po.status.value),
        order_date=po.order_date,
        expected_delivery_date=po.expected_delivery_date,
        received_date=po.received_date,
        subtotal=po.subtotal,
        tax_amount=po.tax_amount,
        discount_amount=po.discount_amount,
        total_amount=po.total_amount,
        items=items,
        items_received=po.items_received,
        approved_by=po.approved_by,
        approved_at=po.approved_at,
        rejection_reason=po.rejection_reason,
        notes=po.notes,
        internal_notes=po.internal_notes,
        created_at=po.created_at,
        updated_at=po.updated_at
    )
