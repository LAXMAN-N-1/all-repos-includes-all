from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime
from enum import Enum


# ============= Request Schemas =============

class InventoryBatchCreate(BaseModel):
    """Schema for creating a new inventory batch"""
    store_id: int
    medicine_id: Optional[int] = None
    product_name: str = Field(..., min_length=1, max_length=255)
    batch_number: str = Field(..., min_length=1, max_length=100)
    expiry_date: date
    manufacture_date: Optional[date] = None
    quantity: int = Field(..., ge=0)
    cost_price: float = Field(..., ge=0)
    selling_price: float = Field(..., ge=0)
    mrp: Optional[float] = Field(None, ge=0)
    reorder_level: int = Field(default=10, ge=0)
    supplier_invoice: Optional[str] = None
    supplier_batch: Optional[str] = None
    rack_location: Optional[str] = None


class InventoryBatchUpdate(BaseModel):
    """Schema for updating an inventory batch"""
    quantity: Optional[int] = Field(None, ge=0)
    selling_price: Optional[float] = Field(None, ge=0)
    mrp: Optional[float] = Field(None, ge=0)
    reorder_level: Optional[int] = Field(None, ge=0)
    rack_location: Optional[str] = None


class StockAdjustment(BaseModel):
    """Schema for stock adjustment"""
    batch_id: int
    adjustment_quantity: int  # Positive for increase, negative for decrease
    reason: str = Field(..., min_length=1, max_length=500)


# ============= Response Schemas =============

class InventoryBatchResponse(BaseModel):
    """Schema for inventory batch response"""
    id: int
    store_id: int
    medicine_id: Optional[int] = None
    product_name: str
    batch_number: str
    expiry_date: date
    manufacture_date: Optional[date] = None
    quantity: int
    quantity_reserved: int
    quantity_available: int  # Computed: quantity - quantity_reserved
    reorder_level: int
    cost_price: float
    selling_price: float
    mrp: Optional[float] = None
    supplier_invoice: Optional[str] = None
    supplier_batch: Optional[str] = None
    rack_location: Optional[str] = None
    is_low_stock: bool  # Computed: quantity <= reorder_level
    days_until_expiry: int  # Computed
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class InventoryAlertItem(BaseModel):
    """Schema for individual inventory alert"""
    batch_id: int
    store_id: int
    product_name: str
    batch_number: str
    alert_type: str  # "LOW_STOCK" or "EXPIRING_SOON" or "EXPIRED"
    current_quantity: int
    reorder_level: int
    expiry_date: date
    days_until_expiry: int


class InventoryAlertResponse(BaseModel):
    """Schema for inventory alerts response"""
    low_stock_items: List[InventoryAlertItem]
    expiring_soon_items: List[InventoryAlertItem]
    expired_items: List[InventoryAlertItem]
    total_alerts: int


class InventoryListResponse(BaseModel):
    """Schema for paginated inventory list"""
    items: List[InventoryBatchResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


# ============= Filter Schemas =============

class InventoryFilters(BaseModel):
    """Schema for inventory filters"""
    store_id: Optional[int] = None
    medicine_id: Optional[int] = None
    product_name: Optional[str] = None
    batch_number: Optional[str] = None
    low_stock_only: bool = False
    expiring_within_days: Optional[int] = None
    expired_only: bool = False
