from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.vendor_category_schema import VendorCategoryCreate, VendorCategoryResponse
from app.services.vendor_category_service import VendorCategoryService
from app.dependencies import PermissionChecker, get_current_active_user
from app.models.user_m import User

router = APIRouter(prefix="/vendor-categories", tags=["Vendor Categories"])

@router.post(
    "/",
    response_model=VendorCategoryResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(PermissionChecker(["vendor.update"]))]
)
async def add_category(
    data: VendorCategoryCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = VendorCategoryService(db)
    return service.add_category_to_vendor(data)

@router.get(
    "/{vendor_id}",
    response_model=List[VendorCategoryResponse],
    dependencies=[Depends(PermissionChecker(["vendor.view"]))]
)
async def get_categories(
    vendor_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = VendorCategoryService(db)
    return service.get_vendor_categories(vendor_id)

@router.delete(
    "/{vendor_id}/{category_id}",
    dependencies=[Depends(PermissionChecker(["vendor.update"]))]
)
async def remove_category(
    vendor_id: int,
    category_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    service = VendorCategoryService(db)
    service.remove_category_from_vendor(vendor_id, category_id)
    return {"message": "Category removed from vendor"}
