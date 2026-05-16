from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.event_manager_profile_m import EventManagerProfile
from app.models.user_m import User
from app.models.event_m import Event, EventStatus
from app.schemas.event_manager_schema import EventManagerProfileCreate, EventManagerProfileUpdate
from fastapi import HTTPException
import json


class EventManagerService:
    
    @staticmethod
    def create_profile(db: Session, profile: EventManagerProfileCreate, current_user):
        """Create event manager profile"""
        # Check if user exists
        user = db.query(User).filter(User.id == profile.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Check if profile already exists
        existing = db.query(EventManagerProfile).filter(
            EventManagerProfile.user_id == profile.user_id
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="Manager profile already exists")
        
        # Convert specialties list to JSON
        specialties_json = json.dumps(profile.specialties) if profile.specialties else None
        
        new_profile = EventManagerProfile(
            user_id=profile.user_id,
            specialties=specialties_json,
            availability_status=profile.availability_status,
            max_concurrent_events=profile.max_concurrent_events,
            created_by=current_user.username
        )
        
        db.add(new_profile)
        db.commit()
        db.refresh(new_profile)
        
        return EventManagerService._format_manager_response(db, new_profile)
    
    @staticmethod
    def get_managers_with_stats(
        db: Session,
        organization_id: int,
        availability_status: str = None,
        skip: int = 0,
        limit: int = 100
    ):
        """Get all event managers with statistics"""
        query = db.query(
            EventManagerProfile,
            User
        ).join(User).filter(
            User.organization_id == organization_id,
            User.inactive == False,
            EventManagerProfile.inactive == False
        )
        
        if availability_status:
            query = query.filter(EventManagerProfile.availability_status == availability_status)
        
        managers = query.offset(skip).limit(limit).all()
        
        result = []
        for profile, user in managers:
            manager_data = EventManagerService._format_manager_response(db, profile, user)
            
            # Add extra stats
            total_budget = db.query(func.sum(Event.budget)).filter(
                Event.event_manager_id == user.id,
                Event.inactive == False
            ).scalar() or 0
            
            avg_attendees = db.query(func.avg(Event.expected_attendees)).filter(
                Event.event_manager_id == user.id,
                Event.inactive == False
            ).scalar() or 0
            
            manager_data['totalBudgetManaged'] = float(total_budget)
            manager_data['avgAttendees'] = int(avg_attendees) if avg_attendees else 0
            
            result.append(manager_data)
        
        return result
    
    @staticmethod
    def get_available_managers(db: Session, organization_id: int):
        """Get only available managers"""
        return EventManagerService.get_managers_with_stats(
            db, organization_id, availability_status="Available"
        )
    
    @staticmethod
    def get_manager_by_id(db: Session, manager_id: int):
        """Get manager profile by user ID"""
        profile = db.query(EventManagerProfile).filter(
            EventManagerProfile.user_id == manager_id,
            EventManagerProfile.inactive == False
        ).first()
        
        if profile:
            return EventManagerService._format_manager_response(db, profile)
        return None
    
    @staticmethod
    def _format_manager_response(db: Session, profile: EventManagerProfile, user: User = None):
        """Format manager data for response - with camelCase for frontend"""
        if not user:
            user = db.query(User).filter(User.id == profile.user_id).first()
        
        specialties = json.loads(profile.specialties) if profile.specialties else []
        
        # Generate avatar initials
        avatar = user.first_name[0].upper()
        if user.last_name:
            avatar += user.last_name[0].upper()
        else:
            avatar = user.first_name[0:2].upper()
        
        return {
            "id": profile.id,
            "userId": user.id,
            "name": f"{user.first_name} {user.last_name or ''}".strip(),
            "email": user.email,
            "avatar": avatar,
            "activeEvents": profile.active_events_count,      # ✅ Camel case
            "completedEvents": profile.completed_events_count, # ✅ Camel case
            "rating": float(profile.rating),
            "specialties": specialties,
            "status": profile.availability_status             # ✅ Renamed from availability_status
        }
    
    @staticmethod
    def update_profile(db: Session, manager_id: int, profile_update: EventManagerProfileUpdate, current_user):
        """Update manager profile"""
        profile = db.query(EventManagerProfile).filter(
            EventManagerProfile.user_id == manager_id
        ).first()
        
        if not profile:
            raise HTTPException(status_code=404, detail="Manager profile not found")
        
        update_data = profile_update.dict(exclude_unset=True)
        
        # Convert specialties to JSON if present
        if 'specialties' in update_data and update_data['specialties']:
            update_data['specialties'] = json.dumps(update_data['specialties'])
        
        for key, value in update_data.items():
            setattr(profile, key, value)
        
        profile.modified_by = current_user.username
        db.commit()
        db.refresh(profile)
        
        return EventManagerService._format_manager_response(db, profile)
    
    @staticmethod
    def get_manager_events(db: Session, manager_id: int, status: str = None):
        """Get events assigned to a manager"""
        query = db.query(Event).filter(
            Event.event_manager_id == manager_id,
            Event.inactive == False
        )
        
        if status:
            query = query.filter(Event.status == status)
        
        events = query.order_by(Event.event_date.desc()).all()
        
        return [{
            "id": e.id,
            "name": e.name,
            "eventDate": e.event_date,
            "location": e.location,
            "status": e.status.value,
            "expectedAttendees": e.expected_attendees,
            "budget": float(e.budget) if e.budget else 0
        } for e in events]
    
    @staticmethod
    def update_manager_stats(db: Session, manager_id: int):
        """Update manager statistics (call this when events change)"""
        profile = db.query(EventManagerProfile).filter(
            EventManagerProfile.user_id == manager_id
        ).first()
        
        if not profile:
            return
        
        # Count active events
        active_count = db.query(func.count(Event.id)).filter(
            Event.event_manager_id == manager_id,
            Event.status.in_([EventStatus.PLANNING, EventStatus.CONFIRMED, EventStatus.ACTIVE]),
            Event.inactive == False
        ).scalar()
        
        # Count completed events
        completed_count = db.query(func.count(Event.id)).filter(
            Event.event_manager_id == manager_id,
            Event.status == EventStatus.COMPLETED,
            Event.inactive == False
        ).scalar()
        
        profile.active_events_count = active_count
        profile.completed_events_count = completed_count
        
        # Update availability based on active events
        if active_count >= profile.max_concurrent_events:
            profile.availability_status = "Busy"
        elif profile.availability_status == "Busy" and active_count < profile.max_concurrent_events:
            profile.availability_status = "Available"
        
        db.commit()