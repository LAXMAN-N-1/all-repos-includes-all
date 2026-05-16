from pydantic import BaseModel
from typing import Optional, Dict, Any

class StripePaymentIntentCreate(BaseModel):
    order_id: Optional[int] = None
    invoice_id: Optional[int] = None
    combined_invoice_id: Optional[int] = None
    amount_override: Optional[float] = None
    currency: str = "usd"

class StripePaymentIntentResponse(BaseModel):
    client_secret: str
    payment_intent_id: str
    amount: float
    currency: str

class StripeCheckoutSessionCreate(BaseModel):
    order_id: int
    success_url: str
    cancel_url: str

class StripeCheckoutSessionResponse(BaseModel):
    url: str
