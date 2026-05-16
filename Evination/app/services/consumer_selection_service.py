# app/services/consumer_selection_service.py

from sqlalchemy.orm import Session
from fastapi import HTTPException
from datetime import datetime

from app.models.vendor_bid_m import VendorBid
from app.models.vendor_m import Vendor
from app.models.event_m import Event, BiddingStatus, EventStatus
from app.models.vendor_order_m import VendorOrder

from app.schemas.consumer_schema import (
    ConsumerShortlistedBidResponse,
    ConsumerShortlistedEventSchema,
    ConsumerShortlistedBidSchema,
    ConsumerVendorSchema,
    ConsumerBidPricingSchema,
    ConsumerBidProposalSchema,
    ConsumerBidSelectionResponse
)
from app.schemas.vendor_order_schema import VendorOrderResponseSchema


class ConsumerSelectionService:

    @staticmethod
    def get_shortlisted_bids(
        db: Session,
        event_id: int,
        consumer_user
    ) -> ConsumerShortlistedBidResponse:
        """Consumer views top 3 shortlisted bids"""

        event = db.query(Event).filter(
            Event.id == event_id,
            Event.organization_id == consumer_user.organization_id,
            Event.inactive == False
        ).first()

        if not event:
            raise HTTPException(403, "Access denied or event not found")

        if event.bidding_status != BiddingStatus.SHORTLISTED:
            raise HTTPException(400, "No bids have been shortlisted yet for this event")

        bids = (
            db.query(VendorBid, Vendor)
            .join(Vendor)
            .filter(
                VendorBid.event_id == event_id,
                VendorBid.shortlisted == True,
                VendorBid.inactive == False
            )
            .order_by(VendorBid.shortlisted_rank)
            .all()
        )

        if not bids:
            raise HTTPException(404, "No shortlisted bids found")

        shortlisted_bids = []

        for bid, vendor in bids:
            if not bid.consumer_viewed_at:
                bid.consumer_viewed_at = datetime.utcnow()

            shortlisted_bids.append(
                ConsumerShortlistedBidSchema(
                    rank=bid.shortlisted_rank,
                    bidId=bid.id,
                    vendor=ConsumerVendorSchema(
                        id=vendor.id,
                        name=vendor.company_name,
                        rating=float(vendor.rating or 0),
                        totalReviews=vendor.total_reviews or 0,
                        completedEvents=vendor.completed_events or 0,
                        experienceYears=bid.vendor_experience_years or 0,
                        teamSize=vendor.team_size,
                        description=vendor.description
                    ),
                    pricing=ConsumerBidPricingSchema(
                        totalAmount=bid.total_amount,
                        serviceBreakdown=bid.service_breakdown
                    ),
                    proposal=ConsumerBidProposalSchema(
                        description=bid.proposal_description,
                        timelineDays=bid.timeline_days,
                        advantages=bid.advantages or [],
                        portfolio=bid.portfolio_items or [],
                        termsAndConditions=bid.terms_and_conditions,
                        cancellationPolicy=bid.cancellation_policy
                    ),
                    submittedAt=bid.submitted_at
                )
            )

        db.commit()

        return ConsumerShortlistedBidResponse(
            event=ConsumerShortlistedEventSchema(
                id=event.id,
                name=event.name,
                eventDate=event.event_date,
                budget=event.budget
            ),
            shortlistedBids=shortlisted_bids
        )

    @staticmethod
    def select_winning_bid(
        db: Session,
        event_id: int,
        bid_id: int,
        consumer_user
    ) -> ConsumerBidSelectionResponse:
        """Consumer selects the winning vendor"""

        event = db.query(Event).filter(
            Event.id == event_id,
            Event.organization_id == consumer_user.organization_id,
            Event.inactive == False
        ).first()

        if not event:
            raise HTTPException(403, "Access denied or event not found")

        if event.bidding_status != BiddingStatus.SHORTLISTED:
            raise HTTPException(400, "Event must be in shortlisted status")

        bid = db.query(VendorBid).filter(
            VendorBid.id == bid_id,
            VendorBid.event_id == event_id,
            VendorBid.shortlisted == True,
            VendorBid.inactive == False
        ).first()

        if not bid:
            raise HTTPException(404, "Invalid bid selection. Bid must be shortlisted.")

        bid.status = "selected"
        bid.selected_at = datetime.utcnow()
        bid.modified_by = consumer_user.username

        event.selected_vendor_id = bid.vendor_id
        event.selected_bid_id = bid.id
        event.vendor_selected_at = datetime.utcnow()
        event.bidding_status = BiddingStatus.AWARDED
        # event.status = EventStatus.CONFIRMED  <-- DEFERRED until payment
        event.modified_by = consumer_user.username

        db.query(VendorBid).filter(
            VendorBid.event_id == event_id,
            VendorBid.id != bid_id,
            VendorBid.shortlisted == True
        ).update(
            {
                "status": "rejected",
                "rejected_at": datetime.utcnow()
            },
            synchronize_session=False
        )

        db.commit()

        order = VendorOrder(
            vendor_id=bid.vendor_id,
            event_id=event.id,
            order_ref=f"ORD-{event.id}-{bid.vendor_id}",
            amount=bid.total_amount,
            status="pending_payment",  # Changed from confirmed
            # confirmed_at=datetime.utcnow(), # DEFERRED
            created_by=consumer_user.username
        )

        db.add(order)
        db.commit()
        db.refresh(order)

        return ConsumerBidSelectionResponse(
            message="Vendor selected successfully",
            order=VendorOrderResponseSchema.from_orm(order)
        )
