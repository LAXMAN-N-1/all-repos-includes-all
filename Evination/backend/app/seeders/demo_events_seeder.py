from app.database import SessionLocal
from app.models import Event, Category, EventType, Organization, Branch, User
from app.models.event_m import EventStatus
from datetime import datetime, timedelta
import random

def seed_demo_events():
    db = SessionLocal()
    try:
        # Get necessary foreign keys
        org = db.query(Organization).first()
        branch = db.query(Branch).first()
        admin = db.query(User).filter(User.username == "superadmin").first()
        
        if not org or not branch:
            print("❌ Organization or Branch not found. Please run seed_database first.")
            return

        categories = db.query(Category).all()
        event_types = db.query(EventType).all()

        if not categories or not event_types:
            print("❌ Categories or EventTypes not found. Please run category_event_type_seeder first.")
            return

        print("🚀 Seeding demo events (leads)...")

        events_to_create = [
            {
                "name": "Grand Corporate Annual Gala",
                "category_code": "CORPORATE",
                "type_code": "CORP_LAUNCH",
                "location": "Convention Center, Downtown",
                "city": "Hyderabad",
                "attendees": 500,
                "budget": 2500000.00,
                "days_away": 60
            },
            {
                "name": "Traditional Wedding Ceremony",
                "category_code": "WEDDING",
                "type_code": "WEDDING_TRADITIONAL",
                "location": "Lotus Gardens",
                "city": "Bangalore",
                "attendees": 1000,
                "budget": 5000000.00,
                "days_away": 120
            },
            {
                "name": "Tech Product Launch 2026",
                "category_code": "CORPORATE",
                "type_code": "CORP_LAUNCH",
                "location": "Tech Hub Auditorium",
                "city": "Hyderabad",
                "attendees": 300,
                "budget": 1500000.00,
                "days_away": 45
            },
            {
                "name": "Luxury Birthday Celebration",
                "category_code": "SOCIAL",
                "type_code": "SOCIAL_BIRTHDAY",
                "location": "Sky Deck Lounge",
                "city": "Mumbai",
                "attendees": 150,
                "budget": 800000.00,
                "days_away": 15
            },
            {
                "name": "Regional Sports Championship",
                "category_code": "SPORTS",
                "type_code": "SPORTS_CHAMPIONSHIP",
                "location": "National Stadium",
                "city": "Delhi",
                "attendees": 2000,
                "budget": 3500000.00,
                "days_away": 90
            }
        ]

        for data in events_to_create:
            # Match category and type
            category = next((c for c in categories if c.code == data["category_code"]), categories[0])
            event_type = next((t for t in event_types if t.code == data["type_code"]), event_types[0])

            event = Event(
                organization_id=org.id,
                name=data["name"],
                category_id=category.id,
                event_type_id=event_type.id,
                event_date=datetime.utcnow() + timedelta(days=data["days_away"]),
                location=data["location"],
                city=data["city"],
                venue=data["location"],
                expected_attendees=data["attendees"],
                budget=data["budget"],
                description=f"Automated lead for {data['name']}. Requires full management and catering.",
                status=EventStatus.ACTIVE, # Active so vendors can see it
                created_by="system"
            )
            db.add(event)
        
        db.commit()
        print(f"✅ Created {len(events_to_create)} demo events.")

    except Exception as e:
        print(f"❌ Error seeding events: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_demo_events()
