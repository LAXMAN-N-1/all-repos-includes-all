from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.dependencies import get_db, get_current_user, PermissionChecker
from app.services.vendor_onboarding_service import VendorOnboardingService
from app.models.user_m import User
from pydantic import BaseModel
from typing import List, Optional, Any

router = APIRouter(prefix="/onboarding", tags=["Vendor Onboarding"])

# Pydantic Schemas
class InitiateRequest(BaseModel):
    vendor_type: str
    company_name: Optional[str] = None
    business_name: Optional[str] = None # For individual
    contact_person: str
    phone: Optional[str] = None
    email: Optional[str] = None

class BusinessDetailsRequest(BaseModel):
    company_name: Optional[str] = None
    city: str
    state: str
    coverage_areas: List[str] = []
    categories: List[Any] # List of dicts with category_id, etc.

class DocItem(BaseModel):
    type: str
    url: str
    number: Optional[str] = None

class DocumentUploadRequest(BaseModel):
    documents: List[DocItem]

# Routes

@router.post("/initiate")
def initiate_onboarding(
    data: InitiateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = VendorOnboardingService(db)
    try:
        vendor = service.initiate_registration(current_user.id, data.vendor_type, data.dict())
        return {"message": "Onboarding initiated", "vendor_id": vendor.id}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.patch("/details")
def save_details(
    data: BusinessDetailsRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = VendorOnboardingService(db)
    if not current_user.vendor_profile:
        raise HTTPException(status_code=404, detail="Vendor profile not found. Initiate first.")
    
    try:
        service.save_business_details(current_user.vendor_profile.id, data.dict())
        return {"message": "Details saved"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/documents")
def save_documents(
    data: DocumentUploadRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = VendorOnboardingService(db)
    if not current_user.vendor_profile:
        raise HTTPException(status_code=404, detail="Vendor profile not found.")
        
    try:
        # Convert list of DocItem to list of dict
        docs = [d.dict() for d in data.documents]
        service.save_documents(current_user.vendor_profile.id, docs)
        return {"message": "Documents saved"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/submit")
def submit_application(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = VendorOnboardingService(db)
    if not current_user.vendor_profile:
        raise HTTPException(status_code=404, detail="Vendor profile not found.")
        
    service.submit_for_approval(current_user.vendor_profile.id)
    return {"message": "Application submitted for approval"}
