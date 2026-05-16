from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.branch_schema import BranchCreate, BranchUpdate, BranchResponse
from app.models.user_m import User
from app.dependencies import get_current_active_user, PermissionChecker
from app.services.organization_service import OrganizationService

router = APIRouter(prefix="/branches", tags=["Branches"])

@router.post(
    "/",
    response_model=BranchResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["branch.create"]))]
)
async def create_branch(
    branch: BranchCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    org_service = OrganizationService(db)
    return org_service.create_branch(branch, current_user.username)

@router.get(
    "/",
    response_model=List[BranchResponse],
    dependencies=[Depends(PermissionChecker(["branch.view"]))]
)
async def get_branches(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    org_service = OrganizationService(db)
    return org_service.get_branches(current_user.organization_id, skip, limit)

@router.get(
    "/{branch_id}",
    response_model=BranchResponse,
    dependencies=[Depends(PermissionChecker(["branch.view"]))]
)
async def get_branch(
    branch_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    org_service = OrganizationService(db)
    return org_service.get_branch(branch_id, current_user.organization_id)

@router.put(
    "/{branch_id}",
    response_model=BranchResponse,
    dependencies=[Depends(PermissionChecker(["branch.update"]))]
)
async def update_branch(
    branch_id: int,
    branch_update: BranchUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    org_service = OrganizationService(db)
    return org_service.update_branch(branch_id, branch_update, current_user.organization_id, current_user.username)

@router.delete(
    "/{branch_id}",
    dependencies=[Depends(PermissionChecker(["branch.delete"]))]
)
async def delete_branch(
    branch_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    org_service = OrganizationService(db)
    org_service.delete_branch(branch_id, current_user.organization_id, current_user.username)
    return {"message": "Branch deleted successfully"}