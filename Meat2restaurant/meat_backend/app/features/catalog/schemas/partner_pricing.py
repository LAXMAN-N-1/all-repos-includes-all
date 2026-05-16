from typing import Optional
from pydantic import BaseModel
from datetime import datetime

class PartnerPriceBase(BaseModel):
    partner_id: int
    product_id: int
    custom_price: float

class PartnerPriceCreate(PartnerPriceBase):
    pass

class PartnerPriceUpdate(BaseModel):
    custom_price: Optional[float] = None

class PartnerPrice(PartnerPriceBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
