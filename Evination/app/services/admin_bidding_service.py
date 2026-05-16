# app/services/admin_bidding_service.py

from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.vendor_bid_m import VendorBid
from app.models.vendor_m import Vendor
from app.models.event_m import Event


# -------------------------
# LIST ALL BIDS
# -------------------------
def fetch_all_bids(db: Session):
    results = (
        db.query(VendorBid, Vendor, Event)
        .join(Vendor, Vendor.id == VendorBid.vendor_id)
        .outerjoin(Event, Event.id == VendorBid.event_id)
        .order_by(VendorBid.submitted_at.desc())
        .all()
    )

    response = []
    for bid, vendor, event in results:
        response.append({
            "id": bid.id,
            "vendor_name": vendor.company_name,
            "vendor_rating": vendor.rating if hasattr(vendor, "rating") else None,
            "amount": float(bid.total_amount),
            "status": bid.status,
            "event_name": event.name if event else None,
            "event_date": event.event_date if event else None,
        })

    return response


# -------------------------
# GET SINGLE BID DETAILS
# -------------------------
def fetch_bid_details(db: Session, bid_id: int):
    result = (
        db.query(VendorBid, Vendor, Event)
        .join(Vendor, Vendor.id == VendorBid.vendor_id)
        .outerjoin(Event, Event.id == VendorBid.event_id)
        .filter(VendorBid.id == bid_id)
        .first()
    )

    if not result:
        return None

    bid, vendor, event = result

    return {
        "id": bid.id,
        "vendor_name": vendor.company_name,
        "vendor_rating": vendor.rating if hasattr(vendor, "rating") else None,
        "vendor_experience": vendor.experience if hasattr(vendor, "experience") else None,
        "completed_events": vendor.completed_events if hasattr(vendor, "completed_events") else None,
        "amount": float(bid.total_amount),
        "status": bid.status,
        "proposal": bid.notes,
        "includes": getattr(bid, "includes", None),
        "requirements": getattr(bid, "requirements", None),
        "advantages": getattr(bid, "advantages", None),
        "timeline_days": getattr(bid, "timeline_days", None),
        "proposed_date": getattr(bid, "proposed_date", None),
        "submitted_at": bid.submitted_at,
        "event_name": event.name if event else None,
        "event_date": event.event_date if event else None,
    }


# -------------------------
# ACCEPT BID
# -------------------------
def approve_bid(db: Session, bid_id: int, notes: str | None):
    bid = db.query(VendorBid).filter(VendorBid.id == bid_id).first()
    if not bid:
        return False

    bid.status = "accepted"
    if notes:
        bid.notes = notes

    db.commit()
    return True


# -------------------------
# REJECT BID
# -------------------------
def decline_bid(db: Session, bid_id: int, notes: str | None):
    bid = db.query(VendorBid).filter(VendorBid.id == bid_id).first()
    if not bid:
        return False

    bid.status = "rejected"
    if notes:
        bid.notes = notes

    db.commit()
    return True
