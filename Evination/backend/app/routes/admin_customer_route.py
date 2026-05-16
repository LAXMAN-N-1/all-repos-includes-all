from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.dependencies import get_current_active_user, PermissionChecker
from app.models.user_m import User
from app.services.admin_customer_service import AdminCustomerService
from app.schemas.admin_customer_schema import CustomerStatResponse, CustomerDetailResponse

router = APIRouter(prefix="/admin/customers", tags=["Admin Customer Management"])

@router.get(
    "/", 
    response_model=List[CustomerStatResponse],
    dependencies=[Depends(PermissionChecker(["customer.view"]))]
)
async def get_customers(
    skip: int = 0,
    limit: int = 100,
    search: str = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = AdminCustomerService(db)
    return service.get_customers(skip, limit, search)

@router.get(
    "/{customer_id}", 
    response_model=CustomerDetailResponse,
    dependencies=[Depends(PermissionChecker(["customer.view"]))]
)
async def get_customer_details(
    customer_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = AdminCustomerService(db)
    return service.get_customer_details(customer_id)
