from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel

# --- Categories ---
class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    parent_id: Optional[int] = None
    is_active: bool = True
    image_url: Optional[str] = None

class CategoryCreate(CategoryBase):
    pass

class CategoryUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    parent_id: Optional[int] = None
    is_active: Optional[bool] = None
    image_url: Optional[str] = None

class CategoryOut(CategoryBase):
    id: int
    created_at: datetime
    updated_at: datetime
    class Config:
        from_attributes = True

# --- Attributes ---
class AttributeValueBase(BaseModel):
    value: str

class AttributeValueCreate(AttributeValueBase):
    attribute_id: int

class AttributeValueUpdate(BaseModel):
    value: Optional[str] = None

class AttributeValueOut(AttributeValueBase):
    id: int
    attribute_id: int
    created_at: datetime
    updated_at: datetime
    class Config:
        from_attributes = True

class AttributeBase(BaseModel):
    name: str
    is_active: bool = True

class AttributeCreate(AttributeBase):
    pass

class AttributeUpdate(BaseModel):
    name: Optional[str] = None
    is_active: Optional[bool] = None

class AttributeOut(AttributeBase):
    id: int
    values: List[AttributeValueOut] = []
    created_at: datetime
    updated_at: datetime
    class Config:
        from_attributes = True
