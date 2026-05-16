from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class PaymentInitiate(BaseModel):
    order_id: int
    amount: float
    payment_method: str
    currency: str = "INR"

class PaymentVerify(BaseModel):
    razorpay_payment_id: str
    razorpay_order_id: str
    razorpay_signature: str

class PaymentResponse(BaseModel):
    transaction_id: str
    status: str
    amount: float
    currency: str = "INR"
    message: str
