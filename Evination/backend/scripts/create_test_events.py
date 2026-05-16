"""Create test events for vendor marketplace testing."""
from app.database import SessionLocal
from app.models.event_m import Event, EventStatus
from app.models.organization_m import Organization
from app.models.category_m import Category
from app.models.event_type_m import EventType
from datetime import datetime, timedelta

def create_test_events():
    db = SessionLocal()
    
    try:
        org = db.query(Organization).first()
        etype = db.query(EventType).first()
        
        if not org or not etype:
            print("❌ Missing organization or event type!")
            return
        
        # Get categories
        catering = db.query(Category).filter(Category.code == "CATERING").first()
        venue = db.query(Category).filter(Category.code == "VENUE").first()
        decor = db.query(Category).filter(Category.code == "DECOR").first()
        
        test_events = [
            {
                "name": "Wedding Reception - Catering Service",
                "category": catering,
                "budget": 150000,
                "description": "Need catering for 200 guests. Full 3-course meal with beverages."
            },
            {
                "name": "Corporate Event - Venue Booking",
                "category": venue,
                "budget": 80000,
                "description": "Looking for a venue for 100 people corporate conference."
            },
            {
                "name": "Birthday Party - Decoration",
                "category": decor,
                "budget": 30000,
                "description": "Balloon decoration and stage setup for birthday celebration."
            }
        ]
        
        for event_data in test_events:
            if event_data["category"]:
                new_event = Event(
                    organization_id=org.id,
                    name=event_data["name"],
                    category_id=event_data["category"].id,
                    event_type_id=etype.id,
                    event_date=datetime.now() + timedelta(days=15),  # 15 days from now
                    location="Mumbai",
                    budget=event_data["budget"],
                    description=event_data["description"],
                    status=EventStatus.ACTIVE
                )
                db.add(new_event)
                print(f"✅ Created: {event_data['name']}")
        
        db.commit()
        print("\n✨ Test events created successfully!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    create_test_events()
