from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from fastapi import HTTPException
from app.models.user_m import User
from app.models.role_m import Role
from app.models.booking_m import Booking, BookingStatus

class AdminCustomerService:
    def __init__(self, db: Session):
        self.db = db

    def get_customers(self, skip: int = 0, limit: int = 100, search: str = None):
        query = (
            self.db.query(User)
            .join(Role)
            .filter(Role.code == "CUSTOMER")
        )

        if search:
            search_filter = f"%{search}%"
            query = query.filter(
                (User.first_name.ilike(search_filter)) |
                (User.last_name.ilike(search_filter)) |
                (User.email.ilike(search_filter)) |
                (User.phone.ilike(search_filter))
            )

        users = query.offset(skip).limit(limit).all()
        
        results = []
        for user in users:
            # Aggregating Booking Stats
            bookings = self.db.query(Booking).filter(Booking.customer_id == user.id).all()
            
            total_bookings = len(bookings)
            active_bookings = len([b for b in bookings if b.status not in [BookingStatus.completed, BookingStatus.cancelled]])
            
            # reliable spent calculation: sum of budget for confirmed/completed bookings
            spent_bookings = [b for b in bookings if b.status in [BookingStatus.confirmed, BookingStatus.completed]]
            total_spent = sum([b.budget or 0.0 for b in spent_bookings])
            
            avg_spent = total_spent / len(spent_bookings) if spent_bookings else 0.0
            
            # Simple Tier Logic
            tier = "Standard"
            if total_spent > 500000:
                tier = "VIP"
            elif total_spent > 100000:
                tier = "Premium"

            results.append({
                "id": user.id,
                "name": f"{user.first_name or ''} {user.last_name or ''}".strip() or user.username,
                "email": user.email,
                "phone": user.phone,
                "location": user.location,
                "join_date": user.created_at,
                "last_active": user.last_login_at or user.updated_at,
                
                "total_bookings": total_bookings,
                "active_bookings": active_bookings,
                "total_spent": total_spent,
                "avg_spent": avg_spent,
                
                "tier": tier,
                "status": "Active" if not user.inactive else "Inactive"
            })
            
        return results

    def get_customer_details(self, customer_id: int):
        user = self.db.query(User).filter(User.id == customer_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="Customer not found")
            
        # Re-using logic (could be refactored to shared method)
        bookings = self.db.query(Booking).filter(Booking.customer_id == user.id).all()
        
        total_bookings = len(bookings)
        active_bookings = len([b for b in bookings if b.status not in [BookingStatus.completed, BookingStatus.cancelled]])
        
        spent_bookings = [b for b in bookings if b.status in [BookingStatus.confirmed, BookingStatus.completed]]
        total_spent = sum([b.budget or 0.0 for b in spent_bookings])
        
        avg_spent = total_spent / len(spent_bookings) if spent_bookings else 0.0
        
        tier = "Standard"
        if total_spent > 500000:
            tier = "VIP"
        elif total_spent > 100000:
            tier = "Premium"

        return {
            "id": user.id,
            "name": f"{user.first_name or ''} {user.last_name or ''}".strip() or user.username,
            "email": user.email,
            "phone": user.phone,
            "location": user.location,
            "join_date": user.created_at,
            "last_active": user.last_login_at or user.updated_at,
            
            "total_bookings": total_bookings,
            "active_bookings": active_bookings,
            "total_spent": total_spent,
            "avg_spent": avg_spent,
            "tier": tier,
            "status": "Active" if not user.inactive else "Inactive",
            
            # Details
            "gender": "Unknown", # Add field to User model if needed
            "anniversary": None, # Add field to User model if needed
            "preferences": {}, # Placeholder
            "admin_notes": "High value potential" if tier == "Premium" else None # Placeholder
        }
