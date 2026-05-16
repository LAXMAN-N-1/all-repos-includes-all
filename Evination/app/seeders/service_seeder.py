from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.service_m import Service


def seed_services():
    """Seed default services matching frontend"""
    db = SessionLocal()

    try:
        # Prevent reseeding
        if db.query(Service).first():
            print("✓ Services already seeded!")
            return

        print("🚀 Starting Services seeding...")

        services_data = [
            {
                "name": "Food & Catering",
                "code": "catering",
                "description": "Professional catering services including meals, beverages, and service staff",
                "icon": "🍽️",
                "base_price": 500.00,
                "price_unit": "per person",
                "is_active": True
            },
            {
                "name": "Decoration & Styling",
                "code": "decoration",
                "description": "Event decoration, theme setup, and venue styling services",
                "icon": "🎨",
                "base_price": 50000.00,
                "price_unit": "fixed",
                "is_active": True
            },
            {
                "name": "Photography & Video",
                "code": "photography",
                "description": "Professional photo and video coverage with editing",
                "icon": "📸",
                "base_price": 25000.00,
                "price_unit": "per event",
                "is_active": True
            },
            {
                "name": "Venue Booking",
                "code": "venue",
                "description": "Venue selection, booking, and management services",
                "icon": "🏛️",
                "base_price": 100000.00,
                "price_unit": "per day",
                "is_active": True
            },
            {
                "name": "Music & DJ",
                "code": "music",
                "description": "Entertainment services including DJ, live bands, and sound systems",
                "icon": "🎵",
                "base_price": 15000.00,
                "price_unit": "per event",
                "is_active": True
            },
            {
                "name": "Guest Transport",
                "code": "transport",
                "description": "Transportation arrangement for guests",
                "icon": "🚗",
                "base_price": 5000.00,
                "price_unit": "per vehicle",
                "is_active": True
            }
        ]

        for idx, service_data in enumerate(services_data, start=1):
            service = Service(**service_data, created_by="system")
            db.add(service)
            print(f"  ✓ [{idx}] {service_data['name']} ({service_data['code']})")

        db.commit()
        print(f"✅ {len(services_data)} services seeded successfully!\n")

    except Exception as e:
        db.rollback()
        print(f"❌ Error seeding services: {e}")
        raise

    finally:
        db.close()


if __name__ == "__main__":
    seed_services()
