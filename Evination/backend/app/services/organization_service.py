from sqlalchemy.orm import Session
from typing import List, Optional
from fastapi import HTTPException, status
from app.models.organization_m import Organization
from app.models.branch_m import Branch
from app.schemas.organization_schema import OrganizationCreate, OrganizationUpdate
from app.schemas.branch_schema import BranchCreate, BranchUpdate

class OrganizationService:
    def __init__(self, db: Session):
        self.db = db

    # Organization Methods
    def create_organization(self, org: OrganizationCreate, created_by: str) -> Organization:
        db_org = self.db.query(Organization).filter(Organization.code == org.code).first()
        if db_org:
            raise HTTPException(status_code=400, detail="Organization code already exists")
        
        new_org = Organization(**org.dict(), created_by=created_by)
        self.db.add(new_org)
        self.db.commit()
        self.db.refresh(new_org)
        return new_org

    def get_organizations(self, skip: int = 0, limit: int = 100) -> List[Organization]:
        return self.db.query(Organization).filter(Organization.inactive == False).offset(skip).limit(limit).all()

    def get_organization(self, org_id: int) -> Organization:
        org = self.db.query(Organization).filter(Organization.id == org_id, Organization.inactive == False).first()
        if not org:
            raise HTTPException(status_code=404, detail="Organization not found")
        return org

    def update_organization(self, org_id: int, org_update: OrganizationUpdate, modified_by: str) -> Organization:
        org = self.get_organization(org_id)
        for key, value in org_update.dict(exclude_unset=True).items():
            setattr(org, key, value)
        
        org.modified_by = modified_by
        self.db.commit()
        self.db.refresh(org)
        return org

    def delete_organization(self, org_id: int, modified_by: str):
        org = self.get_organization(org_id)
        org.inactive = True
        org.modified_by = modified_by
        self.db.commit()

    # Branch Methods
    def create_branch(self, branch: BranchCreate, created_by: str) -> Branch:
        branch_data = branch.dict()
        if 'employees_count' in branch_data:
            del branch_data['employees_count']
            
        new_branch = Branch(**branch_data, created_by=created_by)
        self.db.add(new_branch)
        self.db.commit()
        self.db.refresh(new_branch)
        return new_branch

    def get_branches(self, organization_id: int, skip: int = 0, limit: int = 100) -> List[Branch]:
        return self.db.query(Branch).filter(
            Branch.organization_id == organization_id,
            Branch.inactive == False
        ).offset(skip).limit(limit).all()
        
        for branch in branches:
            branch.employees_count = len(branch.users)
            
        return branches

    def get_branch(self, branch_id: int, organization_id: int) -> Branch:
        branch = self.db.query(Branch).filter(
            Branch.id == branch_id,
            Branch.organization_id == organization_id,
            Branch.inactive == False
        ).first()
        if not branch:
            raise HTTPException(status_code=404, detail="Branch not found")
        return branch

    def update_branch(self, branch_id: int, branch_update: BranchUpdate, organization_id: int, modified_by: str) -> Branch:
        branch = self.get_branch(branch_id, organization_id)
        for key, value in branch_update.dict(exclude_unset=True).items():
            setattr(branch, key, value)
        
        branch.modified_by = modified_by
        self.db.commit()
        self.db.refresh(branch)
        return branch

    def delete_branch(self, branch_id: int, organization_id: int, modified_by: str):
        branch = self.get_branch(branch_id, organization_id)
        branch.inactive = True
        branch.modified_by = modified_by
        self.db.commit()
