from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app.database import get_db
from app.auth.deps import require_role, get_current_user
from app.models.user import User, UserRole
from app.models.saas_config import Module, OrganizationModule, ModuleType
from app.models.organization import Organization
from app.schemas.saas_schema import ModuleResponse, OrgModuleResponse, OrgModuleUpdate, ModuleCreate, OrgModuleBase
from app.schemas.organization_schema import OrganizationResponse, OrganizationUpdate

router = APIRouter(prefix="/api/v1/admin", tags=["SaaS Admin"])

# =============================================================================
# Module Management (Super Admin ONLY)
# =============================================================================

@router.get("/modules", response_model=List[ModuleResponse])
def list_system_modules(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """List all available system modules (Master list)"""
    return db.query(Module).all()

@router.post("/modules", response_model=ModuleResponse)
def create_system_module(
    module_in: ModuleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """Register a new module in the system"""
    module = Module(**module_in.model_dump())
    db.add(module)
    db.commit()
    db.refresh(module)
    return module

# =============================================================================
# Organization Configuration (Super Admin ONLY)
# =============================================================================

@router.get("/orgs", response_model=List[OrganizationResponse])
def list_organizations(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """List all tenant organizations"""
    return db.query(Organization).all()

@router.patch("/orgs/{org_id}/config", response_model=OrganizationResponse)
def update_organization_config(
    org_id: int,
    org_in: OrganizationUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """Update organization settings, domain, or subscription"""
    org = db.query(Organization).filter(Organization.id == org_id).first()
    if not org:
        raise HTTPException(status_code=404, detail="Organization not found")
    
    update_data = org_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(org, field, value)
    
    db.commit()
    db.refresh(org)
    return org

@router.post("/orgs/{org_id}/modules", response_model=OrgModuleResponse)
def toggle_organization_module(
    org_id: int,
    module_in: OrgModuleBase,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """Enable or configuration a module for a specific organization"""
    # 1. Verify Org Exists
    org = db.query(Organization).filter(Organization.id == org_id).first()
    if not org:
        raise HTTPException(status_code=404, detail="Organization not found")

    # 2. Check if already exists
    org_module = db.query(OrganizationModule).filter(
        OrganizationModule.organization_id == org_id,
        OrganizationModule.module_id == module_in.module_id
    ).first()

    if org_module:
        # Update existing
        org_module.is_enabled = module_in.is_enabled
        org_module.config = module_in.config
    else:
        # Create new
        org_module = OrganizationModule(
            organization_id=org_id,
            module_id=module_in.module_id,
            is_enabled=module_in.is_enabled,
            config=module_in.config
        )
        db.add(org_module)
    
    db.commit()
    db.refresh(org_module)
    db.commit()
    db.refresh(org_module)
    return org_module

# =============================================================================
# Subscription Plans Management
# =============================================================================

from app.models.subscription import Plan
from app.schemas.saas_schema import PlanResponse, PlanCreate

@router.get("/plans", response_model=List[PlanResponse])
def list_plans(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """List all subscription plans"""
    return db.query(Plan).all()

@router.post("/plans", response_model=PlanResponse)
def create_plan(
    plan_data: PlanCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """Create a new subscription plan"""
    # Exclude 'features' from init, as it maps to 'included_modules'
    data = plan_data.model_dump(exclude={'features'})
    plan = Plan(**data)
    plan.included_modules = plan_data.features 
    db.add(plan)
    db.commit()
    db.refresh(plan)
    return plan

# =============================================================================
# Organization Onboarding
# =============================================================================

from app.schemas.saas_schema import OrganizationOnboardingRequest
from app.models.role import Role
from app.auth.password import get_password_hash
from app.models.subscription import Subscription

@router.post("/orgs/onboarding", status_code=201)
def onboard_organization(
    data: OrganizationOnboardingRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """
    Full Onboarding Wizard:
    1. Create Organization
    2. Create Admin User
    3. Assign Subscription
    """
    
    # 1. Create Organization
    new_org = Organization(
        name=data.org_name,
        tax_id=data.tax_id,
        address=data.address,
        is_active=True
    )
    db.add(new_org)
    db.flush() # Get ID
    
    # 2. Get Admin Role
    admin_role = db.query(Role).filter(Role.code == "ORG_ADMIN").first()
    if not admin_role:
        raise HTTPException(status_code=500, detail="ORG_ADMIN role not found")
        
    # 3. Create Admin User
    new_user = User(
        email=data.admin_user.email,
        full_name=data.admin_user.full_name,
        password_hash=get_password_hash(data.admin_user.password),
        organization_id=new_org.id,
        role_id=admin_role.id,
        inactive=False
    )
    db.add(new_user)
    
    # 4. Create Subscription
    plan = db.query(Plan).get(data.plan_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
        
    subscription = Subscription(
        organization_id=new_org.id,
        plan_id=plan.id,
        start_date=datetime.utcnow(),
        status="ACTIVE"
    )
    db.add(subscription)
    
    db.commit()
    
    return {
        "message": "Organization onboarded successfully",
        "org_id": new_org.id,
        "admin_email": new_user.email
    }

# =============================================================================
# Dashboard & Analytics
# =============================================================================

@router.get("/stats", response_model=dict)
def get_admin_dashboard_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """Aggregate platform-wide statistics"""
    total_orgs = db.query(Organization).count()
    active_orgs = db.query(Organization).filter(Organization.is_active == True).count()
    
    # Calculate Total Monthly Recurring Revenue (MRR)
    # Sum of monthly_price of plans for all active subscriptions
    mrr_query = db.query(Subscription).join(Plan).filter(
        Subscription.status == "ACTIVE"
    ).with_entities(Plan.monthly_price)
    
    total_mrr = sum([x[0] for x in mrr_query.all()])
    
    return {
        "total_revenue": total_mrr, 
        "active_orgs": active_orgs,
        "total_orgs": total_orgs,
        "churn_rate": 0.0 # Placeholder for now
    }

# =============================================================================
# Tenant Management
# =============================================================================

@router.post("/orgs/{org_id}/suspend")
def suspend_organization(
    org_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """Suspend an organization (block access)"""
    org = db.query(Organization).filter(Organization.id == org_id).first()
    if not org:
        raise HTTPException(status_code=404, detail="Organization not found")
        
    org.is_active = False
    
    # Also suspend subscription
    if org.current_subscription:
        org.current_subscription[0].status = "SUSPENDED"
        
    db.commit()
    return {"message": f"Organization {org.name} suspended"}

@router.post("/orgs/{org_id}/reactivate")
def reactivate_organization(
    org_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role([UserRole.SAAS_SUPER_ADMIN]))
):
    """Reactivate a suspended organization"""
    org = db.query(Organization).filter(Organization.id == org_id).first()
    if not org:
        raise HTTPException(status_code=404, detail="Organization not found")
        
    org.is_active = True
    
    # Reactivate subscription
    if org.current_subscription:
        org.current_subscription[0].status = "ACTIVE"
        
    db.commit()
    return {"message": f"Organization {org.name} reactivated"}
