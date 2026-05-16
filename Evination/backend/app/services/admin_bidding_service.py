from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from fastapi import HTTPException
from app.models.vendor_bid_m import VendorBid
from app.models.vendor_m import Vendor
from app.models.event_m import Event

class AdminBiddingService:
    def __init__(self, db: Session):
        self.db = db

    def get_bids(self, skip: int = 0, limit: int = 100):
        results = (
            self.db.query(VendorBid, Vendor, Event)
            .join(Vendor, Vendor.id == VendorBid.vendor_id)
            .outerjoin(Event, Event.id == VendorBid.event_id)
            .order_by(VendorBid.submitted_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )

        response = []
        for bid, vendor, event in results:
            response.append({
                "id": bid.id,
                "vendor_name": vendor.company_name,
                "vendor_rating": vendor.rating if hasattr(vendor, "rating") else None,
                "amount": bid.amount,
                "status": bid.status,
                "event_name": event.name if event else None,
                "event_date": event.event_date if event else None,
                "is_pushed": bid.is_pushed
            })

        return response

    def get_dashboard_events(self):
        from sqlalchemy import func
        from sqlalchemy.orm import joinedload
        from datetime import datetime
        from app.models.event_m import Event
        
        events = (
            self.db.query(Event)
            .options(joinedload(Event.bids).joinedload(VendorBid.vendor))
            .all()
        )
        
        dashboard_data = []
        now = datetime.utcnow()
        
        for event in events:
            bids = event.bids # Relationship we added
            
            if not bids:
                total_bids = 0
                lowest_bid = 0.0
                highest_bid = 0.0
                average_bid = 0.0
                assigned_vendor = None
            else:
                amounts = [b.amount for b in bids]
                total_bids = len(bids)
                lowest_bid = min(amounts)
                highest_bid = max(amounts)
                average_bid = sum(amounts) / total_bids
                
                accepted_bid = next((b for b in bids if b.status == 'accepted'), None)
                assigned_vendor = None
                if accepted_bid:
                    assigned_vendor = {
                        "id": accepted_bid.vendor.id,
                        "name": accepted_bid.vendor.company_name,
                        "amount": accepted_bid.amount,
                        "rating": getattr(accepted_bid.vendor, 'rating', 4.5)
                    }

            # Calculate time left
            if event.event_date > now:
                delta = event.event_date - now
                time_left = f"{delta.days} days left"
            else:
                time_left = "Event Passed"

            dashboard_data.append({
                "id": event.id,
                "event_name": event.name,
                "event_date": event.event_date,
                "event_type": event.event_type.name if event.event_type else "Unknown",
                "status": "Awarded" if assigned_vendor else ("Active" if event.event_date > now else "Closed"),
                "categories": [event.category.name] if event.category else [], # Simplified for now
                "location": event.location or event.city or "Unknown",
                "description": event.description,
                "total_bids": total_bids,
                "lowest_bid": lowest_bid,
                "average_bid": average_bid,
                "highest_bid": highest_bid,
                "time_left": time_left,
                "assigned_vendor": assigned_vendor,
                "payment_status": "Pending" # Mock
            })
            
        return dashboard_data

    def get_customer_view(self, event_id: int):
        from sqlalchemy.orm import joinedload
        from app.models.event_m import Event
        
        event = (
            self.db.query(Event)
            .options(joinedload(Event.bids).joinedload(VendorBid.vendor).joinedload(Vendor.user))
            .filter(Event.id == event_id)
            .first()
        )
        
        if not event:
            raise HTTPException(status_code=404, detail="Event not found")
            
        bids = event.bids
        
        assigned_bid = None
        top_bids = []

        if bids:
            # Reusing logic to map bid to detail response structure
            def map_bid(b):
                v = b.vendor
                docs = getattr(v, "documents", [])
                certs = getattr(v, "certifications", [])
                specs = getattr(v, "specializations", [])
                return {
                    "id": b.id,
                    "vendor_name": v.company_name,
                    "vendor_rating": v.rating if hasattr(v, "rating") else 4.8,
                    "vendor_experience": v.year_established,
                    "completed_events": len(v.bids) if v.bids else 100,
                    
                    "vendor_phone": v.phone,
                    "vendor_email": v.user.email if v.user else "N/A",
                    "vendor_location": f"{v.city or ''}, {v.state or ''}".strip(", "),
                    "vendor_team_size": v.team_size,
                    "vendor_notes": v.description,
                    "vendor_documents": docs if docs else ['Proposal.pdf'],
                    "vendor_certifications": certs if certs else ['Verified'],
                    "vendor_specializations": specs if specs else ['General'],

                    "final_price": getattr(b, "final_price", b.amount),
                    "base_amount": b.amount,
                    "platform_commission": getattr(b, "platform_commission", 0.0),
                    "gst_on_commission": getattr(b, "gst_on_commission", 0.0),
                    "gateway_fee": getattr(b, "gateway_fee", 0.0),

                    "status": b.status,
                    "proposal": b.notes,
                    "includes": getattr(b, "includes", []),
                    "requirements": getattr(b, "requirements", []),
                    "advantages": getattr(b, "advantages", []),
                    "timeline_days": getattr(b, "timeline_days", 30),
                    "proposed_date": getattr(b, "proposed_date", None),
                    "submitted_at": b.submitted_at, 
                    "event_id": event.id,
                    "event_name": event.name,
                    "event_venue": getattr(event, "venue", "Unknown Venue"),
                    "event_location": getattr(event, "location", "Unknown Location"),
                    "event_guests": getattr(event, "expected_attendees", 0),
                    "event_date": event.event_date,
                }
            
            # Find assigned bid
            accepted_bid_obj = next((b for b in bids if b.status == 'accepted'), None)
            if accepted_bid_obj:
                assigned_bid = map_bid(accepted_bid_obj)
            
            # Filter bids that have been pushed by admin
            pushed_bids = [b for b in bids if getattr(b, 'is_pushed', 0) == 1]
            top_bids = [map_bid(b) for b in pushed_bids]
            
        return {
            "event_id": event.id,
            "event_name": event.name,
            "event_date": event.event_date,
            "event_location": event.location,
            "event_venue": event.venue or "Unknown Venue",
            "event_guests": event.expected_attendees,
            "assigned_bid": assigned_bid,
            "top_bids": top_bids
        }

    def get_event_details(self, event_id: int):
        from app.models.event_m import Event
        
        event = (
            self.db.query(Event)
            .options(joinedload(Event.bids).joinedload(VendorBid.vendor))
            .filter(Event.id == event_id)
            .first()
        )
        
        if not event:
            raise HTTPException(status_code=404, detail="Event not found")
            
        bids = event.bids
        now = datetime.utcnow()
        
        if not bids:
            total_bids = 0
            lowest_bid = 0.0
            highest_bid = 0.0
            average_bid = 0.0
            assigned_vendor = None
        else:
            amounts = [b.amount for b in bids]
            total_bids = len(bids)
            lowest_bid = min(amounts)
            highest_bid = max(amounts)
            average_bid = sum(amounts) / total_bids
            
            accepted_bid = next((b for b in bids if b.status == 'accepted'), None)
            assigned_vendor = None
            if accepted_bid:
                assigned_vendor = {
                    "id": accepted_bid.vendor.id,
                    "name": accepted_bid.vendor.company_name,
                    "amount": accepted_bid.amount,
                    "rating": getattr(accepted_bid.vendor, 'rating', 4.5)
                }

        # Calculate time left
        if event.event_date > now:
            delta = event.event_date - now
            time_left = f"{delta.days} days left"
        else:
            time_left = "Event Passed"
            
        return {
            "id": event.id,
            "event_name": event.name,
            "event_date": event.event_date,
            "event_type": event.event_type.name if event.event_type else "Unknown",
            "status": "Awarded" if assigned_vendor else ("Active" if event.event_date > now else "Closed"),
            "categories": [event.category.name] if event.category else [], # Simplified
            "location": event.location or event.city or "Unknown",
            "description": event.description,
            "total_bids": total_bids,
            "lowest_bid": lowest_bid,
            "average_bid": average_bid,
            "highest_bid": highest_bid,
            "time_left": time_left,
            "assigned_vendor": assigned_vendor,
            "payment_status": "Pending", # Mock
            
            # Detail specific
            "venue": event.venue or event.location,
            "expected_guests": event.expected_attendees,
            "duration": "1 Day" # Mock
        }

    def get_event_bids(self, event_id: int):
        from sqlalchemy.orm import joinedload
        from app.models.event_m import Event
        
        # Verify event exists
        event = self.db.query(Event).get(event_id)
        if not event:
             raise HTTPException(status_code=404, detail="Event not found")
             
        bids = (
            self.db.query(VendorBid)
            .join(Vendor, Vendor.id == VendorBid.vendor_id)
            .outerjoin(User, User.id == Vendor.user_id)
            .options(joinedload(VendorBid.vendor).joinedload(Vendor.user))
            .filter(VendorBid.event_id == event_id)
            .all()
        )
        
        mapped_bids = []
        for b in bids:
            v = b.vendor
            docs = getattr(v, "documents", [])
            certs = getattr(v, "certifications", [])
            specs = getattr(v, "specializations", [])
            
            # Helper to extract category name safely
            category_name = "General"
            if v.categories_link:
                 # Assuming categories_link is a list of VC link objects which have 'category' relationship
                 # or if it's many-to-many direct relation depending on model. 
                 # Let's check vendor_m.py previously viewed.
                 # It has `categories_link = relationship("VendorCategoryLink", ...)`
                 # So we need to access `categories_link[0].category.name`
                 if len(v.categories_link) > 0 and v.categories_link[0].category:
                      category_name = v.categories_link[0].category.name
            
            mapped_bids.append({
                "id": b.id,
                "vendor_name": v.company_name,
                "vendor_rating": v.rating if hasattr(v, "rating") else 4.8,
                "vendor_category": category_name,
                "vendor_experience": v.year_established,
                "completed_events": len(v.bids) if v.bids else 100,
                
                "vendor_phone": v.phone,
                "vendor_email": v.user.email if v.user else "N/A",
                "vendor_location": f"{v.city or ''}, {v.state or ''}".strip(", "),
                "vendor_team_size": v.team_size,
                "vendor_notes": v.description,
                "vendor_documents": docs if docs else ['Proposal.pdf'],
                "vendor_certifications": certs if certs else ['Verified'],
                "vendor_specializations": specs if specs else ['General'],

                "amount": b.amount,
                "status": b.status,
                "is_recommended": getattr(v, "rating", 0) >= 4.7, # Simple recommendation logic
                "proposal": b.notes,
                "includes": getattr(b, "includes", []),
                "requirements": getattr(b, "requirements", []),
                "advantages": getattr(b, "advantages", []),
                "timeline_days": getattr(b, "timeline_days", 30),
                "proposed_date": getattr(b, "proposed_date", None),
                "submitted_at": b.submitted_at, 
                "event_id": event.id,
                "event_name": event.name,
                "event_venue": getattr(event, "venue", "Unknown Venue"),
                "event_location": getattr(event, "location", "Unknown Location"),
                "event_guests": getattr(event, "expected_attendees", 0),
                "event_date": event.event_date,
            })
            
        return mapped_bids

    def get_bid(self, bid_id: int):
        from sqlalchemy.orm import joinedload
        from app.models.user_m import User
        # ... (rest of get_bid implementation, need to ensure vendor_category is also populated there)
        # For now I will overwrite up to start of get_bid and manually update get_bid in next step if needed
        # Actually I can replace get_bid start to update it too if I'm clever.
        # But this edit is getting large. Let's stick to adding get_event_bids and then update get_bid.
        # Wait, the instruction says "Add get_event_bids". I'll just insert it before get_bid.
        pass # Placeholder for replace logic alignment

        from sqlalchemy.orm import joinedload
        from app.models.user_m import User
        
        result = (
            self.db.query(VendorBid, Vendor, Event)
            .join(Vendor, Vendor.id == VendorBid.vendor_id)
            .outerjoin(Event, Event.id == VendorBid.event_id)
            .outerjoin(User, User.id == Vendor.user_id) # Join user for email
            .options(joinedload(VendorBid.vendor).joinedload(Vendor.user))
            .filter(VendorBid.id == bid_id)
            .first()
        )

        if not result:
            raise HTTPException(status_code=404, detail="Bid not found")

        bid, vendor, event = result
        
        # Mock additional data for now if not in DB
        documents = getattr(vendor, "documents", [])
        certifications = getattr(vendor, "certifications", [])
        specializations = getattr(vendor, "specializations", [])

        return {
            "id": bid.id,
            "vendor_name": vendor.company_name,
            "vendor_rating": vendor.rating if hasattr(vendor, "rating") else 4.8, # Mock rating if missing
            "vendor_experience": vendor.year_established,
            "completed_events": len(vendor.bids) if vendor.bids else 250, # Mock completed
            
            "vendor_phone": vendor.phone,
            "vendor_email": vendor.user.email if vendor.user else "N/A",
            "vendor_location": f"{vendor.city or ''}, {vendor.state or ''}".strip(", "),
            "vendor_team_size": vendor.team_size,
            "vendor_notes": vendor.description,
            "vendor_documents": documents if documents else ['Proposal.pdf', 'Profile.pdf'],
            "vendor_certifications": certifications if certifications else ['Certified'],
            "vendor_specializations": specializations if specializations else ['Events'],

            "amount": bid.amount,
            "status": bid.status,
            "proposal": bid.notes,
            "includes": getattr(bid, "includes", []),
            "requirements": getattr(bid, "requirements", []),
            "advantages": getattr(bid, "advantages", []),
            "timeline_days": getattr(bid, "timeline_days", None),
            "proposed_date": getattr(bid, "proposed_date", None),
            "submitted_at": bid.submitted_at,
            
            "event_id": event.id if event else None,
            "event_name": event.name if event else None,
            "event_venue": getattr(event, "venue_name", "Unknown Venue"), # Assume event has venue
            "event_location": getattr(event, "location", "Unknown Location"),
            "event_guests": getattr(event, "expected_guests", 0),
            "event_date": event.event_date if event else None,
        }

    def approve_bid(self, bid_id: int, notes: Optional[str], modified_by: str):
        bid = self.db.query(VendorBid).filter(VendorBid.id == bid_id).first()
        if not bid:
            raise HTTPException(status_code=404, detail="Bid not found")

        # Basic financial parameters
        commission_rate = 0.15 # 15%
        gst_rate = 0.18 # 18% on commission
        gateway_rate = 0.02 # 2%

        # Calculations
        base_amount = bid.amount
        commission = base_amount * commission_rate
        gst = commission * gst_rate
        gateway = base_amount * gateway_rate
        insurance = 0.0 # Standard for now

        final_price = base_amount + commission + gst + gateway + insurance

        # Update bid fields
        bid.status = "accepted"
        bid.accepted_at = func.now()
        bid.platform_commission = commission
        bid.gst_on_commission = gst
        bid.gateway_fee = gateway
        bid.final_price = final_price
        
        if notes:
            bid.notes = notes
        
        self.db.commit()
        return True

    def reject_bid(self, bid_id: int, notes: Optional[str], modified_by: str):
        bid = self.db.query(VendorBid).filter(VendorBid.id == bid_id).first()
        if not bid:
            raise HTTPException(status_code=404, detail="Bid not found")

        bid.status = "rejected"
        if notes:
            bid.notes = notes

        self.db.commit()
        return True

    def push_bids_to_customer(self, event_id: int, bid_ids: List[int]):
        # Reset all bids for this event to is_pushed = 0 first if we want only latest push 
        # (or just add new ones)
        # For simplicity, let's just mark the provided ones as pushed.
        
        bids = self.db.query(VendorBid).filter(
            VendorBid.event_id == event_id,
            VendorBid.id.in_(bid_ids)
        ).all()
        
        if not bids:
            raise HTTPException(status_code=404, detail="No matching bids found to push")
            
        for bid in bids:
            bid.is_pushed = 1
        
        # Notify Customer
        event = self.db.query(Event).filter(Event.id == event_id).first()
        if event and event.created_by_user_id: # Assuming we track this or link to booking
             from app.services.notification_service import NotificationService
             notif_service = NotificationService(self.db)
             notif_service.notify_customer_of_curated_bids(
                 event_id=event_id,
                 customer_user_id=event.created_by_user_id,
                 event_name=event.name
             )


        self.db.commit()
        self.db.commit()
        return True
    
    def update_bid_pricing(self, bid_id: int, final_price: float, commission: float = None, notes: str = None):
        bid = self.db.query(VendorBid).filter(VendorBid.id == bid_id).first()
        if not bid:
            raise HTTPException(status_code=404, detail="Bid not found")
            
        bid.final_price = final_price
        if commission is not None:
            bid.platform_commission = commission
        else:
             # Auto calc commission as diff
             bid.platform_commission = final_price - bid.amount
             
        if notes:
            bid.notes = notes
            
        self.db.commit()
        return bid

    def finalize_customer_selection(self, bid_id: int):
        """
        After customer selects a bid, admin finalizes it and sends full event details to the vendor.
        """
        bid = self.db.query(VendorBid).filter(VendorBid.id == bid_id).first()
        if not bid:
            raise HTTPException(status_code=404, detail="Bid not found")
        
        # Get event details
        event = self.db.query(Event).filter(Event.id == bid.event_id).first()
        if not event:
            raise HTTPException(status_code=404, detail="Event not found")
        
        # Mark bid as won
        bid.status = "won"
        
        # Update event to mark as assigned
        event.status = EventStatus.CONFIRMED
        
        # Get vendor info
        vendor = self.db.query(Vendor).filter(Vendor.id == bid.vendor_id).first()
        
        # Notify vendor with full event details
        if vendor:
            from app.services.notification_service import NotificationService
            notif_service = NotificationService(self.db)
            notif_service.notify_vendor_of_event_assignment(
                vendor_id=vendor.id,
                event_id=event.id,
                event_name=event.name,
                event_date=event.event_date,
                event_location=event.location or event.city,
                venue=event.venue
            )
        
        self.db.commit()
        return True
