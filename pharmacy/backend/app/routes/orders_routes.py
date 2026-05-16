from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from typing import Optional
from datetime import datetime
from app.database import get_db
from app.models.user import User, UserRole
from app.models.order import OrderStatus
from app.auth.deps import get_current_user
from app.services.order_service import OrderService
from app.dependencies import get_order_service
from app.schemas.order_schema import (
    OrderCreate, OrderStatusUpdate, OrderPaymentUpdate, OrderCancellation,
    OrderResponse, OrderSummaryResponse, OrderListResponse, OrderFilters,
    OrderStatusEnum, PaymentStatusEnum, OrderItemResponse
)

router = APIRouter(prefix="/api/v1/orders", tags=["Orders"])



def order_to_response(order) -> OrderResponse:
    """Convert Order model to OrderResponse schema"""
    items = []
    for item in order.items:
        items.append(OrderItemResponse(
            id=item.id,
            medicine_id=item.medicine_id,
            inventory_batch_id=item.inventory_batch_id,
            product_name=item.product_name,
            product_strength=item.product_strength,
            batch_number=item.batch_number,
            quantity=item.quantity,
            unit_price=item.unit_price,
            discount_percent=item.discount_percent or 0,
            tax_percent=item.tax_percent or 0,
            total_price=item.total_price,
            quantity_fulfilled=item.quantity_fulfilled or 0
        ))
    
    return OrderResponse(
        id=order.id,
        order_number=order.order_number,
        customer_id=order.customer_id,
        store_id=order.store_id,
        prescription_id=order.prescription_id,
        status=OrderStatusEnum(order.status.value),
        payment_status=PaymentStatusEnum(order.payment_status.value),
        payment_method=order.payment_method.value if order.payment_method else None,
        subtotal=order.subtotal,
        tax_amount=order.tax_amount,
        discount_amount=order.discount_amount,
        total_amount=order.total_amount,
        estimated_pickup_time=order.estimated_pickup_time,
        ready_at=order.ready_at,
        picked_up_at=order.picked_up_at,
        customer_phone=order.customer_phone,
        customer_email=order.customer_email,
        notes=order.notes,
        cancellation_reason=order.cancellation_reason,
        items=items,
        created_at=order.created_at,
        updated_at=order.updated_at
    )


@router.get("/", response_model=OrderListResponse)
async def list_orders(
    store_id: Optional[int] = Query(None),
    customer_id: Optional[int] = Query(None),
    status: Optional[OrderStatusEnum] = Query(None),
    payment_status: Optional[PaymentStatusEnum] = Query(None),
    date_from: Optional[datetime] = Query(None),
    date_to: Optional[datetime] = Query(None),
    order_number: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: OrderService = Depends(get_order_service)
):
    """
    List orders with filters.
    - HQ Admin: Can see all stores
    - Store Admin/Pharmacist: Only assigned stores
    - Customer: Only own orders
    """
    filters = OrderFilters(
        store_id=store_id,
        customer_id=customer_id,
        status=status,
        payment_status=payment_status,
        date_from=date_from,
        date_to=date_to,
        order_number=order_number
    )
    
    # Apply role-based access control
    if current_user.role.code == UserRole.CUSTOMER.value:
        filters.customer_id = current_user.id
    elif current_user.role.code != UserRole.HQ_ADMIN.value:
        assigned_store_ids = [str(s.id) for s in current_user.assigned_stores]
        if store_id and str(store_id) not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
        if not store_id and assigned_store_ids:
            filters.store_id = int(assigned_store_ids[0])
    
    orders, total = service.get_orders(filters, page, page_size)
    
    items = []
    for order in orders:
        customer_name = order.customer.full_name if order.customer else None
        store_name = order.store.name if order.store else "Unknown"
        items.append(OrderSummaryResponse(
            id=order.id,
            order_number=order.order_number,
            customer_name=customer_name,
            store_name=store_name,
            status=OrderStatusEnum(order.status.value),
            payment_status=PaymentStatusEnum(order.payment_status.value),
            total_amount=order.total_amount,
            items_count=len(order.items),
            created_at=order.created_at
        ))
    
    total_pages = (total + page_size - 1) // page_size
    
    return OrderListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )


@router.post("/", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(
    data: OrderCreate,
    current_user: User = Depends(get_current_user),
    service: OrderService = Depends(get_order_service)
):
    """
    Create a new order (customer self-service).
    Validates stock availability and reserves inventory.
    """
    try:
        order = service.create_order(data, current_user.id, current_user.id)
        return order_to_response(order)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/my", response_model=OrderListResponse)
async def get_my_orders(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    service: OrderService = Depends(get_order_service)
):
    """Get current customer's orders."""
    orders, total = service.get_customer_orders(current_user.id, page, page_size)
    
    items = []
    for order in orders:
        store_name = order.store.name if order.store else "Unknown"
        items.append(OrderSummaryResponse(
            id=order.id,
            order_number=order.order_number,
            customer_name=current_user.full_name,
            store_name=store_name,
            status=OrderStatusEnum(order.status.value),
            payment_status=PaymentStatusEnum(order.payment_status.value),
            total_amount=order.total_amount,
            items_count=len(order.items),
            created_at=order.created_at
        ))
    
    total_pages = (total + page_size - 1) // page_size
    
    return OrderListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=total_pages
    )


@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    service: OrderService = Depends(get_order_service)
):
    """Get a single order by ID."""
    order = service.get_order(order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    # Verify access
    if current_user.role.code == UserRole.CUSTOMER.value:
        if order.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Access denied")
    elif current_user.role.code != UserRole.HQ_ADMIN.value:
        assigned_store_ids = [str(s.id) for s in current_user.assigned_stores]
        if str(order.store_id) not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
    
    return order_to_response(order)


@router.put("/{order_id}/status", response_model=OrderResponse)
async def update_order_status(
    order_id: int,
    data: OrderStatusUpdate,
    current_user: User = Depends(get_current_user),
    service: OrderService = Depends(get_order_service)
):
    """
    Update order status (pickup workflow transitions).
    - PENDING → CONFIRMED → PACKED → READY_FOR_PICKUP → COMPLETED
    - Any non-completed status → CANCELLED
    """
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value, UserRole.PHARMACIST.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    try:
        order = service.update_order_status(order_id, data, current_user.id)
        if not order:
            raise HTTPException(status_code=404, detail="Order not found")
        return order_to_response(order)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{order_id}/payment", response_model=OrderResponse)
async def update_payment_status(
    order_id: int,
    data: OrderPaymentUpdate,
    current_user: User = Depends(get_current_user),
    service: OrderService = Depends(get_order_service)
):
    """Update payment status for an order."""
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value, UserRole.PHARMACIST.value]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    order = service.update_payment(order_id, data, current_user.id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order_to_response(order)


@router.delete("/{order_id}", response_model=OrderResponse)
async def cancel_order(
    order_id: int,
    data: OrderCancellation,
    current_user: User = Depends(get_current_user),
    service: OrderService = Depends(get_order_service)
):
    """
    Cancel an order and release reserved stock.
    Customers can cancel their own orders if not yet completed.
    Staff can cancel any order in their stores.
    """
    order = service.get_order(order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    # Verify access
    if current_user.role.code == UserRole.CUSTOMER.value:
        if order.customer_id != current_user.id:
            raise HTTPException(status_code=403, detail="Access denied")
    elif current_user.role.code != UserRole.HQ_ADMIN.value:
        assigned_store_ids = [str(s.id) for s in current_user.assigned_stores]
        if str(order.store_id) not in assigned_store_ids:
            raise HTTPException(status_code=403, detail="Access denied to this store")
    
    try:
        cancelled_order = service.cancel_order(order_id, data, current_user.id)
        return order_to_response(cancelled_order)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
