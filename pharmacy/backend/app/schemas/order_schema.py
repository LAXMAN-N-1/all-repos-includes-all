from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class OrderStatusEnum(str, Enum):
    PENDING = "PENDING"
    CONFIRMED = "CONFIRMED"
    PACKED = "PACKED"
    READY_FOR_PICKUP = "READY_FOR_PICKUP"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"


class PaymentStatusEnum(str, Enum):
    PENDING = "PENDING"
    PAID = "PAID"
    FAILED = "FAILED"
    REFUNDED = "REFUNDED"


class PaymentMethodEnum(str, Enum):
    CASH = "CASH"
    CARD = "CARD"
    UPI = "UPI"
    NET_BANKING = "NET_BANKING"
    WALLET = "WALLET"
    RAZORPAY = "RAZORPAY"


# ============= Order Item Schemas =============

class OrderItemCreate(BaseModel):
    """Schema for creating order item"""
    medicine_id: int
    quantity: int = Field(..., ge=1)
    inventory_batch_id: Optional[int] = None


class OrderItemResponse(BaseModel):
    """Schema for order item response"""
    id: int
    medicine_id: int
    inventory_batch_id: Optional[int] = None
    product_name: str
    product_strength: Optional[str] = None
    batch_number: Optional[str] = None
    quantity: int
    unit_price: float
    discount_percent: float
    tax_percent: float
    total_price: float
    quantity_fulfilled: int

    class Config:
        from_attributes = True


# ============= Order Request Schemas =============

class OrderCreate(BaseModel):
    """Schema for creating a new order (customer self-service)"""
    store_id: int
    prescription_id: Optional[int] = None
    items: List[OrderItemCreate] = Field(..., min_length=1)
    customer_phone: Optional[str] = None
    customer_email: Optional[str] = None
    notes: Optional[str] = None


class OrderStatusUpdate(BaseModel):
    """Schema for updating order status (pickup workflow)"""
    status: OrderStatusEnum
    internal_notes: Optional[str] = None


class OrderPaymentUpdate(BaseModel):
    """Schema for updating payment status"""
    payment_status: PaymentStatusEnum
    payment_method: Optional[PaymentMethodEnum] = None


class OrderCancellation(BaseModel):
    """Schema for cancelling an order"""
    cancellation_reason: str = Field(..., min_length=1, max_length=500)


# ============= Order Response Schemas =============

class OrderResponse(BaseModel):
    """Schema for order response"""
    id: int
    order_number: str
    customer_id: Optional[int] = None
    store_id: int
    prescription_id: Optional[int] = None
    status: OrderStatusEnum
    payment_status: PaymentStatusEnum
    payment_method: Optional[PaymentMethodEnum] = None
    subtotal: float
    tax_amount: float
    discount_amount: float
    total_amount: float
    estimated_pickup_time: Optional[datetime] = None
    ready_at: Optional[datetime] = None
    picked_up_at: Optional[datetime] = None
    customer_phone: Optional[str] = None
    customer_email: Optional[str] = None
    notes: Optional[str] = None
    cancellation_reason: Optional[str] = None
    items: List[OrderItemResponse] = []
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class OrderSummaryResponse(BaseModel):
    """Schema for order summary (list view)"""
    id: int
    order_number: str
    customer_name: Optional[str] = None
    store_name: str
    status: OrderStatusEnum
    payment_status: PaymentStatusEnum
    total_amount: float
    items_count: int
    created_at: datetime

    class Config:
        from_attributes = True


class OrderListResponse(BaseModel):
    """Schema for paginated order list"""
    items: List[OrderSummaryResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


# ============= Filter Schemas =============

class OrderFilters(BaseModel):
    """Schema for order filters"""
    store_id: Optional[int] = None
    customer_id: Optional[int] = None
    status: Optional[OrderStatusEnum] = None
    payment_status: Optional[PaymentStatusEnum] = None
    date_from: Optional[datetime] = None
    date_to: Optional[datetime] = None
    order_number: Optional[str] = None
