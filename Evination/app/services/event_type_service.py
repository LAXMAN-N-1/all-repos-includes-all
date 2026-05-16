from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.event_type_m import EventType
from app.models.event_m import Event
from app.models.category_m import Category
from app.schemas.event_type_schema import EventTypeCreate, EventTypeUpdate
from fastapi import HTTPException


class EventTypeService:
    
    @staticmethod
    def create_event_type(db: Session, event_type: EventTypeCreate, current_user):
        """Create new event type"""
        existing = db.query(EventType).filter(EventType.code == event_type.code).first()
        if existing:
            raise HTTPException(status_code=400, detail="Event type code already exists")
        
        # Check if category exists
        category = db.query(Category).filter(
            Category.id == event_type.category_id,
            Category.inactive == False
        ).first()
        
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")
        
        new_type = EventType(
            **event_type.dict(),
            created_by=current_user.username
        )
        db.add(new_type)
        db.commit()
        db.refresh(new_type)
        
        return {
            'id': new_type.id,
            'name': new_type.name,
            'code': new_type.code,
            'color': new_type.color,
            'category': category.name,
            'count': 0,
            'created_at': new_type.created_at
        }
    
    @staticmethod
    def get_event_types(db: Session, category_id: int = None, skip: int = 0, limit: int = 100):
        """Get event types with counts"""
        query = db.query(
            EventType,
            Category.name.label('category_name'),
            func.count(Event.id).label('events_count')
        ).select_from(EventType).join(
            Category, EventType.category_id == Category.id
        ).outerjoin(
            Event, Event.event_type_id == EventType.id
        ).filter(
            EventType.inactive == False
        )
        
        if category_id:
            query = query.filter(EventType.category_id == category_id)
        
        types = query.group_by(EventType.id, Category.name).offset(skip).limit(limit).all()
        
        result = []
        for t, cat_name, count in types:
            result.append({
                'id': t.id,
                'name': t.name,
                'code': t.code,
                'color': t.color,
                'category': cat_name,      # ✅ Match frontend expectation
                'count': count,            # ✅ Match frontend expectation
                'created_at': t.created_at
            })
        
        return result
    
    @staticmethod
    def get_event_type_by_id(db: Session, type_id: int):
        """Get event type by ID"""
        event_type = db.query(EventType).filter(
            EventType.id == type_id,
            EventType.inactive == False
        ).first()
        
        if not event_type:
            return None
        
        # Get category name
        category = db.query(Category).filter(
            Category.id == event_type.category_id
        ).first()
        
        # Get events count
        count = db.query(func.count(Event.id)).filter(
            Event.event_type_id == type_id,
            Event.inactive == False
        ).scalar() or 0
        
        return {
            'id': event_type.id,
            'name': event_type.name,
            'code': event_type.code,
            'color': event_type.color,
            'category': category.name if category else None,
            'count': count,
            'created_at': event_type.created_at
        }
    
    @staticmethod
    def update_event_type(db: Session, type_id: int, type_update: EventTypeUpdate, current_user):
        """Update event type"""
        event_type = db.query(EventType).filter(
            EventType.id == type_id,
            EventType.inactive == False
        ).first()
        
        if not event_type:
            raise HTTPException(status_code=404, detail="Event type not found")
        
        for key, value in type_update.dict(exclude_unset=True).items():
            setattr(event_type, key, value)
        
        event_type.modified_by = current_user.username
        db.commit()
        db.refresh(event_type)
        
        # Get category name
        category = db.query(Category).filter(
            Category.id == event_type.category_id
        ).first()
        
        # Get events count
        count = db.query(func.count(Event.id)).filter(
            Event.event_type_id == type_id,
            Event.inactive == False
        ).scalar() or 0
        
        return {
            'id': event_type.id,
            'name': event_type.name,
            'code': event_type.code,
            'color': event_type.color,
            'category': category.name if category else None,
            'count': count,
            'created_at': event_type.created_at
        }
    
    @staticmethod
    def delete_event_type(db: Session, type_id: int, current_user):
        """Soft delete event type"""
        event_type = db.query(EventType).filter(
            EventType.id == type_id,
            EventType.inactive == False
        ).first()
        
        if not event_type:
            raise HTTPException(status_code=404, detail="Event type not found")
        
        # Check if type has events
        events_count = db.query(func.count(Event.id)).filter(
            Event.event_type_id == type_id,
            Event.inactive == False
        ).scalar() or 0
        
        if events_count > 0:
            raise HTTPException(
                status_code=400, 
                detail=f"Cannot delete event type with {events_count} active events"
            )
        
        event_type.inactive = True
        event_type.modified_by = current_user.username
        db.commit()