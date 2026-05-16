from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.dependencies import get_current_active_user, PermissionChecker
from app.models.user_m import User
from app.services.admin_order_service import AdminOrderService
from app.schemas.admin_order_schema import AdminOrderListSchema, AdminOrderDetailSchema

router = APIRouter(
    prefix="/admin/orders",
    tags=["Admin Orders"]
)

@router.get(
    "",
    response_model=List[AdminOrderListSchema],
    dependencies=[Depends(PermissionChecker(["admin.order.view"]))], # Assuming permission exists or generic admin access
)
async def get_all_orders(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    List all orders (Vendor Orders) with pagination.
    """
    return AdminOrderService.get_all_orders(db, skip, limit)

@router.get(
    "/{id}",
    response_model=AdminOrderDetailSchema,
    dependencies=[Depends(PermissionChecker(["admin.order.view"]))],
)
async def get_order_details(
    id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """
    Get detailed Order information by ID (e.g., 'ORD-123' or '123').
    """
    return AdminOrderService.get_order_details(db, id)
