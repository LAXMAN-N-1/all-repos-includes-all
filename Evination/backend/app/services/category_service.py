from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.category_m import Category
from app.models.event_m import Event
from app.models.event_type_m import EventType
from app.models.vendor_category_m import VendorCategory
from app.schemas.category_schema import CategoryCreate, CategoryUpdate
from fastapi import HTTPException


class CategoryService:
    
    @staticmethod
    def create_category(db: Session, category: CategoryCreate, current_user):
        """Create new category"""
        # Check if code exists
        existing = db.query(Category).filter(Category.code == category.code).first()
        if existing:
            raise HTTPException(status_code=400, detail="Category code already exists")
        
        new_category = Category(
            **category.dict(),
            created_by=current_user.username
        )
        db.add(new_category)
        db.commit()
        db.refresh(new_category)
        
        # Return formatted response
        return {
            'id': new_category.id,
            'name': new_category.name,
            'code': new_category.code,
            'description': new_category.description,
            'icon': new_category.icon,
            'color': new_category.color,
            'eventsCount': 0,
            'created_at': new_category.created_at
        }
    
    @staticmethod
    def get_categories_with_stats(db: Session, skip: int, limit: int):
        """Get all categories with event counts"""
        # First, get all categories
        categories = db.query(Category).filter(
            Category.inactive == False
        ).offset(skip).limit(limit).all()
        
        result = []
        for cat in categories:
            # Count events for this category
            events_count = db.query(func.count(Event.id)).filter(
                Event.category_id == cat.id,
                Event.inactive == False
            ).scalar() or 0
            
            # Count event types for this category
            event_types_count = db.query(func.count(EventType.id)).filter(
                EventType.category_id == cat.id,
                EventType.inactive == False
            ).scalar() or 0
            
            # Count vendors for this category
            vendors_count = db.query(func.count(VendorCategory.id)).filter(
                VendorCategory.category_id == cat.id
            ).scalar() or 0
            
            result.append({
                'id': cat.id,
                'name': cat.name,
                'code': cat.code,
                'description': cat.description,
                'icon': cat.icon,
                'color': cat.color,
                'eventsCount': events_count,
                'eventTypesCount': event_types_count,
                'vendorsCount': vendors_count,
                'created_at': cat.created_at
            })
        
        return result
    
    @staticmethod
    def get_category_by_id(db: Session, category_id: int):
        """Get category by ID"""
        category = db.query(Category).filter(
            Category.id == category_id,
            Category.inactive == False
        ).first()
        
        if not category:
            return None
        
        # Get events count for this category
        events_count = db.query(func.count(Event.id)).filter(
            Event.category_id == category_id,
            Event.inactive == False
        ).scalar() or 0
        
        # Get vendors count
        vendors_count = db.query(func.count(VendorCategory.id)).filter(
            VendorCategory.category_id == category_id
        ).scalar() or 0
        
        return {
            'id': category.id,
            'name': category.name,
            'code': category.code,
            'description': category.description,
            'icon': category.icon,
            'color': category.color,
            'eventsCount': events_count,
            'vendorsCount': vendors_count,
            'created_at': category.created_at
        }
    
    @staticmethod
    def update_category(db: Session, category_id: int, category_update: CategoryUpdate, current_user):
        """Update category"""
        category = db.query(Category).filter(
            Category.id == category_id,
            Category.inactive == False
        ).first()
        
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")
        
        for key, value in category_update.dict(exclude_unset=True).items():
            setattr(category, key, value)
        
        category.modified_by = current_user.username
        db.commit()
        db.refresh(category)
        
        # Get events count
        events_count = db.query(func.count(Event.id)).filter(
            Event.category_id == category_id,
            Event.inactive == False
        ).scalar() or 0
        
        # Get vendors count
        vendors_count = db.query(func.count(VendorCategory.id)).filter(
            VendorCategory.category_id == category_id
        ).scalar() or 0
        
        return {
            'id': category.id,
            'name': category.name,
            'code': category.code,
            'description': category.description,
            'icon': category.icon,
            'color': category.color,
            'eventsCount': events_count,
            'vendorsCount': vendors_count,
            'created_at': category.created_at
        }
    
    @staticmethod
    def delete_category(db: Session, category_id: int, current_user):
        """Soft delete category"""
        category = db.query(Category).filter(
            Category.id == category_id,
            Category.inactive == False
        ).first()
        
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")
        
        # Check if category has events
        events_count = db.query(func.count(Event.id)).filter(
            Event.category_id == category_id,
            Event.inactive == False
        ).scalar() or 0
        
        if events_count > 0:
            raise HTTPException(
                status_code=400, 
                detail=f"Cannot delete category with {events_count} active events"
            )
        
        category.inactive = True
        category.modified_by = current_user.username
        db.commit()