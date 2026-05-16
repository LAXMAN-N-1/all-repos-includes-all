from app.database import SessionLocal
from app.models.vendor_m import Vendor
from app.models.booking_m import Booking
from app.models.event_m import Event

db = SessionLocal()

vendors = db.query(Vendor).all()
print(f'Found {len(vendors)} vendors')
for v in vendors[:3]:
    print(f'  - Vendor ID: {v.id}, User ID: {v.user_id}')

bookings = db.query(Booking).all()
print(f'\nFound {len(bookings)} bookings')
for b in bookings[:5]:
    print(f'  - ID: {b.id}, Name: {b.event_name}, Status: {b.status}')

events = db.query(Event).all()
print(f'\nFound {len(events)} events')
for e in events[-5:]:  # Show last 5
    print(f'  - ID: {e.id}, Name: {e.name}, Status: {e.status}')

db.close()
