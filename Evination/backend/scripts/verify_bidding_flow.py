from app.database import SessionLocal
from app.services.bidding_service import BiddingService
from app.models.user_m import User
from app.models.vendor_m import Vendor
import sys

def verify_flow():
    db = SessionLocal()
    try:
        print("🚀 Starting Bidding System Verification...")
        
        # 0. Setup: Ensure a Vendor Exists linked to a User
        # Find a user to act as Vendor
        vendor_user = db.query(User).filter(User.email.like("%vendor%")).first()
        if not vendor_user:
            print("Creating Mock Vendor User")
            vendor_user = User(email="vendor_bid_test@test.com", username="vendor_bid_test", password_hash="hash", first_name="Vendor", role_id=3) 
            db.add(vendor_user)
            db.commit()
            
        # Ensure Vendor Profile
        vendor = db.query(Vendor).filter(Vendor.user_id == vendor_user.id).first()
        if not vendor:
            vendor = Vendor(user_id=vendor_user.id, company_name="Lucky Events", status="active", city="Hyderabad")
            db.add(vendor)
            db.commit()
            print(f"✓ Created Vendor: {vendor.company_name} (ID: {vendor.id})")
        else:
            print(f"✓ Using Vendor: {vendor.company_name} (ID: {vendor.id})")

        # 1. Customer Creates Request
        print("\n--- Phase 1: Customer Request ---")
        customer_id = 1 # Assuming Super Admin as Customer for test
        bs = BiddingService(db)
        
        req_data = {
            "event_type": "Marriage",
            "sub_category": "Hindu Wedding",
            "event_date": "2026-12-01",
            "city": "Hyderabad",
            "budget": 500000,
            "guest_count": 500
        }
        booking = bs.create_event_request(customer_id, req_data)
        print(f"✓ Created Request: {booking.event_name} (ID: {booking.id})")
        
        # 2. Vendor Submits Bid
        print("\n--- Phase 2: Vendor Bid ---")
        bid_amount = 450000.0
        bid = bs.submit_bid(vendor.id, booking.id, bid_amount, "We provide best service.")
        print(f"✓ Submitted Bid: {bid.amount} (ID: {bid.id})")
        
        # 3. Admin Curates (Shortlists)
        print("\n--- Phase 3: Admin Curation ---")
        # Check initial status
        print(f"   Status before: {bid.status}")
        curated_bid = bs.curate_bid(bid.id, "shortlist")
        print(f"   Status after: {curated_bid.status}")
        print(f"   Final Price: {curated_bid.final_price}")
        print(f"   Commission: {curated_bid.platform_commission}")
        
        if curated_bid.final_price > bid_amount:
            print("✓ Pricing Logic Applied (Price increased with fees)")
        else:
            print("❌ Pricing Logic Failed")
            
        # 4. Customer Selects
        print("\n--- Phase 4: Customer Selection ---")
        selected_bid = bs.select_bid(bid.id)
        print(f"✓ Bid Selected. Status: {selected_bid.status}")
        
        # Verify Booking Updated
        db.refresh(booking)
        print(f"   Booking Vendor ID: {booking.vendor_id}")
        print(f"   Booking Budget (Updated): {booking.budget}")
        
        if booking.vendor_id == vendor.id:
            print("\n✅ SUCCESS: Full Flow Verified!")
        else:
            print("\n❌ FAILURE: Booking not linked to Vendor.")

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    verify_flow()
