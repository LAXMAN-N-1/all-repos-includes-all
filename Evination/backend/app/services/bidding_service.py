from sqlalchemy.orm import Session
from app.models.booking_m import Booking, BookingStatus
from app.models.vendor_bid_m import VendorBid
from app.models.service_request_m import ServiceRequest
from app.models.vendor_m import Vendor, VendorCategory
from app.models.user_m import User
from app.services.notification_service import NotificationService
from app.services.finance_service import FinanceService
from datetime import datetime
import json

class BiddingService:
    def __init__(self, db: Session):
        self.db = db
        self.notifier = NotificationService(db)

    # ----------------------------
    # PHASE 1: CUSTOMER REQUEST
    # ----------------------------
    def create_event_request(self, customer_id: int, data: dict):
        """
        Creates a Booking (Request) and ServiceRequests. 
        Triggers Vendor Matching.
        """
        # 1. Create Booking
        new_booking = Booking(
            reference_id=f"EVT-{int(datetime.now().timestamp())}",
            customer_id=customer_id,
            event_name=data.get('event_type') + " Request",
            event_type=data.get('event_type'),
            sub_category=data.get('sub_category'),
            event_date=data.get('event_date'), 
            city=data.get('city'),
            location=data.get('location'),
            guest_count=str(data.get('guest_count')),
            budget=float(data.get('budget', 0)),
            requirements=data.get('requirements'),
            status=BookingStatus.awaiting_vendors, # Custom status concept, mapping to 'awaiting_vendors'
            images=data.get('images')
        )
        self.db.add(new_booking)
        self.db.commit()
        self.db.refresh(new_booking)
        
        # 2. Find Matching Vendors & Notify
        self._notify_matching_vendors(new_booking)
        
        return new_booking

    def _notify_matching_vendors(self, booking: Booking):
        # Simplified Matching: Same City + Category (if we had category mapping)
        # For now matches all status='active' vendors in same city
        vendors = self.db.query(Vendor).join(User).filter(
            # Vendor.city == booking.city, # weak match, maybe just active for demo
            Vendor.status == 'active' 
        ).all()
        
        count = 0
        for vendor in vendors:
            # Send Notification
            self.notifier.send_notification(
                "VENDOR", vendor.id,
                "New Lead Available",
                f"New {booking.event_type} event in {booking.city}. Budget: {booking.budget}",
                "BOOKING", str(booking.id)
            )
            count += 1
        print(f"Notified {count} vendors for Booking {booking.id}")

    # ----------------------------
    # PHASE 2: VENDOR BIDDING
    # ----------------------------
    def submit_bid(self, vendor_id: int, booking_id: int, amount: float, proposal: str):
        booking = self.db.query(Booking).filter(Booking.id == booking_id).first()
        if not booking:
            raise Exception("Booking not found")

        bid = VendorBid(
            vendor_id=vendor_id,
            # We treat Booking as 'ServiceRequest' logic or add booking_id to Bid in future?
            # Current VendorBid links to ServiceRequest or Event. 
            # Let's assume we link via 'event_id' (Admin Event) or 'service_request_id'. 
            # Ideally VendorBid should link to Booking. 
            # ADAPTATION: We'll misuse 'service_request_id' to store Booking ID or add booking_id to VendorBid?
            # Schema didn't add booking_id to VendorBid. 
            # Let's use 'notes' to store "Booking:{id}" or create a ServiceRequest wrapper.
            # CORRECT WAY: Create a ServiceRequest for this Booking.
            amount=amount,
            proposal=proposal,
            status="submitted",
            submitted_at=datetime.now()
        )
        
        # Link to Booking via ServiceRequest (Create one if missing)
        # Check if booking has service request
        sr = self.db.query(ServiceRequest).filter(ServiceRequest.booking_id == booking.id).first()
        if not sr:
            sr = ServiceRequest(booking_id=booking.id, service_name="Main Event", status="pending")
            self.db.add(sr)
            self.db.commit()
            self.db.refresh(sr)
        
        bid.service_request_id = sr.id
        self.db.add(bid)
        self.db.commit()
        
        # Notify Admin
        # Assuming Admin ID 1
        self.notifier.send_notification(
            "ADMIN", 1, "New Bid Received",
            f"Vendor {vendor_id} bid {amount} for Booking {booking.reference_id}",
            "BID", str(bid.id)
        )
        return bid

    # ----------------------------
    # PHASE 3: ADMIN CURATION
    # ----------------------------
    def curate_bid(self, bid_id: int, action: str):
        """
        action: 'shortlist' | 'reject'
        If shortlist, calculates final price.
        """
        bid = self.db.query(VendorBid).filter(VendorBid.id == bid_id).first()
        if not bid: 
            raise Exception("Bid not found")
            
        if action == 'reject':
            bid.status = 'rejected'
            self.db.commit()
            self.notifier.send_notification("VENDOR", bid.vendor_id, "Bid Rejected", "Your bid was not shortlisted.")
            return bid
            
        if action == 'shortlist':
            # Calculate Fees
            fees = FinanceService.calculate_platform_fees(bid.amount, self.db)
            
            bid.platform_commission = fees['commission']
            bid.gst_on_commission = fees['gst_on_commission']
            bid.gateway_fee = fees['gateway_fee']
            bid.final_price = fees['final_price']
            bid.status = 'shortlisted'
            
            self.db.commit()
            
            # Notify Customer? Not yet, maybe after Batch Send?
            # Or per flow, Admin sends to customer.
            bid.status = 'sent_to_customer'
            self.db.commit()
            
            # Get Booking Customer
            sr = self.db.query(ServiceRequest).filter(ServiceRequest.id == bid.service_request_id).first()
            booking = sr.booking
            
            self.notifier.send_notification(
                "USER", booking.customer_id,
                "New Quotation Received",
                f"You have a new quote for {fees['final_price']}",
                "BOOKING", str(booking.id)
            )
            return bid

    # ----------------------------
    # PHASE 4: CUSTOMER SELECTION
    # ----------------------------
    def select_bid(self, bid_id: int):
        bid = self.db.query(VendorBid).filter(VendorBid.id == bid_id).first()
        bid.status = 'selected'
        bid.accepted_at = datetime.now()
        
        sr = self.db.query(ServiceRequest).filter(ServiceRequest.id == bid.service_request_id).first()
        booking = sr.booking
        
        # Update Booking
        booking.status = BookingStatus.awaiting_payment # Or confirmed if no pay?
        booking.vendor_id = bid.vendor_id
        booking.budget = bid.final_price # Update budget to actual cost
        
        self.db.commit()
        
        # Notify Vendor & Admin
        self.notifier.send_notification("VENDOR", bid.vendor_id, "Bid Accepted!", "Customer selected your bid. Wait for payment.")
        self.notifier.send_notification("ADMIN", 1, "Bid Selected", f"Booking {booking.reference_id} matched.")
        
        return bid
