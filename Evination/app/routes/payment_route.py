from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.services.payment_service import PaymentService
from app.models.user_m import User
from app.dependencies import get_current_active_user

from app.schemas.payment_schema import (
    PaymentInitiate,
    PaymentResponse,
    PaymentVerify
)

router = APIRouter(prefix="/payments", tags=["Payments"])

@router.post(
    "/initiate",
    response_model=PaymentResponse,
)
async def initiate_payment(
    payment_data: PaymentInitiate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Initiate a payment for an order.
    """
    return PaymentService.initiate_payment(db, payment_data, current_user.id)

@router.post(
    "/verify",
    response_model=PaymentResponse,
)
async def verify_payment(
    verify_data: PaymentVerify,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """
    Verify a payment after gateway callback.
    """
    return PaymentService.verify_payment(
        db, 
        verify_data.razorpay_payment_id, 
        verify_data.razorpay_order_id, 
        verify_data.razorpay_signature
    )
