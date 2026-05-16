from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from app.models.saas_config import ModuleType

# Module Schemas
class ModuleBase(BaseModel):
    name: str
    code: ModuleType
    description: Optional[str] = None
    is_beta: bool = False

class ModuleCreate(ModuleBase):
    pass

class ModuleResponse(ModuleBase):
    id: int
    
    class Config:
        from_attributes = True

# Organization Module Schemas (Feature Flags)
class OrgModuleBase(BaseModel):
    module_id: int
    is_enabled: bool = True
    config: Dict[str, Any] = {}

class OrgModuleUpdate(BaseModel):
    is_enabled: Optional[bool] = None
    config: Optional[Dict[str, Any]] = None

class OrgModuleResponse(OrgModuleBase):
    id: int
    organization_id: int
    module: Optional[ModuleResponse] = None

    class Config:
        from_attributes = True

# Plan Schemas
from app.models.subscription import PlanType
class PlanBase(BaseModel):
    name: str
    code: PlanType
    monthly_price: float
    yearly_price: float
    max_stores: int
    max_users: int
    storage_limit_gb: int
    description: Optional[str] = None
    features: List[str] = [] # JSON list of features strings for UI

class PlanCreate(PlanBase):
    pass

class PlanResponse(PlanBase):
    id: int
    is_public: bool
    
    class Config:
        from_attributes = True

# Onboarding Schema
class AdminUserCreate(BaseModel):
    full_name: str
    email: str
    password: str

class OrganizationOnboardingRequest(BaseModel):
    org_name: str
    tax_id: Optional[str] = None
    address: Optional[str] = None
    plan_id: int
    admin_user: AdminUserCreate
