# ============================================
# ADMIN BID REVIEW SERVICE
# ============================================

from sqlalchemy.orm import Session
from fastapi import HTTPException
from datetime import datetime
from typing import List
from sqlalchemy import func

from app.models.vendor_bid_m import VendorBid
from app.models.vendor_m import Vendor
from app.models.event_m import Event, BiddingStatus

from app.schemas.vendor_bid_schema import (
    AdminEventBidReviewResponse,
    AdminBidReviewItemSchema,
    AdminVendorSnapshotSchema,
    AdminBidPricingSchema,
    AdminBidProposalSchema,
)
from app.schemas.event_schema import ConsumerEventListSchema
from app.schemas.vendor_bid_schema import AdminShortlistSchema, AdminScoreUpdateSchema


class AdminBidReviewService:

    # ---------------------------------------------------------
    # EVENTS WITH BIDS (FOR ADMIN DASHBOARD)
    # ---------------------------------------------------------
    @staticmethod
    def get_events_for_review(
        db: Session,
        skip: int = 0,
        limit: int = 100
    ) -> List[ConsumerEventListSchema]:

        events = db.query(Event).filter(
            Event.bidding_status.in_(
                [BiddingStatus.OPEN, BiddingStatus.UNDER_REVIEW]
            ),
            Event.inactive == False
        ).offset(skip).limit(limit).all()

        response: List[ConsumerEventListSchema] = []

        for event in events:
            bid_count = db.query(func.count(VendorBid.id)).filter(
                VendorBid.event_id == event.id,
                VendorBid.status == "submitted",
                VendorBid.inactive == False
            ).scalar()

            if bid_count > 0:
                response.append(
                    ConsumerEventListSchema(
                        id=event.id,
                        name=event.name,
                        eventDate=event.event_date.strftime("%b %d, %Y"),
                        location=event.location,
                        budget=event.budget or 0,
                        biddingStatus=event.bidding_status,
                        bidCount=bid_count,
                        createdAt=event.created_at,
                    )
                )

        return response

    # ---------------------------------------------------------
    # BIDS FOR SINGLE EVENT (ADMIN REVIEW)
    # ---------------------------------------------------------
    @staticmethod
    def get_bids_for_event(
        db: Session,
        event_id: int
    ) -> AdminEventBidReviewResponse:

        event = db.query(Event).filter(Event.id == event_id).first()
        if not event:
            raise HTTPException(404, "Event not found")

        bids = db.query(VendorBid, Vendor).join(Vendor).filter(
            VendorBid.event_id == event_id,
            VendorBid.status == "submitted",
            VendorBid.inactive == False
        ).all()

        bid_items: List[AdminBidReviewItemSchema] = []

        for bid, vendor in bids:
            auto_score = AdminBidReviewService._calculate_auto_score(
                vendor, bid, event
            )

            bid_items.append(
                AdminBidReviewItemSchema(
                    bidId=bid.id,
                    vendor=AdminVendorSnapshotSchema(
                        id=vendor.id,
                        name=vendor.company_name,
                        rating=float(vendor.rating or 0),
                        totalReviews=vendor.total_reviews or 0,
                        completedEvents=vendor.completed_events or 0,
                        experienceYears=bid.vendor_experience_years or 0,
                        teamSize=vendor.team_size,
                    ),
                    pricing=AdminBidPricingSchema(
                        totalAmount=bid.total_amount,
                        serviceBreakdown=bid.service_breakdown,
                    ),
                    proposal=AdminBidProposalSchema(
                        description=bid.proposal_description,
                        timelineDays=bid.timeline_days,
                        advantages=bid.advantages or [],
                        portfolio=bid.portfolio_items or [],
                    ),
                    submittedAt=bid.submitted_at.isoformat()
                    if bid.submitted_at
                    else None,
                    autoScore=auto_score,
                    adminScore=float(bid.admin_score)
                    if bid.admin_score
                    else None,
                    adminNotes=bid.admin_notes,
                    shortlisted=bid.shortlisted,
                )
            )

        # Sort bids by auto score
        bid_items.sort(key=lambda x: x.autoScore, reverse=True)

        return AdminEventBidReviewResponse(
            event={
                "id": event.id,
                "name": event.name,
                "budget": float(event.budget or 0),
            },
            bids=bid_items,
        )

    # ---------------------------------------------------------
    # AUTO SCORE CALCULATION
    # ---------------------------------------------------------
    @staticmethod
    def _calculate_auto_score(
        vendor: Vendor,
        bid: VendorBid,
        event: Event
    ) -> float:

        score = 0.0

        # 1. Rating (30)
        if vendor.rating:
            score += float(vendor.rating) * 6

        # 2. Experience (25)
        score += min((vendor.completed_events or 0) * 1.5, 25)

        # 3. Budget competitiveness (25)
        if event.budget and bid.total_amount:
            budget = float(event.budget)
            amount = float(bid.total_amount)

            if amount <= budget:
                savings = ((budget - amount) / budget) * 100
                score += min(savings / 4, 20)
            else:
                over = ((amount - budget) / budget) * 100
                score -= min(over / 2, 15)

        # 4. Timeline (10)
        if bid.timeline_days:
            if bid.timeline_days <= 30:
                score += 10
            elif bid.timeline_days <= 60:
                score += 7
            elif bid.timeline_days <= 90:
                score += 5
            else:
                score += 3

        # 5. Reviews (10)
        score += min((vendor.total_reviews or 0) / 10, 10)

        return max(0, min(score, 100))

    # ---------------------------------------------------------
    # SHORTLIST TOP 3 BIDS
    # ---------------------------------------------------------
    @staticmethod
    def shortlist_top_3(
        db: Session,
        event_id: int,
        data: AdminShortlistSchema,
        admin_user
    ):

        if len(data.bid_ids) != 3:
            raise HTTPException(400, "Must select exactly 3 bids")

        event = db.query(Event).filter(Event.id == event_id).first()
        if not event:
            raise HTTPException(404, "Event not found")

        db.query(VendorBid).filter(
            VendorBid.event_id == event_id,
            VendorBid.status.in_(["submitted", "shortlisted"])
        ).update(
            {
                "shortlisted": False,
                "shortlisted_rank": None,
                "status": "submitted",
            },
            synchronize_session=False,
        )

        for rank, bid_id in enumerate(data.bid_ids, start=1):
            bid = db.query(VendorBid).filter(
                VendorBid.id == bid_id,
                VendorBid.event_id == event_id,
            ).first()

            if not bid:
                raise HTTPException(404, f"Bid {bid_id} not found")

            bid.shortlisted = True
            bid.shortlisted_rank = rank
            bid.status = "shortlisted"
            bid.admin_reviewed_at = datetime.utcnow()
            bid.admin_reviewed_by = admin_user.username
            bid.modified_by = admin_user.username

        event.bidding_status = BiddingStatus.SHORTLISTED
        event.modified_by = admin_user.username

        db.commit()

        return {
            "message": "Top 3 bids shortlisted successfully",
            "shortlistedBids": data.bid_ids,
        }

    # ---------------------------------------------------------
    # ADMIN SCORE UPDATE
    # ---------------------------------------------------------
    @staticmethod
    def update_admin_score(
        db: Session,
        bid_id: int,
        data: AdminScoreUpdateSchema,
        admin_user
    ):

        bid = db.query(VendorBid).filter(VendorBid.id == bid_id).first()
        if not bid:
            raise HTTPException(404, "Bid not found")

        if not 0 <= data.score <= 100:
            raise HTTPException(400, "Score must be between 0 and 100")

        bid.admin_score = data.score
        bid.admin_notes = data.notes
        bid.admin_reviewed_by = admin_user.username
        bid.admin_reviewed_at = datetime.utcnow()
        bid.modified_by = admin_user.username

        db.commit()

        return {"message": "Admin score updated successfully"}
