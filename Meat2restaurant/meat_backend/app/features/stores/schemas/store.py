"""
Store Location Master — Pydantic Schemas
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, date, time


# ─── Timing ────────────────────────────────────────────────────────────
class StoreTimingCreate(BaseModel):
    day_of_week: int = Field(..., ge=0, le=6)
    is_open: bool = True
    open_time: Optional[str] = None  # "HH:MM"
    close_time: Optional[str] = None

class StoreTimingOut(BaseModel):
    id: int
    day_of_week: int
    is_open: bool
    open_time: Optional[str] = None
    close_time: Optional[str] = None

    class Config:
        orm_mode = True
        json_encoders = {time: lambda v: v.strftime("%H:%M") if v else None}

    @classmethod
    def from_orm(cls, obj):
        return cls(
            id=obj.id,
            day_of_week=obj.day_of_week,
            is_open=obj.is_open,
            open_time=obj.open_time.strftime("%H:%M") if obj.open_time else None,
            close_time=obj.close_time.strftime("%H:%M") if obj.close_time else None,
        )


# ─── Special Hours ─────────────────────────────────────────────────────
class StoreSpecialHoursCreate(BaseModel):
    date: str  # "YYYY-MM-DD"
    label: Optional[str] = None
    is_closed: bool = True
    open_time: Optional[str] = None
    close_time: Optional[str] = None

class StoreSpecialHoursOut(BaseModel):
    id: int
    date: str
    label: Optional[str] = None
    is_closed: bool
    open_time: Optional[str] = None
    close_time: Optional[str] = None

    class Config:
        orm_mode = True


# ─── Services ──────────────────────────────────────────────────────────
class StoreServiceCreate(BaseModel):
    web_orders_enabled: bool = False
    app_orders_enabled: bool = False
    whatsapp_orders_enabled: bool = False
    walkin_enabled: bool = False
    home_delivery_enabled: bool = False
    pickup_enabled: bool = False
    bulk_orders_enabled: bool = False
    cod_enabled: bool = False
    card_on_delivery_enabled: bool = False
    online_payment_enabled: bool = False

class StoreServiceOut(StoreServiceCreate):
    id: int
    class Config:
        orm_mode = True


# ─── Delivery Zone ─────────────────────────────────────────────────────
class StoreDeliveryZoneCreate(BaseModel):
    zone_name: str
    polygon_geojson: Optional[str] = None
    delivery_fee: float = 0.0
    min_order: float = 0.0
    estimated_time_minutes: int = 45
    priority: int = 0

class StoreDeliveryZoneUpdate(BaseModel):
    zone_name: Optional[str] = None
    polygon_geojson: Optional[str] = None
    delivery_fee: Optional[float] = None
    min_order: Optional[float] = None
    estimated_time_minutes: Optional[int] = None
    priority: Optional[int] = None

class StoreDeliveryZoneOut(BaseModel):
    id: int
    store_id: int
    zone_name: str
    polygon_geojson: Optional[str] = None
    delivery_fee: float
    min_order: float
    estimated_time_minutes: int
    priority: int
    class Config:
        orm_mode = True


# ─── WhatsApp Config ───────────────────────────────────────────────────
class StoreWhatsappConfigCreate(BaseModel):
    whatsapp_phone: Optional[str] = None
    business_account_id: Optional[str] = None
    greeting_template: Optional[str] = None
    default_language: str = "en"
    keyword_triggers: Optional[str] = None  # JSON array string

class StoreWhatsappConfigOut(BaseModel):
    id: int
    whatsapp_phone: Optional[str] = None
    business_account_id: Optional[str] = None
    greeting_template: Optional[str] = None
    default_language: str
    keyword_triggers: Optional[str] = None
    class Config:
        orm_mode = True


# ─── Media ─────────────────────────────────────────────────────────────
class StoreMediaCreate(BaseModel):
    media_url: str
    media_type: str = "image"
    display_order: int = 0
    is_cover: bool = False

class StoreMediaOut(BaseModel):
    id: int
    media_url: str
    media_type: str
    display_order: int
    is_cover: bool
    class Config:
        orm_mode = True


# ─── Staff ─────────────────────────────────────────────────────────────
class StoreStaffCreate(BaseModel):
    name: str
    role: Optional[str] = None
    phone: Optional[str] = None

class StoreStaffOut(BaseModel):
    id: int
    name: str
    role: Optional[str] = None
    phone: Optional[str] = None
    class Config:
        orm_mode = True


# ─── Store (main) ──────────────────────────────────────────────────────
class StoreCreate(BaseModel):
    name: str
    store_code: Optional[str] = None  # auto-generated if missing
    store_type: str = "outlet"
    address_line1: Optional[str] = None
    address_line2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    country: str = "US"
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    google_place_id: Optional[str] = None
    display_order: int = 0
    status: str = "active"
    cover_image_url: Optional[str] = None

    # nested children
    timings: Optional[List[StoreTimingCreate]] = None
    special_hours: Optional[List[StoreSpecialHoursCreate]] = None
    services: Optional[StoreServiceCreate] = None
    delivery_zones: Optional[List[StoreDeliveryZoneCreate]] = None
    whatsapp_config: Optional[StoreWhatsappConfigCreate] = None
    media: Optional[List[StoreMediaCreate]] = None
    staff: Optional[List[StoreStaffCreate]] = None

class StoreUpdate(BaseModel):
    name: Optional[str] = None
    store_type: Optional[str] = None
    address_line1: Optional[str] = None
    address_line2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    country: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    google_place_id: Optional[str] = None
    display_order: Optional[int] = None
    status: Optional[str] = None
    cover_image_url: Optional[str] = None

    timings: Optional[List[StoreTimingCreate]] = None
    special_hours: Optional[List[StoreSpecialHoursCreate]] = None
    services: Optional[StoreServiceCreate] = None
    whatsapp_config: Optional[StoreWhatsappConfigCreate] = None
    media: Optional[List[StoreMediaCreate]] = None
    staff: Optional[List[StoreStaffCreate]] = None


class StoreSummaryOut(BaseModel):
    """Lightweight schema for list view cards."""
    id: int
    name: str
    store_code: str
    store_type: str
    city: Optional[str] = None
    status: str
    display_order: int
    cover_image_url: Optional[str] = None
    created_at: Optional[datetime] = None

    # Inline service flags for filter chips (optional)
    whatsapp_orders_enabled: bool = False
    web_orders_enabled: bool = False
    app_orders_enabled: bool = False

    class Config:
        orm_mode = True


class StoreOut(BaseModel):
    """Full store detail with all nested entities."""
    id: int
    name: str
    store_code: str
    slug: Optional[str] = None
    store_type: str
    address_line1: Optional[str] = None
    address_line2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    country: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    google_place_id: Optional[str] = None
    display_order: int
    status: str
    cover_image_url: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    timings: List[StoreTimingOut] = []
    special_hours: List[StoreSpecialHoursOut] = []
    services: Optional[StoreServiceOut] = None
    delivery_zones: List[StoreDeliveryZoneOut] = []
    whatsapp_config: Optional[StoreWhatsappConfigOut] = None
    media: List[StoreMediaOut] = []
    staff: List[StoreStaffOut] = []

    class Config:
        orm_mode = True


class PaginatedStoresResponse(BaseModel):
    total: int
    page: int
    limit: int
    items: List[StoreSummaryOut]


class StoreStatusUpdate(BaseModel):
    status: str  # active, inactive, coming_soon


class WhatsappBranchOut(BaseModel):
    store_id: int
    display_name: str
    whatsapp_phone: Optional[str] = None
    greeting_template: Optional[str] = None
