"""Payment routes for Razorpay integration"""
from fastapi import APIRouter, Depends, HTTPException, status, Request, Header
from sqlalchemy.orm import Session
from typing import Optional
import json
import logging

from app.database import get_db
from app.models.user import User, UserRole
from app.auth.deps import get_current_user
from app.services.payment_service import RazorpayService
from app.services.audit_service import AuditService
from app.schemas.payment_schema import (
    CreatePaymentResponse,
    VerifyPaymentRequest,
    VerifyPaymentResponse,
    PaymentStatusResponse,
    RefundRequest,
    RefundResponse,
    WebhookResponse
)

router = APIRouter(prefix="/api/v1/payments", tags=["Payments"])
logger = logging.getLogger(__name__)


def get_payment_service(db: Session = Depends(get_db)) -> RazorpayService:
    """Dependency to get payment service instance"""
    audit_service = AuditService(db)
    return RazorpayService(db, audit_service)


@router.post("/create/{order_id}", response_model=CreatePaymentResponse)
async def create_payment_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    service: RazorpayService = Depends(get_payment_service)
):
    """
    Create a Razorpay order for payment.
    
    Returns the Razorpay order details needed to initiate checkout.
    The frontend should use these details with Razorpay's checkout.js.
    """
    try:
        result = service.create_razorpay_order(order_id)
        return CreatePaymentResponse(**result)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Payment order creation failed: {e}")
        raise HTTPException(
            status_code=500,
            detail="Failed to create payment order. Please try again."
        )


@router.post("/verify", response_model=VerifyPaymentResponse)
async def verify_payment(
    data: VerifyPaymentRequest,
    current_user: User = Depends(get_current_user),
    service: RazorpayService = Depends(get_payment_service)
):
    """
    Verify Razorpay payment after successful checkout.
    
    This endpoint should be called by the frontend after Razorpay checkout
    completes successfully. It verifies the payment signature and updates
    the order status to PAID.
    """
    try:
        result = service.verify_payment(
            order_id=data.order_id,
            razorpay_order_id=data.razorpay_order_id,
            razorpay_payment_id=data.razorpay_payment_id,
            razorpay_signature=data.razorpay_signature,
            user_id=current_user.id
        )
        return VerifyPaymentResponse(**result)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Payment verification failed: {e}")
        raise HTTPException(
            status_code=500,
            detail="Payment verification failed. Please contact support."
        )


@router.get("/{order_id}/status", response_model=PaymentStatusResponse)
async def get_payment_status(
    order_id: int,
    current_user: User = Depends(get_current_user),
    service: RazorpayService = Depends(get_payment_service)
):
    """
    Get payment status for an order.
    
    Returns the current payment status, method, and Razorpay IDs.
    """
    try:
        result = service.get_payment_status(order_id)
        return PaymentStatusResponse(**result)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.post("/{order_id}/refund", response_model=RefundResponse)
async def initiate_refund(
    order_id: int,
    data: Optional[RefundRequest] = None,
    current_user: User = Depends(get_current_user),
    service: RazorpayService = Depends(get_payment_service)
):
    """
    Initiate a refund for a paid order.
    
    - HQ Admin and Store Admin can initiate refunds
    - Partial refunds are supported by specifying an amount
    """
    # Check permissions
    if current_user.role.code not in [UserRole.HQ_ADMIN.value, UserRole.STORE_ADMIN.value]:
        raise HTTPException(
            status_code=403,
            detail="Only HQ Admin and Store Admin can initiate refunds"
        )
    
    try:
        refund_data = data or RefundRequest()
        result = service.initiate_refund(
            order_id=order_id,
            amount=refund_data.amount,
            reason=refund_data.reason,
            user_id=current_user.id
        )
        return RefundResponse(**result)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Refund initiation failed: {e}")
        raise HTTPException(
            status_code=500,
            detail="Failed to initiate refund. Please try again."
        )


@router.post("/webhook", response_model=WebhookResponse)
async def handle_webhook(
    request: Request,
    x_razorpay_signature: Optional[str] = Header(None, alias="X-Razorpay-Signature"),
    db: Session = Depends(get_db)
):
    """
    Handle Razorpay webhooks.
    
    This endpoint receives webhook events from Razorpay for:
    - payment.captured: When payment is successfully captured
    - payment.failed: When payment fails
    - refund.created: When a refund is initiated
    
    Configure this URL in your Razorpay dashboard under Webhooks.
    """
    try:
        body = await request.body()
        payload = json.loads(body)
        
        audit_service = AuditService(db)
        service = RazorpayService(db, audit_service)
        
        result = service.process_webhook(payload, x_razorpay_signature or "")
        return WebhookResponse(**result)
    except ValueError as e:
        logger.error(f"Webhook processing failed: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Webhook error: {e}")
        # Return 200 to prevent Razorpay from retrying
        return WebhookResponse(status="error", message=str(e))
