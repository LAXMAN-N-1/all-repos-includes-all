from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.organization_schema import OrganizationCreate, OrganizationUpdate, OrganizationResponse
from app.models.user_m import User
from app.dependencies import get_current_active_user, PermissionChecker
from app.services.organization_service import OrganizationService

router = APIRouter(prefix="/organizations", tags=["Organizations"])

@router.post(
    "/", 
    response_model=OrganizationResponse, 
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["organization.create"]))] # Assumed PERMISSION
)
async def create_organization(
    org: OrganizationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    org_service = OrganizationService(db)
    return org_service.create_organization(org, current_user.username)

@router.get(
    "/", 
    response_model=List[OrganizationResponse],
    dependencies=[Depends(PermissionChecker(["organization.view"]))]
)
async def get_organizations(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    org_service = OrganizationService(db)
    return org_service.get_organizations(skip, limit)

@router.get(
    "/{org_id}", 
    response_model=OrganizationResponse,
    dependencies=[Depends(PermissionChecker(["organization.view"]))]
)
async def get_organization(
    org_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    org_service = OrganizationService(db)
    return org_service.get_organization(org_id)

@router.put(
    "/{org_id}", 
    response_model=OrganizationResponse,
    dependencies=[Depends(PermissionChecker(["organization.update"]))]
)
async def update_organization(
    org_id: int,
    org_update: OrganizationUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    org_service = OrganizationService(db)
    return org_service.update_organization(org_id, org_update, current_user.username)

@router.delete(
    "/{org_id}",
    dependencies=[Depends(PermissionChecker(["organization.delete"]))] # Hypothetical, normally we don't delete orgs often
)
async def delete_organization(
    org_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    org_service = OrganizationService(db)
    org_service.delete_organization(org_id, current_user.username)
    return {"message": "Organization deleted successfully"}