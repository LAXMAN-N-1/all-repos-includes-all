from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.schemas.order_schema import OrderCreate, OrderUpdate, OrderResponse
from app.services.order_service import OrderService
from app.dependencies import PermissionChecker, get_current_active_user
from app.models.user_m import User

router = APIRouter(prefix="/orders", tags=["Orders"])

@router.post(
    "/",
    response_model=OrderResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["order.create"]))]
)
async def create_order(
    order: OrderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = OrderService(db)
    return service.create_order(order, current_user.username)

@router.get(
    "/",
    response_model=List[OrderResponse],
    dependencies=[Depends(PermissionChecker(["order.view"]))]
)
async def get_orders(
    vendor_id: Optional[int] = None,
    event_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = OrderService(db)
    return service.get_orders(vendor_id, event_id, skip, limit)

@router.get(
    "/{order_id}",
    response_model=OrderResponse,
    dependencies=[Depends(PermissionChecker(["order.view"]))]
)
async def get_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = OrderService(db)
    return service.get_order(order_id)

@router.put(
    "/{order_id}",
    response_model=OrderResponse,
    dependencies=[Depends(PermissionChecker(["order.update"]))]
)
async def update_order(
    order_id: int,
    order_update: OrderUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = OrderService(db)
    return service.update_order(order_id, order_update, current_user.username)
