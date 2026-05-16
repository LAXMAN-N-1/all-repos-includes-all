from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, JSON, Text
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class VendorBid(BaseModel):
    __tablename__ = "vendor_bids"

    # ----------------------------
    # RELATIONS
    # ----------------------------
    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    # Admin System Link
    event_id = Column(Integer, ForeignKey("events.id"), nullable=True)
    # Customer System Link
    service_request_id = Column(Integer, ForeignKey("service_requests.id"), nullable=True)
    
    category_id = Column(Integer, nullable=True)

    # ----------------------------
    # BID DETAILS
    # ----------------------------
    amount = Column(Float, nullable=False)
    status = Column(String(50), default="pending")
    # pending, submitted, rejected, accepted, cancelled

    notes = Column(String(500), nullable=True)
    # Mapping Customer 'proposal' to 'notes' or 'description'? 
    # Customer has 'proposal' (Text). Admin has 'notes' (String 500). 
    # Let's add proposal text.
    proposal = Column(Text, nullable=True)
    
    submitted_at = Column(DateTime, nullable=True)
    accepted_at = Column(DateTime, nullable=True)

    # ----------------------------
    # EXTENDED FIELDS FOR ADMIN UI
    # ----------------------------

    # For Timeline/Delivery time
    timeline_days = Column(Integer, nullable=True)

    # Proposed delivery / event date
    proposed_date = Column(DateTime, nullable=True)

    # UI shows list of advantages → JSON list
    advantages = Column(JSON, nullable=True)

    # Requirements (e.g., certificates)
    requirements = Column(JSON, nullable=True)

    # Services included (Admin Bid Details)
    includes = Column(JSON, nullable=True)
    
    # Detailed Quote Fields
    line_items = Column(JSON, nullable=True) # [{desc, qty, unit_price, total}]
    tax = Column(Float, default=0.0)
    terms = Column(JSON, nullable=True) # List of strings

    # ----------------------------
    # ADMIN CURATION & PRICING
    # ----------------------------
    platform_commission = Column(Float, default=0.0)
    gst_on_commission = Column(Float, default=0.0)
    gateway_fee = Column(Float, default=0.0)
    final_price = Column(Float, default=0.0) # The price shown to customer

    # Comparison Fields
    discount = Column(Float, default=0.0)
    valid_until = Column(DateTime, nullable=True)

    # ----------------------------
    # Vendor Profile Snapshot
    # ----------------------------
    vendor_rating = Column(Float, nullable=True)
    vendor_experience = Column(String(50), nullable=True)
    vendor_completed_events = Column(Integer, nullable=True)
    
    # New Field for Admin Shortlisting
    is_pushed = Column(Integer, default=0) # 0: No, 1: Yes. Using Integer for wider compatibility if needed, but bool is also fine.
    # Actually let's use Boolean if possible, but SQLAlchemy usually handles bool.
    # The existing codebase seems to use standard types.

    # ----------------------------
    # Relationship
    # ----------------------------
    vendor = relationship("Vendor", back_populates="bids")
    event = relationship("Event", back_populates="bids")
    service_request = relationship("ServiceRequest", back_populates="bids")


# IMPORTANT — Import AFTER class definition
from .service_request_m import ServiceRequest
