from sqlalchemy.orm import Session
from sqlalchemy import func, or_
from app.models.event_m import Event, EventStatus
from app.models.category_m import Category
from app.models.event_type_m import EventType
from app.models.user_m import User
from app.schemas.event_schema import EventCreateSchema, EventUpdateSchema
from fastapi import HTTPException
from datetime import datetime


class EventService:
    
    @staticmethod
    def create_event(db: Session, event: EventCreateSchema, current_user):
        """Create new event"""
        # Exclude organization_id from schema dict (we'll set it from current_user)
        event_data = event.dict(exclude={'organization_id'})
        
        new_event = Event(
            **event_data,
            organization_id=current_user.organization_id,
            created_by=current_user.username
        )
        db.add(new_event)
        db.commit()
        db.refresh(new_event)
        return EventService._populate_event_details(db, new_event)
    
    @staticmethod
    def get_events_with_filters(
        db: Session, 
        organization_id: int,
        status: str = None,
        category_id: int = None,
        event_type_id: int = None,
        manager_id: int = None,
        search: str = None,
        skip: int = 0,
        limit: int = 100
    ):
        """Get events with multiple filters - formatted for frontend"""
        query = db.query(
            Event,
            Category.name.label('category_name'),
            EventType.name.label('event_type_name'),
            User.first_name,
            User.last_name
        ).select_from(Event).join(
            Category, Event.category_id == Category.id
        ).join(
            EventType, Event.event_type_id == EventType.id
        ).outerjoin(
            User, Event.event_manager_id == User.id
        ).filter(
            Event.organization_id == organization_id,
            Event.inactive == False
        )
        
        # Apply filters
        if status:
            query = query.filter(Event.status == status)
        if category_id:
            query = query.filter(Event.category_id == category_id)
        if event_type_id:
            query = query.filter(Event.event_type_id == event_type_id)
        if manager_id:
            query = query.filter(Event.event_manager_id == manager_id)
        if search:
            query = query.filter(
                or_(
                    Event.name.contains(search),
                    Event.location.contains(search),
                    Event.city.contains(search)
                )
            )
        
        events = query.order_by(Event.event_date.desc()).offset(skip).limit(limit).all()
        
        result = []
        for event, cat_name, type_name, fname, lname in events:
            # Format location properly
            location = event.location
            if event.city and event.state:
                location = f"{event.city}, {event.state}"
            elif event.city:
                location = event.city
            
            # Format manager name
            manager = None
            if fname:
                manager = f"{fname} {lname}" if lname else fname
            
            result.append({
                "id": event.id,
                "name": event.name,
                "category": cat_name,
                "type": type_name,  # Changed from event_type to type
                "date": event.event_date.strftime("%b %d, %Y"),
                "location": location,
                "attendees": event.expected_attendees,
                "budget": float(event.budget) if event.budget else 0,  # ✅ Ensure float
                "manager": manager,
                "status": event.status.value
            })
        
        return result
    
    @staticmethod
    def get_event_stats(db: Session, organization_id: int):
        """Get event statistics"""
        total = db.query(func.count(Event.id)).filter(
            Event.organization_id == organization_id,
            Event.inactive == False
        ).scalar()
        
        active = db.query(func.count(Event.id)).filter(
            Event.organization_id == organization_id,
            Event.status == EventStatus.ACTIVE,
            Event.inactive == False
        ).scalar()
        
        attendees = db.query(func.sum(Event.expected_attendees)).filter(
            Event.organization_id == organization_id,
            Event.inactive == False
        ).scalar() or 0
        
        budget = db.query(func.sum(Event.budget)).filter(
            Event.organization_id == organization_id,
            Event.inactive == False
        ).scalar() or 0
        
        return {
            "totalEvents": total,
            "activeEvents": active,
            "totalAttendees": attendees,
            "totalBudget": float(budget)  # ✅ Ensure float
        }
    
    @staticmethod
    def get_event_by_id(db: Session, event_id: int, organization_id: int):
        """Get event by ID"""
        event = db.query(Event).filter(
            Event.id == event_id,
            Event.organization_id == organization_id,
            Event.inactive == False
        ).first()
        
        if event:
            return EventService._populate_event_details(db, event)
        return None
    
    @staticmethod
    def _populate_event_details(db: Session, event: Event):
        """Populate event with related data - formatted for frontend"""
        
        # Get category name
        category = db.query(Category).filter(Category.id == event.category_id).first()
        
        # Get event type name
        event_type = db.query(EventType).filter(EventType.id == event.event_type_id).first()
        
        # Get manager name
        manager_name = None
        if event.event_manager_id:
            manager = db.query(User).filter(User.id == event.event_manager_id).first()
            if manager:
                manager_name = f"{manager.first_name} {manager.last_name or ''}".strip()
        
        # Get required services
        from app.models.service_m import Service
        required_services = []
        if event.required_services:
            services = db.query(Service).filter(
                Service.id.in_(event.required_services)
            ).all()
            required_services = [
                {
                    "id": s.id,
                    "name": s.name,
                    "code": s.code,
                    "icon": s.icon
                } for s in services
            ]
        
        return {
            "id": event.id,
            "organizationId": event.organization_id,
            "name": event.name,
            "categoryId": event.category_id,
            "categoryName": category.name if category else None,
            "eventTypeId": event.event_type_id,
            "eventTypeName": event_type.name if event_type else None,
            "eventDate": event.event_date,
            "startTime": event.start_time,
            "endTime": event.end_time,
            "location": event.location,
            "city": event.city,
            "state": event.state,
            "venue": event.venue,
            "expectedAttendees": event.expected_attendees,
            "actualAttendees": event.actual_attendees,
            "budget": float(event.budget) if event.budget else 0,
            "description": event.description,
            "specialRequirements": event.special_requirements,
            "status": event.status.value,
            "eventManagerId": event.event_manager_id,
            "managerName": manager_name,
            "requiredServices": required_services,
            "createdAt": event.created_at,
            "updatedAt": event.updated_at
        }
    
    @staticmethod
    def update_event(db: Session, event_id: int, event_update: EventUpdateSchema, current_user):
        """Update event"""
        event = db.query(Event).filter(
            Event.id == event_id,
            Event.organization_id == current_user.organization_id
        ).first()
        
        if not event:
            raise HTTPException(status_code=404, detail="Event not found")
        
        for key, value in event_update.dict(exclude_unset=True).items():
            setattr(event, key, value)
        
        event.modified_by = current_user.username
        db.commit()
        db.refresh(event)
        return EventService._populate_event_details(db, event)
    
    @staticmethod
    def delete_event(db: Session, event_id: int, current_user):
        """Soft delete event"""
        event = db.query(Event).filter(
            Event.id == event_id,
            Event.organization_id == current_user.organization_id
        ).first()
        
        if not event:
            raise HTTPException(status_code=404, detail="Event not found")
        
        event.inactive = True
        event.modified_by = current_user.username
        db.commit()
    
    @staticmethod
    def assign_manager(db: Session, event_id: int, manager_id: int, current_user):
        """Assign manager to event"""
        event = db.query(Event).filter(Event.id == event_id).first()
        if not event:
            raise HTTPException(status_code=404, detail="Event not found")
        
        manager = db.query(User).filter(User.id == manager_id).first()
        if not manager:
            raise HTTPException(status_code=404, detail="Manager not found")
        
        event.event_manager_id = manager_id
        event.modified_by = current_user.username
        db.commit()
        
        # Update manager stats
        from app.services.event_manager_service import EventManagerService
        EventManagerService.update_manager_stats(db, manager_id)