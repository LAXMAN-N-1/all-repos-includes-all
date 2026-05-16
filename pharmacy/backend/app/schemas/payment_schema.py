"""Payment schemas for Razorpay integration"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum


class RazorpayOrderStatus(str, Enum):
    """Razorpay order status"""
    CREATED = "created"
    ATTEMPTED = "attempted"
    PAID = "paid"


# ============= Request Schemas =============

class CreatePaymentRequest(BaseModel):
    """Request to create a Razorpay order for payment"""
    order_id: int = Field(..., description="Internal order ID to pay for")


class VerifyPaymentRequest(BaseModel):
    """Request to verify Razorpay payment after completion"""
    order_id: int = Field(..., description="Internal order ID")
    razorpay_order_id: str = Field(..., description="Razorpay order ID")
    razorpay_payment_id: str = Field(..., description="Razorpay payment ID")
    razorpay_signature: str = Field(..., description="Razorpay signature for verification")


class RefundRequest(BaseModel):
    """Request to initiate a refund"""
    reason: Optional[str] = Field(None, max_length=500, description="Reason for refund")
    amount: Optional[float] = Field(None, gt=0, description="Partial refund amount (optional, defaults to full)")


# ============= Response Schemas =============

class CreatePaymentResponse(BaseModel):
    """Response after creating Razorpay order"""
    razorpay_order_id: str = Field(..., description="Razorpay order ID")
    razorpay_key: str = Field(..., description="Razorpay public key for checkout")
    amount: int = Field(..., description="Amount in paise (smallest currency unit)")
    currency: str = Field(default="INR", description="Currency code")
    order_id: int = Field(..., description="Internal order ID")
    order_number: str = Field(..., description="Order number for display")
    customer_name: Optional[str] = None
    customer_email: Optional[str] = None
    customer_phone: Optional[str] = None
    description: str = Field(..., description="Payment description")


class PaymentStatusResponse(BaseModel):
    """Response for payment status check"""
    order_id: int
    order_number: str
    payment_status: str
    payment_method: Optional[str] = None
    razorpay_order_id: Optional[str] = None
    razorpay_payment_id: Optional[str] = None
    total_amount: float
    is_paid: bool


class VerifyPaymentResponse(BaseModel):
    """Response after payment verification"""
    success: bool
    message: str
    order_id: int
    order_number: str
    payment_status: str
    razorpay_payment_id: Optional[str] = None


class RefundResponse(BaseModel):
    """Response after refund initiation"""
    success: bool
    message: str
    refund_id: Optional[str] = None
    order_id: int
    refund_amount: float
    refund_status: str


class WebhookResponse(BaseModel):
    """Response for webhook processing"""
    status: str = "ok"
    message: str = "Webhook processed successfully"
