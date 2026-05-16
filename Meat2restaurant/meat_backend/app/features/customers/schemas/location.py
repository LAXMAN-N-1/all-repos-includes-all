from typing import Optional
from pydantic import BaseModel
from datetime import datetime

# Shared properties
class LocationBase(BaseModel):
    name: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    phone: Optional[str] = None
    is_default: bool = False
    is_active: bool = True

# Properties to receive on item creation
class LocationCreate(LocationBase):
    name: str
    address: str
    city: str
    state: str
    zip_code: str

# Properties to receive on item update
class LocationUpdate(LocationBase):
    pass

# Properties shared by models stored in DB
class LocationInDBBase(LocationBase):
    id: int
    customer_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Properties to return to client
class Location(LocationInDBBase):
    pass
