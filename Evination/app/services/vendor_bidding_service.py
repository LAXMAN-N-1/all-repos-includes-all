# app/services/vendor_bidding_service.py

from sqlalchemy.orm import Session
from fastapi import HTTPException
from datetime import datetime
from typing import List, Optional
from fastapi.encoders import jsonable_encoder

from app.models.vendor_bid_m import VendorBid
from app.models.event_m import Event, BiddingStatus
from app.models.vendor_m import Vendor
from app.models.service_m import Service

from app.schemas.vendor_bid_schema import (
    VendorBidCreateSchema,
    VendorAvailableEventSchema,
    BidRequiredServiceSchema,
    VendorMyBidSchema,
    VendorBidUpdateSchema,
    VendorBidDetailSchema,
)

class VendorBiddingService:

    @staticmethod
    def get_available_events(
        db: Session,
        vendor_id: int,
        skip: int = 0,
        limit: int = 100
    ) -> List[VendorAvailableEventSchema]:

        vendor = db.query(Vendor).filter(Vendor.id == vendor_id).first()
        if not vendor:
            raise HTTPException(404, "Vendor not found")

        vendor_services = set(vendor.offered_services or [])

        events = db.query(Event).filter(
            Event.bidding_status == BiddingStatus.OPEN.value,
            Event.inactive == False
        ).offset(skip).limit(limit).all()

        result: List[VendorAvailableEventSchema] = []

        for event in events:
            # Check if vendor offers ALL required services
            if not set(event.required_services).issubset(vendor_services):
                continue

            existing_bid = db.query(VendorBid).filter(
                VendorBid.event_id == event.id,
                VendorBid.vendor_id == vendor_id,
                VendorBid.inactive == False
            ).first()

            if existing_bid:
                continue

            services = db.query(Service).filter(
                Service.id.in_(event.required_services)
            ).all()

            required_services = [
                BidRequiredServiceSchema(
                    id=s.id,
                    name=s.name,
                    icon=s.icon
                )
                for s in services
            ]

            result.append(
                VendorAvailableEventSchema(
                    id=event.id,
                    name=event.name,
                    eventDate=event.event_date.isoformat(),
                    location=f"{event.city}, {event.state}"
                    if event.city and event.state
                    else event.location,
                    expectedAttendees=event.expected_attendees,
                    budget=event.budget,
                    requiredServices=required_services,
                    biddingDeadline=event.bidding_deadline.isoformat()
                    if event.bidding_deadline
                    else None,
                    description=event.description,
                    specialRequirements=event.special_requirements
                )
            )

        return result

    @staticmethod
    def submit_bid(
        db: Session,
        vendor_id: int,
        bid_data: VendorBidCreateSchema
    ):

        event = db.query(Event).filter(
            Event.id == bid_data.event_id,
            Event.inactive == False
        ).first()

        if not event:
            raise HTTPException(404, "Event not found")

        if event.bidding_status != BiddingStatus.OPEN.value:
            raise HTTPException(400, "Bidding is closed for this event")

        if event.bidding_deadline and datetime.utcnow() > event.bidding_deadline:
            raise HTTPException(400, "Bidding deadline has passed")

        vendor = db.query(Vendor).filter(Vendor.id == vendor_id).first()
        if not vendor:
            raise HTTPException(404, "Vendor not found")

        if not set(event.required_services).issubset(set(vendor.offered_services or [])):
            raise HTTPException(
                400,
                "You don't offer all required services for this event"
            )

        existing = db.query(VendorBid).filter(
            VendorBid.vendor_id == vendor_id,
            VendorBid.event_id == event.id,
            VendorBid.inactive == False
        ).first()

        if existing:
            raise HTTPException(400, "You already submitted a bid")

        bid = VendorBid(
            event_id=event.id,
            vendor_id=vendor_id,
            total_amount=bid_data.total_amount,
            service_breakdown=jsonable_encoder(bid_data.service_breakdown)
            if bid_data.service_breakdown
            else None,
            proposal_description=bid_data.proposal_description,
            timeline_days=bid_data.timeline_days,
            advantages=bid_data.advantages,
            portfolio_items=jsonable_encoder(bid_data.portfolio_items or []),
            terms_and_conditions=bid_data.terms_and_conditions,
            cancellation_policy=bid_data.cancellation_policy,
            notes=bid_data.notes,
            status="submitted",
            submitted_at=datetime.utcnow(),
            vendor_rating=float(vendor.rating) if vendor.rating else 0.0,
            vendor_completed_events=vendor.completed_events or 0,
            vendor_experience_years=VendorBiddingService._calculate_experience(
                vendor.year_established
            ),
            created_by=f"vendor_{vendor_id}"
        )

        db.add(bid)
        db.commit()
        db.refresh(bid)

        return {
            "message": "Bid submitted successfully",
            "bid_id": bid.id,
            "status": bid.status
        }

    @staticmethod
    def get_my_bids(
        db: Session,
        vendor_id: int,
        status: Optional[str] = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[VendorMyBidSchema]:

        query = db.query(VendorBid, Event).join(
            Event, VendorBid.event_id == Event.id
        ).filter(
            VendorBid.vendor_id == vendor_id,
            VendorBid.inactive == False
        )

        if status:
            query = query.filter(VendorBid.status == status)

        bids = query.order_by(
            VendorBid.submitted_at.desc()
        ).offset(skip).limit(limit).all()

        return [
            VendorMyBidSchema(
                bidId=bid.id,
                eventName=event.name,
                eventDate=event.event_date.strftime("%b %d, %Y"),
                totalAmount=float(bid.total_amount),
                status=bid.status,
                submittedAt=bid.submitted_at.isoformat()
                if bid.submitted_at
                else None,
                shortlisted=bid.shortlisted,
                shortlistedRank=bid.shortlisted_rank
            )
            for bid, event in bids
        ]


    @staticmethod
    def _calculate_experience(year_established: Optional[str]) -> int:
        if not year_established:
            return 0
        try:
            return max(0, datetime.now().year - int(year_established))
        except ValueError:
            return 0

    @staticmethod
    def get_bid_details(
        db: Session,
        bid_id: int,
        vendor_id: int
    ) -> VendorBidDetailSchema:
        bid = db.query(VendorBid).filter(
            VendorBid.id == bid_id,
            VendorBid.vendor_id == vendor_id,
            VendorBid.inactive == False
        ).first()

        if not bid:
            raise HTTPException(404, "Bid not found")

        # Fetch event for details
        event = db.query(Event).get(bid.event_id)

        return VendorBidDetailSchema(
            id=bid.id,
            event_id=event.id,
            event_name=event.name,
            event_date=event.event_date.strftime("%Y-%m-%d"),
            bidding_deadline=event.bidding_deadline.isoformat() if event.bidding_deadline else None,
            total_amount=bid.total_amount,
            service_breakdown=bid.service_breakdown,
            proposal_description=bid.proposal_description,
            timeline_days=bid.timeline_days,
            advantages=bid.advantages or [],
            portfolio_items=bid.portfolio_items or [],
            terms_and_conditions=bid.terms_and_conditions,
            cancellation_policy=bid.cancellation_policy,
            notes=bid.notes,
            status=bid.status,
            submitted_at=bid.submitted_at.isoformat() if bid.submitted_at else None,
            shortlisted=bid.shortlisted
        )

    @staticmethod
    def update_bid(
        db: Session,
        bid_id: int,
        vendor_id: int,
        bid_data: VendorBidUpdateSchema
    ):
        bid = db.query(VendorBid).filter(
            VendorBid.id == bid_id,
            VendorBid.vendor_id == vendor_id,
            VendorBid.inactive == False
        ).first()

        if not bid:
            raise HTTPException(404, "Bid not found")

        event = db.query(Event).get(bid.event_id)
        if event.bidding_deadline and datetime.utcnow() > event.bidding_deadline:
             raise HTTPException(400, "Cannot edit bid after deadline")
        
        if bid.status not in ["submitted"]:
             raise HTTPException(400, f"Cannot edit bid in '{bid.status}' status")

        update_data = bid_data.model_dump(exclude_unset=True)
        if "service_breakdown" in update_data:
            update_data["service_breakdown"] = jsonable_encoder(update_data["service_breakdown"])
        if "portfolio_items" in update_data:
            update_data["portfolio_items"] = jsonable_encoder(update_data["portfolio_items"])

        for key, value in update_data.items():
            setattr(bid, key, value)
        
        db.commit()
        db.refresh(bid)
        return {"message": "Bid updated successfully"}

    @staticmethod
    def withdraw_bid(
        db: Session,
        bid_id: int,
        vendor_id: int
    ):
        bid = db.query(VendorBid).filter(
            VendorBid.id == bid_id,
            VendorBid.vendor_id == vendor_id,
            VendorBid.inactive == False
        ).first()

        if not bid:
            raise HTTPException(404, "Bid not found")
            
        event = db.query(Event).get(bid.event_id)
        # Assuming one can always withdraw if it's not already awarded etc.
        # But maybe restrict if shortlisted? strict rules: deadline only?
        # For now, allow withdraw if status is submitted.
        
        if bid.status not in ["submitted"]:
             raise HTTPException(400, f"Cannot withdraw bid in '{bid.status}' status")

        # Soft delete or hard delete? "Withdraw" usually implies it's gone for consideration.
        # But we might want to keep history.
        # Let's set inactive=True (Soft Delete) or just delete.
        # Given standard practice, let's just delete for now as per "Withdraw/Remove".
        # Or mark status as "withdrawn" if enum supported. 
        # Checking schema... statuses are strings.
        
        # bid.status = "withdrawn"
        # db.commit()
        
        # User requested DELETE endpoint implying removal. Let's soft delete.
        bid.inactive = True
        db.commit()
        
        return {"message": "Bid withdrawn successfully"}

