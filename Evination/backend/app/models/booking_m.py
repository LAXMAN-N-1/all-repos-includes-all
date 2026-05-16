from sqlalchemy import Column, Integer, String, Float, Text, ForeignKey, Enum, Boolean, DateTime, JSON
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel
import enum

class BookingStatus(str, enum.Enum):
    under_process = "under_process"
    awaiting_vendors = "awaiting_vendors"
    awaiting_payment = "awaiting_payment"
    confirmed = "confirmed"
    completed = "completed"
    cancelled = "cancelled"

class Booking(BaseModel):
    __tablename__ = "bookings"

    reference_id = Column(String(100), unique=True, index=True)
    customer_id = Column(Integer, ForeignKey("users.id"))
    
    # Event Details from Customer App
    event_name = Column(String(255))
    event_type = Column(String(100))
    event_date = Column(String(100)) # Keep as string for now to match customer app, or migrate to DateTime later
    event_time = Column(String(100), nullable=True)
    location = Column(String(255))
    city = Column(String(100), nullable=True)
    guest_count = Column(String(50), nullable=True)
    budget = Column(Float)
    services = Column(JSON, nullable=True)  # Array of service names from customer app
    requirements = Column(Text, nullable=True)
    
    status = Column(Enum(BookingStatus), default=BookingStatus.under_process)
    
    # Metadata
    transaction_id = Column(String(100), nullable=True)
    booking_step = Column(String(50), default="details")

    # Relationships
    customer = relationship("User", back_populates="bookings")
    service_requests = relationship("ServiceRequest", back_populates="booking")
    # payments = relationship("Payment", back_populates="booking") # To be implemented/linked
    
    # ----------------------------
    # NEW FIELDS FOR POLICY START
    # ----------------------------
    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=True)
    
    # ----------------------------
    # REQUEST DETAILS (Enhanced)
    # ----------------------------
    sub_category = Column(String(100), nullable=True) # e.g., Hindu Wedding
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    images = Column(JSON, nullable=True) # List of image URLs
    
    # ----------------------------
    # FINANCIAL STATUS
    # ----------------------------
    payment_status = Column(String(50), default="pending") # pending, paid, partial, refunded
    escrow_status = Column(String(50), default="none") # none, held, released, disputed
    payment_schedule = Column(JSON, nullable=True) # Breakdown of milestones

    # Work Status for Refund Policy
    work_started = Column(Boolean, default=False)
    work_started_at = Column(DateTime, nullable=True)
    
    # Cancellation Details
    cancellation_reason = Column(String(500), nullable=True)
    cancelled_by = Column(String(50), nullable=True) # USER, VENDOR, ADMIN, SYSTEM
    cancellation_penalty = Column(Float, default=0.0)
    
    # ----------------------------
    # NEW FIELDS FOR POLICY END
    # ----------------------------

    # Optional link to Admin Event if promoted
    # event_id = Column(Integer, ForeignKey("events.id"), nullable=True)
