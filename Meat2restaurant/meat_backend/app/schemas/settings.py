from typing import Optional, List, Dict, Any
from datetime import datetime
from pydantic import BaseModel

class ConfigUpdate(BaseModel):
    key: str
    value: str
    description: Optional[str] = None

class ConfigOut(BaseModel):
    key: str
    value: str
    description: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ShippingMethodBase(BaseModel):
    name: str
    price: float
    is_active: bool = True
    estimated_days: Optional[int] = 3

class ShippingMethodCreate(ShippingMethodBase):
    pass

class ShippingMethodUpdate(BaseModel):
    name: Optional[str] = None
    price: Optional[float] = None
    is_active: Optional[bool] = None
    estimated_days: Optional[int] = None

class ShippingMethodOut(ShippingMethodBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# --- Delivery Zones ---
class DeliveryZoneBase(BaseModel):
    name: str
    zip_codes: str
    fee: float = 0.0

class DeliveryZoneCreate(DeliveryZoneBase):
    pass

class DeliveryZoneUpdate(BaseModel):
    name: Optional[str] = None
    zip_codes: Optional[str] = None
    fee: Optional[float] = None

class DeliveryZoneOut(DeliveryZoneBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# --- Reports & Insights ---

class ReportsMetric(BaseModel):
    value: float
    change_pct: float

class ReportsInsights(BaseModel):
    meta: dict # section, days, generated_at, start_date, end_date
    kpis: Dict[str, ReportsMetric]
    sales_series: List[dict] = []
    order_status_breakdown: List[dict] = []
    top_customers: List[dict] = []
    top_products: List[dict] = []
    revenue_by_category: List[dict] = []
    revenue_by_location: List[dict] = []
    inventory_health: dict = {}
    delivery_performance: dict = {}
    financials: dict = {}
    receivables_aging: List[dict] = []
    customer_segments: dict = {}
    recent_orders: List[dict] = []
    alerts: List[dict] = []

# --- Preferences ---

class NotificationPreferences(BaseModel):
    order_updates_enabled: bool = True
    invoice_updates_enabled: bool = True
    promotions_enabled: bool = True
    system_alerts_enabled: bool = True
    delivery_updates_enabled: bool = True
    daily_digest_enabled: bool = False

class TaxPreferences(BaseModel):
    default_tax_rate: float = 0.0
    tax_inclusive_pricing: bool = False
    tax_label: str = "GST"
    tax_registration_number: str = ""

class PaymentPreferences(BaseModel):
    accept_cash: bool = True
    accept_card: bool = True
    accept_bank_transfer: bool = True
    accept_upi: bool = True
    accept_wallet: bool = True
    auto_confirm_payments: bool = False
    stripe_publishable_key: str = ""
    payment_terms_default: str = "Due on receipt"

# --- Overview & Activity ---

class SettingsOverview(BaseModel):
    store_profile_complete: bool = False
    config_entries: int = 0
    shipping_methods_total: int = 0
    shipping_methods_active: int = 0
    delivery_zones_total: int = 0
    staff_users_total: int = 0
    staff_users_active: int = 0
    api_keys_total: int = 0
    api_keys_active: int = 0

class SettingsActivityOut(BaseModel):
    id: int
    section: str
    event: str
    subject: str
    timestamp: datetime
    actor: Optional[str] = None
    metadata: dict = {}

    class Config:
        from_attributes = True

# --- API Keys ---

class ApiAccessKeyCreate(BaseModel):
    name: str
    scopes: List[str]
    expires_at: Optional[datetime] = None

class ApiAccessKeyOut(BaseModel):
    id: int
    name: str
    key_prefix: str
    scopes: List[str]
    is_active: bool
    is_expired: bool
    last_used_at: Optional[datetime] = None
    expires_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True

class ApiAccessKeyCreateResult(BaseModel):
    api_key: str
    key: ApiAccessKeyOut

# --- User Roles ---

class RoleDefinitionOut(BaseModel):
    role: str
    permissions: List[str]
