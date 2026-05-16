from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.dependencies import get_current_user
from app.models.user_m import User
from app.models.booking_m import Booking
from app.schemas.booking_schema import BookingCreate, BookingResponse, BookingStatus
import uuid

router = APIRouter(prefix="/bookings", tags=["Bookings"])

@router.post("/", response_model=BookingResponse)
async def create_booking(
    booking: BookingCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Determine reference ID (e.g. EV-YYYY-XXXX)
    import random
    from datetime import datetime, timedelta
    ref_id = f"EV-{random.randint(10000, 99999)}"

    # Parse Event Date
    if hasattr(booking, 'event_date') and booking.event_date:
        if isinstance(booking.event_date, str):
            event_datetime = datetime.fromisoformat(booking.event_date.replace('Z', '+00:00'))
        else:
            event_datetime = booking.event_date
    else:
        event_datetime = datetime.now() + timedelta(days=7)
    
    # Create Booking
    # We must pass the parsed datetime to the internal model if it expects DateTime
    booking_dict = booking.dict()
    booking_dict['event_date'] = event_datetime

    new_booking = Booking(
        **booking_dict,
        reference_id=ref_id,
        customer_id=current_user.id,
        status=BookingStatus.under_process
    )
    
    db.add(new_booking)
    db.flush() # Get ID

    # Create corresponding Events for bidding based on services
    from app.models.event_m import Event, EventStatus
    from app.models.organization_m import Organization
    from app.models.category_m import Category
    from app.models.event_type_m import EventType
    from app.models.service_request_m import ServiceRequest

    org = db.query(Organization).first()
    etype = db.query(EventType).first()
    
    # Mapping for this demo
    service_to_cat_code = {
        "Food & Catering": "CATERING",
        "Venue Booking": "VENUE",
        "Decoration & Styling": "DECOR",
        "Photography & Video": "SOCIAL" # Fallback/Example
    }

    services_to_process = booking.services if booking.services else ["Food & Catering"]

    for service_name in services_to_process:
        cat_code = service_to_cat_code.get(service_name, "SOCIAL")
        cat = db.query(Category).filter(Category.code == cat_code).first()
        
        if not cat:
            cat = db.query(Category).first() # Final fallback

        if org and cat and etype:
            new_event = Event(
                organization_id=org.id,
                name=f"{new_booking.event_name} - {service_name}",
                category_id=cat.id,
                event_type_id=etype.id,
                event_date=event_datetime,
                location=new_booking.location,
                budget=new_booking.budget / len(services_to_process), # Split budget
                description=f"Service: {service_name}. {new_booking.requirements}",
                status=EventStatus.ACTIVE,
                created_by_user_id=current_user.id
            )
            db.add(new_event)
            db.flush()

            # Link ServiceRequest
            new_sr = ServiceRequest(
                booking_id=new_booking.id,
                service_name=service_name,
                status="pending"
            )
            db.add(new_sr)
            db.flush()

            # Trigger Notification to all vendors
            from app.services.notification_service import NotificationService
            notif_service = NotificationService(db)
            notif_service.notify_vendors_of_new_event(
                event_id=new_event.id,
                event_name=new_event.name,
                message=f"A new lead is available for {service_name} at {new_booking.location}. Budget: {new_event.budget}"
            )

    db.commit()
    db.refresh(new_booking)
    return new_booking

@router.get("/", response_model=List[BookingResponse])
async def get_my_bookings(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # If admin, show all? For now, let's assume this is mostly for customers.
    # We can add checking logic.
    if current_user.role.code in ["ADMIN", "SUPERADMIN"]:
         return db.query(Booking).all()
         
    return db.query(Booking).filter(Booking.customer_id == current_user.id).all()

@router.get("/{booking_id}", response_model=BookingResponse)
async def get_booking(
    booking_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
        
    # Check permission
    if current_user.role.code not in ["ADMIN", "SUPERADMIN"] and booking.customer_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to view this booking")
        
    return booking

class CancellationRequest(BaseModel):
    reason: str

@router.post("/{booking_id}/cancel")
async def cancel_booking(
    booking_id: int,
    request: CancellationRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    from app.services.refund_service import RefundService
    from app.services.finance_service import FinanceService
    
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    # Permission/Ownership check
    is_admin = current_user.role.code in ["ADMIN", "SUPERADMIN"]
    if not is_admin and booking.customer_id != current_user.id:
         raise HTTPException(status_code=403, detail="Not authorized to cancel this booking")

    if booking.status == BookingStatus.cancelled:
        raise HTTPException(status_code=400, detail="Booking already cancelled")

    # Identify who is cancelling
    cancelled_by = "ADMIN" if is_admin else "USER"
    # If Vendor cancels, that would be a separate endpoint on Vendor App side, 
    # but for now assuming this is Customer/Admin facing.

    # Calculate Penalty
    penalty = FinanceService.calculate_cancellation_penalty(booking, cancelled_by)

    # Process Refund Logic
    refund_service = RefundService(db)
    refund = refund_service.process_cancellation_refund(booking, cancelled_by, current_user.id)

    # Update Booking
    booking.status = BookingStatus.cancelled
    booking.cancellation_reason = request.reason
    booking.cancelled_by = cancelled_by
    booking.cancellation_penalty = penalty
    
    db.commit()
    db.refresh(booking)
    
    return {
        "message": "Booking cancelled successfully",
        "booking_id": booking.id,
        "status": booking.status,
        "refund_status": refund.status,
        "refund_type": refund.refund_type,
        "penalty_charged": penalty
    }
