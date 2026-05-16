from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

# Supplier Schemas
class SupplierBase(BaseModel):
    name: str
    contact_name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    status: str = "Active"

class SupplierCreate(SupplierBase):
    pass

class SupplierUpdate(BaseModel):
    name: Optional[str] = None
    contact_name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    status: Optional[str] = None

class SupplierResponse(SupplierBase):
    id: int
    rating: float
    created_at: datetime

    class Config:
        from_attributes = True

# Purchase Order Item Schemas
class PurchaseOrderItemBase(BaseModel):
    product_id: int
    variant_id: Optional[int] = None
    quantity: int
    unit_price: float

class PurchaseOrderItemCreate(PurchaseOrderItemBase):
    pass

class PurchaseOrderItemResponse(PurchaseOrderItemBase):
    id: int
    received_quantity: int
    product_name: Optional[str] = None

    class Config:
        from_attributes = True

# Purchase Order Schemas
class PurchaseOrderBase(BaseModel):
    supplier_id: int
    po_number: str
    expected_delivery: Optional[datetime] = None
    notes: Optional[str] = None

class PurchaseOrderCreate(PurchaseOrderBase):
    items: List[PurchaseOrderItemCreate]

class PurchaseOrderResponse(PurchaseOrderBase):
    id: int
    status: str
    order_date: datetime
    total_amount: float
    items: List[PurchaseOrderItemResponse]
    supplier_name: Optional[str] = None

    class Config:
        from_attributes = True

class PurchaseOrderReceive(BaseModel):
    received_items: List[dict] # List of {"item_id": int, "quantity": int}
