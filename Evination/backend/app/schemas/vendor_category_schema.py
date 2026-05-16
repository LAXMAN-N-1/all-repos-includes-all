from pydantic import BaseModel
from typing import Optional, List

class VendorCategoryBase(BaseModel):
    vendor_id: int
    category_id: int

class VendorCategoryCreate(VendorCategoryBase):
    pass

# We might not need Update for a link table, usually just Create/Delete. 
# But let's keep it simple.

class VendorCategoryResponse(VendorCategoryBase):
    id: int # If BaseModel has ID
    vendor_name: Optional[str] = None
    category_name: Optional[str] = None

    class Config:
        from_attributes = True
