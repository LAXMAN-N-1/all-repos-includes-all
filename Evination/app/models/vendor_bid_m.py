from sqlalchemy import Column, Integer, String, Numeric, ForeignKey, DateTime, JSON, Boolean, Text
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class VendorBid(BaseModel):
    __tablename__ = "vendor_bids"

    # ----------------------------
    # CORE RELATIONS
    # ----------------------------
    vendor_id = Column(Integer, ForeignKey("vendors.id"), nullable=False)
    event_id = Column(Integer, ForeignKey("events.id"), nullable=False)
    
    # REMOVED: category_id (not needed - bid is for entire event)
    
    # ----------------------------
    # BID PRICING
    # ----------------------------
    total_amount = Column(Numeric(15, 2), nullable=False)
    
    # Optional: Breakdown by service
    service_breakdown = Column(JSON, nullable=True)
    # [
    #   {"service_id": 1, "service_name": "Catering", "cost": 100000, "notes": "300 pax"},
    #   {"service_id": 2, "service_name": "Decoration", "cost": 50000, "notes": "Theme setup"}
    # ]
    
    # ----------------------------
    # PROPOSAL DETAILS
    # ----------------------------
    proposal_description = Column(Text, nullable=True)
    timeline_days = Column(Integer, nullable=True)
    proposed_date = Column(DateTime, nullable=True)
    
    # Vendor's competitive advantages
    advantages = Column(JSON, nullable=True)
    # ["Licensed & Insured", "5+ years experience", "24/7 support"]
    
    # Portfolio items for this bid
    portfolio_items = Column(JSON, nullable=True)
    # [{"type": "image", "url": "..."}, {"type": "video", "url": "..."}]
    
    # Terms & Conditions
    terms_and_conditions = Column(Text, nullable=True)
    cancellation_policy = Column(Text, nullable=True)
    
    # ----------------------------
    # STATUS TRACKING
    # ----------------------------
    status = Column(String(50), default="draft")
    # draft -> submitted -> under_review -> shortlisted -> selected/rejected
    
    notes = Column(Text, nullable=True)  # Internal vendor notes
    
    # ----------------------------
    # ADMIN REVIEW FIELDS
    # ----------------------------
    admin_score = Column(Numeric(5, 2), nullable=True)  # 0-100
    admin_notes = Column(Text, nullable=True)
    shortlisted = Column(Boolean, default=False)
    shortlisted_rank = Column(Integer, nullable=True)  # 1, 2, or 3
    admin_reviewed_by = Column(String(100), nullable=True)
    admin_reviewed_at = Column(DateTime, nullable=True)
    
    # ----------------------------
    # VENDOR PROFILE SNAPSHOT (at bid time)
    # ----------------------------
    vendor_rating = Column(Numeric(3, 2), nullable=True)
    vendor_completed_events = Column(Integer, nullable=True)
    vendor_experience_years = Column(Integer, nullable=True)
    
    # ----------------------------
    # TIMESTAMPS
    # ----------------------------
    submitted_at = Column(DateTime, nullable=True)
    consumer_viewed_at = Column(DateTime, nullable=True)
    selected_at = Column(DateTime, nullable=True)
    rejected_at = Column(DateTime, nullable=True)
    
    # ----------------------------
    # RELATIONSHIPS
    # ----------------------------
    vendor = relationship("Vendor", back_populates="bids", foreign_keys=[vendor_id])
    event = relationship("Event", back_populates="bids", foreign_keys=[event_id])

