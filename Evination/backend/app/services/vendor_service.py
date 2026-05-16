from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List, Optional
from fastapi import HTTPException
from app.models.vendor_m import Vendor
from app.models.vendor_category_m import VendorCategory
from app.models.user_m import User
from app.schemas.vendor_schema import VendorProfileResponse

class VendorService:
    def __init__(self, db: Session):
        self.db = db

    def get_vendors(
        self, 
        status: Optional[str] = None, 
        business_type: Optional[str] = None,
        category_id: Optional[int] = None,
        search: Optional[str] = None, 
        skip: int = 0, 
        limit: int = 100
    ) -> List[Vendor]:
        query = self.db.query(Vendor).join(User).filter(Vendor.inactive == False)
        
        if status:
            query = query.filter(Vendor.status == status)
        
        if business_type:
            query = query.filter(Vendor.business_type == business_type)
            
        if category_id:
            query = query.join(VendorCategory).filter(VendorCategory.category_id == category_id)
            
        if search:
            query = query.filter(
                or_(
                    Vendor.company_name.contains(search),
                    User.first_name.contains(search),
                    User.email.contains(search),
                    Vendor.city.contains(search)
                )
            )
            
        return query.offset(skip).limit(limit).all()

    def get_vendor(self, vendor_id: int) -> Vendor:
        vendor = self.db.query(Vendor).join(User).filter(
            Vendor.id == vendor_id,
            Vendor.inactive == False
        ).first()
        if not vendor:
            raise HTTPException(status_code=404, detail="Vendor not found")
        return vendor

    def update_vendor_status(self, vendor_id: int, status: str, modified_by: str) -> Vendor:
        vendor = self.get_vendor(vendor_id)
        if status not in ["pending", "approved", "rejected", "blacklisted"]:
             raise HTTPException(status_code=400, detail="Invalid status")
        
        vendor.status = status
        vendor.modified_by = modified_by
        self.db.commit()
        self.db.refresh(vendor)
        return vendor

    def delete_vendor(self, vendor_id: int, modified_by: str):
        vendor = self.get_vendor(vendor_id)
        vendor.inactive = True
        vendor.modified_by = modified_by
        self.db.commit()
