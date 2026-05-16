from typing import Optional, List
from pydantic import BaseModel

# Shared properties
class CustomerGroupBase(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = True
    discount_percentage: Optional[float] = 0.0

# Properties to receive on group creation
class CustomerGroupCreate(CustomerGroupBase):
    name: str
    customer_ids: Optional[List[int]] = None

# Properties to receive on group update
class CustomerGroupUpdate(CustomerGroupBase):
    customer_ids: Optional[List[int]] = None

# Properties shared by models stored in DB
class CustomerGroupInDBBase(CustomerGroupBase):
    id: int
    name: str

    class Config:
        from_attributes = True

# Properties to return to client
class CustomerGroup(CustomerGroupInDBBase):
    pass

# Properties stored in DB
class CustomerGroupInDB(CustomerGroupInDBBase):
    pass
