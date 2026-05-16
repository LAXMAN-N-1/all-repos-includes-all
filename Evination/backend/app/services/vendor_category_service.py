from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.vendor_category_m import VendorCategory
from app.models.vendor_m import Vendor
from app.models.category_m import Category
from app.schemas.vendor_category_schema import VendorCategoryCreate

class VendorCategoryService:
    def __init__(self, db: Session):
        self.db = db

    def add_category_to_vendor(self, data: VendorCategoryCreate):
        # Check if exists
        existing = self.db.query(VendorCategory).filter(
            VendorCategory.vendor_id == data.vendor_id,
            VendorCategory.category_id == data.category_id
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="Vendor already has this category")

        # Check validity
        vendor = self.db.query(Vendor).filter(Vendor.id == data.vendor_id).first()
        if not vendor:
            raise HTTPException(status_code=404, detail="Vendor not found")
            
        category = self.db.query(Category).filter(Category.id == data.category_id).first()
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")

        new_link = VendorCategory(**data.dict())
        self.db.add(new_link)
        self.db.commit()
        self.db.refresh(new_link)
        
        return self._format_response(new_link, vendor, category)

    def get_vendor_categories(self, vendor_id: int):
        links = self.db.query(VendorCategory, Vendor, Category).\
            join(Vendor, VendorCategory.vendor_id == Vendor.id).\
            join(Category, VendorCategory.category_id == Category.id).\
            filter(VendorCategory.vendor_id == vendor_id).all()
            
        return [self._format_response(link, vendor, category) for link, vendor, category in links]

    def remove_category_from_vendor(self, vendor_id: int, category_id: int):
        link = self.db.query(VendorCategory).filter(
            VendorCategory.vendor_id == vendor_id,
            VendorCategory.category_id == category_id
        ).first()
        
        if not link:
            raise HTTPException(status_code=404, detail="Category assignment not found")
            
        self.db.delete(link)
        self.db.commit()

    def _format_response(self, link, vendor, category):
        return {
            "vendor_id": link.vendor_id,
            "category_id": link.category_id,
            "vendor_name": vendor.company_name if vendor else None,
            "category_name": category.name if category else None
        }
