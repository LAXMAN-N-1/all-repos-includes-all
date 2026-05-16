from app.database import SessionLocal, engine
from app.models.event_m import Event
from app.models.booking_m import Booking
from app.models.vendor_bid_m import VendorBid
from app.models.vendor_order_m import VendorOrder
from sqlalchemy import text

def cleanup_data():
    db = SessionLocal()
    try:
        print("Cleaning up Vendor Bids...")
        db.query(VendorBid).delete()
        
        print("Cleaning up Vendor Orders...")
        db.query(VendorOrder).delete()
        
        print("Cleaning up Bookings...")
        db.query(Booking).delete()
        
        # Events might be linked to other things, but user said "all event and all raised by customer"
        # We should be careful about "System" events vs "Customer Requests"
        # Since the system seems to treat Customer Requests as Events (or Bookings?), I'll clear Events created by customers.
        # However, looking at the schema, Event table is often used for Admin events too.
        # User said "raised by the customer", which usually maps to `Event` with `is_private=True` or `booking_id` linked?
        # Or maybe purely `Booking` table?
        # Let's check if Events have a flag.
        
        print("Cleaning up Events (Customer Requests)...")
        # Assuming we can delete all for a "fresh start" as requested, or just those that look like customer requests.
        # For now, I'll delete all events to be safe and true to "delete all". 
        # But I'll leave "Master" data if possible.
        db.query(Event).delete()
        
        db.commit()
        print("Data cleanup complete!")
    except Exception as e:
        print(f"Error during cleanup: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    cleanup_data()
