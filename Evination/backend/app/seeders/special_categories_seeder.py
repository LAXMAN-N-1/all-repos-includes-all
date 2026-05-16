from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import Category

def add_specialized_categories():
    db = SessionLocal()
    try:
        special_categories = [
            {
                "name": "Food & Catering",
                "code": "CATERING",
                "description": "Catering services, food stalls, and dining management.",
                "icon": "🍽️",
                "color": "orange"
            },
            {
                "name": "Venue Booking",
                "code": "VENUE",
                "description": "Booking of hotels, banquet halls, and outdoor venues.",
                "icon": "🏨",
                "color": "blue"
            },
            {
                "name": "Decoration & Styling",
                "code": "DECOR",
                "description": "Floral, lighting, and theme-based decorations.",
                "icon": "✨",
                "color": "pink"
            }
        ]

        for cat_data in special_categories:
            existing = db.query(Category).filter(Category.code == cat_data["code"]).first()
            if not existing:
                category = Category(**cat_data)
                db.add(category)
                print(f"✅ Created category: {cat_data['name']}")
            else:
                print(f"⚠️ Category {cat_data['name']} already exists.")

        db.commit()
    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    add_specialized_categories()
