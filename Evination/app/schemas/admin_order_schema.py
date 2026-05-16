from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class AdminOrderListSchema(BaseModel):
    id: str
    eventName: str
    vendor: str
    service: str
    amount: float
    status: str
    orderDate: str
    deliveryDate: str
    progress: int

class AdminOrderDetailSchema(BaseModel):
    id: str
    eventName: str
    vendor: str
    service: str
    amount: float
    status: str
    orderDate: str
    deliveryDate: str
    progress: int
    
    # Customer Info
    customerName: str
    customerEmail: str
    customerPhone: str
    
    # Event Info
    eventDate: str
    eventLocation: str
    
    # Vendor Info
    vendorContact: str
    vendorEmail: str
    serviceDescription: str
    
    # Payment Info
    paymentStatus: str
    paidAmount: float
    
    notes: Optional[str]
