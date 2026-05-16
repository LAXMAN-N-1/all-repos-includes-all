from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.schemas.payment_schema import PaymentCreate, PaymentResponse
from app.services.payment_service import PaymentService
from app.dependencies import PermissionChecker, get_current_active_user
from app.models.user_m import User

router = APIRouter(prefix="/payments", tags=["Payments"])

@router.post(
    "/",
    response_model=PaymentResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["payment.create"]))]
)
async def create_payment(
    payment: PaymentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = PaymentService(db)
    return service.create_payment(payment, current_user.username)

@router.get(
    "/",
    response_model=List[PaymentResponse],
    dependencies=[Depends(PermissionChecker(["payment.view"]))]
)
async def get_payments(
    vendor_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = PaymentService(db)
    return service.get_payments(vendor_id, skip, limit)

@router.get(
    "/{payment_id}",
    response_model=PaymentResponse,
    dependencies=[Depends(PermissionChecker(["payment.view"]))]
)
async def get_payment(
    payment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = PaymentService(db)
    return service.get_payment(payment_id)
