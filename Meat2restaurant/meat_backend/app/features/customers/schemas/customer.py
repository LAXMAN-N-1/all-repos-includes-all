import datetime
from typing import Optional, List
from pydantic import BaseModel, EmailStr
from app.features.customers.models.customer import CustomerType, BillingCycle

# --- Membership Plan Schemas (Defined early for circular refs) ---
class MembershipPlanBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: int
    duration_days: int = 30
    benefits: Optional[str] = ""
    is_active: bool = True

class MembershipPlanCreate(MembershipPlanBase):
    pass

class MembershipPlanUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[int] = None
    duration_days: Optional[int] = None
    is_active: Optional[bool] = None

class MembershipPlan(MembershipPlanBase):
    id: int
    created_at: datetime.datetime
    updated_at: datetime.datetime

    class Config:
        from_attributes = True

# --- Membership Schemas ---
class MembershipBase(BaseModel):
    plan_id: int
    start_date: Optional[datetime.date] = None
    end_date: Optional[datetime.date] = None
    is_active: bool = True

class MembershipCreate(MembershipBase):
    pass # customer_id is usually in the URL

class MembershipUpdate(BaseModel):
    plan_id: Optional[int] = None
    end_date: Optional[datetime.date] = None
    is_active: Optional[bool] = None

class Membership(MembershipBase):
    id: int
    customer_id: int
    plan: Optional[MembershipPlan] = None
    created_at: datetime.datetime
    updated_at: datetime.datetime

    class Config:
        from_attributes = True

# --- Customer Schemas ---

# Fields available to everyone (read-only usually)
class CustomerBase(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    zip_code: Optional[str] = None
    customer_type: Optional[CustomerType] = CustomerType.DIRECT
    billing_cycle: Optional[BillingCycle] = BillingCycle.IMMEDIATE
    business_name: Optional[str] = None
    owner_name: Optional[str] = None
    tax_id: Optional[str] = None
    business_description: Optional[str] = None
    stripe_customer_id: Optional[str] = None
    current_balance: Optional[float] = 0.0
    wallet_balance: Optional[float] = 0.0
    wallet_enabled: Optional[bool] = True
    cycle_start_day: Optional[int] = 1
    cycle_cutoff_day: Optional[int] = 30
    payment_due_day: Optional[int] = 5
    group_id: Optional[int] = None

# Public Registration - Strictly limited
class CustomerRegister(BaseModel):
    name: str
    email: EmailStr
    password: str
    phone: Optional[str] = None
    address: Optional[str] = None
    zip_code: Optional[str] = None
    business_name: Optional[str] = None
    owner_name: Optional[str] = None
    tax_id: Optional[str] = None
    business_description: Optional[str] = None
    billing_cycle: Optional[BillingCycle] = BillingCycle.WEEKLY
    business_type: Optional[str] = None
    years_in_business: Optional[str] = None
    customer_type: Optional[CustomerType] = CustomerType.DIRECT

# Public Application (No Password - Admin generates it)
class CustomerApply(BaseModel):
    name: str
    email: EmailStr
    password: str
    phone: str
    address: str
    zip_code: Optional[str] = None
    business_name: str
    owner_name: Optional[str] = None
    tax_id: str
    business_description: Optional[str] = None
    years_in_business: Optional[str] = None
    business_type: Optional[str] = None
    billing_cycle: Optional[BillingCycle] = BillingCycle.WEEKLY

class CustomerApprove(BaseModel):
    credit_limit: float = 0.0
    group_id: Optional[int] = None
    customer_type: Optional[CustomerType] = None
    billing_cycle: Optional[BillingCycle] = None

# Partner Update - Limited (No credit_limit, wallet_balance, status, etc.)
class CustomerUpdatePartner(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    zip_code: Optional[str] = None
    business_name: Optional[str] = None
    owner_name: Optional[str] = None
    tax_id: Optional[str] = None
    business_description: Optional[str] = None

# Staff/Admin Create - Full control
class CustomerCreateAdmin(CustomerBase):
    name: str
    email: EmailStr
    password: str
    credit_limit: Optional[float] = 0.0
    is_verified: Optional[bool] = False
    status: Optional[str] = "draft"

# Staff/Admin Update - Full control
class CustomerUpdateAdmin(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    zip_code: Optional[str] = None
    customer_type: Optional[CustomerType] = None
    billing_cycle: Optional[BillingCycle] = None
    business_name: Optional[str] = None
    owner_name: Optional[str] = None
    tax_id: Optional[str] = None
    business_description: Optional[str] = None
    credit_limit: Optional[float] = None
    current_balance: Optional[float] = None
    is_verified: Optional[bool] = None
    status: Optional[str] = None
    is_active: Optional[bool] = None
    stripe_customer_id: Optional[str] = None
    wallet_balance: Optional[float] = None
    wallet_enabled: Optional[bool] = None
    cycle_start_day: Optional[int] = None
    cycle_cutoff_day: Optional[int] = None
    payment_due_day: Optional[int] = None

# Base for DB internal use
class CustomerInDBBase(CustomerBase):
    id: Optional[int] = None
    credit_limit: Optional[float] = 0.0
    current_balance: Optional[float] = 0.0
    wallet_balance: Optional[float] = 0.0
    is_verified: Optional[bool] = False
    status: Optional[str] = "draft"
    is_active: Optional[bool] = True
    membership: Optional[Membership] = None
    created_at: Optional[datetime.datetime] = None
    updated_at: Optional[datetime.datetime] = None

    class Config:
        from_attributes = True

# Response model
class Customer(CustomerInDBBase):
    pass

# Compatibility aliases for existing code
CustomerCreate = CustomerCreateAdmin
CustomerUpdate = CustomerUpdateAdmin

# --- Password Reset Flow ---
class PasswordResetRequest(BaseModel):
    email: EmailStr

class PasswordResetConfirm(BaseModel):
    email: EmailStr
    otp: str
    new_password: str
    confirm_password: str

    from pydantic import field_validator

    @field_validator("new_password")
    def password_min_length(cls, v):
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters long")
        return v

    @field_validator("confirm_password")
    def passwords_match(cls, v, info):
        if "new_password" in info.data and v != info.data["new_password"]:
            raise ValueError("Passwords do not match")
        return v

# --- Bulk Import Schemas ---
class CustomerBulkImport(BaseModel):
    name: str
    email: str 
    phone: Optional[str] = None
    business_name: Optional[str] = None
    zip_code: Optional[str] = None
    customer_type: Optional[str] = "b2b"

class CustomerBulkImportResult(BaseModel):
    successful: int
    failed: int
    errors: List[str]

