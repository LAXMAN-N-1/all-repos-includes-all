from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import Category, EventType


def seed_categories_and_event_types():
    db = SessionLocal()

    try:
        # Prevent reseeding
        if db.query(Category).first():
            print("Categories already seeded!")
            return

        print("🚀 Starting Categories and EventTypes seeding...")

        # ============================
        # Categories
        # ============================
        categories_data = [
            {
                "name": "Weddings",
                "code": "WEDDING",
                "description": "Wedding ceremonies, receptions, and related events",
                "icon": "💍",
                "color": "pink"
            },
            {
                "name": "Corporate Events",
                "code": "CORPORATE",
                "description": "Business meetings, conferences, team building, and corporate gatherings",
                "icon": "💼",
                "color": "blue"
            },
            {
                "name": "Social Events",
                "code": "SOCIAL",
                "description": "Birthday parties, anniversaries, family gatherings, and celebrations",
                "icon": "🎉",
                "color": "orange"
            },
            {
                "name": "Conferences & Seminars",
                "code": "CONFERENCE",
                "description": "Professional conferences, seminars, workshops, and educational events",
                "icon": "🎓",
                "color": "indigo"
            },
            {
                "name": "Entertainment & Shows",
                "code": "ENTERTAINMENT",
                "description": "Concerts, theater performances, exhibitions, and entertainment events",
                "icon": "🎭",
                "color": "purple"
            },
            {
                "name": "Sports Events",
                "code": "SPORTS",
                "description": "Sports tournaments, competitions, marathons, and athletic events",
                "icon": "⚽",
                "color": "green"
            },
            {
                "name": "Charity & Fundraising",
                "code": "CHARITY",
                "description": "Charity galas, fundraising events, and nonprofit gatherings",
                "icon": "❤️",
                "color": "red"
            }
        ]

        categories = {}
        for cat_data in categories_data:
            category = Category(**cat_data)
            db.add(category)
            db.flush()
            categories[cat_data["code"]] = category
            print(f"✅ Created category: {cat_data['name']}")

        # ============================
        # Event Types
        # ============================
        event_types_data = [
            # Wedding Event Types
            {"category": "WEDDING", "name": "Traditional Wedding", "code": "WEDDING_TRADITIONAL", "color": "rose"},
            {"category": "WEDDING", "name": "Destination Wedding", "code": "WEDDING_DESTINATION", "color": "pink"},
            {"category": "WEDDING", "name": "Intimate Wedding", "code": "WEDDING_INTIMATE", "color": "purple"},
            {"category": "WEDDING", "name": "Reception Only", "code": "WEDDING_RECEPTION", "color": "fuchsia"},
            
            # Corporate Event Types
            {"category": "CORPORATE", "name": "In-Person Conference", "code": "CORP_INPERSON", "color": "blue"},
            {"category": "CORPORATE", "name": "Virtual Conference", "code": "CORP_VIRTUAL", "color": "cyan"},
            {"category": "CORPORATE", "name": "Hybrid Event", "code": "CORP_HYBRID", "color": "indigo"},
            {"category": "CORPORATE", "name": "Team Building", "code": "CORP_TEAMBUILDING", "color": "sky"},
            {"category": "CORPORATE", "name": "Product Launch", "code": "CORP_LAUNCH", "color": "teal"},
            
            # Social Event Types
            {"category": "SOCIAL", "name": "Birthday Party", "code": "SOCIAL_BIRTHDAY", "color": "yellow"},
            {"category": "SOCIAL", "name": "Anniversary", "code": "SOCIAL_ANNIVERSARY", "color": "amber"},
            {"category": "SOCIAL", "name": "Baby Shower", "code": "SOCIAL_BABYSHOWER", "color": "lime"},
            {"category": "SOCIAL", "name": "Graduation Party", "code": "SOCIAL_GRADUATION", "color": "orange"},
            
            # Conference & Seminar Event Types
            {"category": "CONFERENCE", "name": "Academic Conference", "code": "CONF_ACADEMIC", "color": "indigo"},
            {"category": "CONFERENCE", "name": "Business Seminar", "code": "CONF_SEMINAR", "color": "blue"},
            {"category": "CONFERENCE", "name": "Workshop", "code": "CONF_WORKSHOP", "color": "violet"},
            {"category": "CONFERENCE", "name": "Training Session", "code": "CONF_TRAINING", "color": "purple"},
            
            # Entertainment Event Types
            {"category": "ENTERTAINMENT", "name": "Concert", "code": "ENT_CONCERT", "color": "purple"},
            {"category": "ENTERTAINMENT", "name": "Theater Performance", "code": "ENT_THEATER", "color": "fuchsia"},
            {"category": "ENTERTAINMENT", "name": "Art Exhibition", "code": "ENT_EXHIBITION", "color": "pink"},
            {"category": "ENTERTAINMENT", "name": "Film Screening", "code": "ENT_SCREENING", "color": "violet"},
            
            # Sports Event Types
            {"category": "SPORTS", "name": "Tournament", "code": "SPORTS_TOURNAMENT", "color": "green"},
            {"category": "SPORTS", "name": "Marathon", "code": "SPORTS_MARATHON", "color": "lime"},
            {"category": "SPORTS", "name": "Championship", "code": "SPORTS_CHAMPIONSHIP", "color": "emerald"},
            {"category": "SPORTS", "name": "Sports Festival", "code": "SPORTS_FESTIVAL", "color": "teal"},
            
            # Charity Event Types
            {"category": "CHARITY", "name": "Fundraising Gala", "code": "CHARITY_GALA", "color": "red"},
            {"category": "CHARITY", "name": "Charity Auction", "code": "CHARITY_AUCTION", "color": "rose"},
            {"category": "CHARITY", "name": "Community Drive", "code": "CHARITY_DRIVE", "color": "pink"},
            {"category": "CHARITY", "name": "Awareness Campaign", "code": "CHARITY_AWARENESS", "color": "orange"},
        ]

        for et_data in event_types_data:
            category_code = et_data.pop("category")
            event_type = EventType(
                category_id=categories[category_code].id,
                **et_data
            )
            db.add(event_type)
            print(f"✅ Created event type: {et_data['name']} under {category_code}")

        db.commit()
        print("✅ Categories and EventTypes seeding completed successfully!")

    except Exception as e:
        db.rollback()
        print(f"❌ Error seeding database: {e}")
        raise

    finally:
        db.close()


if __name__ == "__main__":
    seed_categories_and_event_types()