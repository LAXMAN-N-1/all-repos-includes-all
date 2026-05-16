from app.db.session import SessionLocal
from app.models.promotion import Promotion
from datetime import datetime, timedelta

def seed_promos():
    db = SessionLocal()
    try:
        # Check if WELCOME20 exists
        promo1 = db.query(Promotion).filter(Promotion.code == "WELCOME20").first()
        if not promo1:
            promo1 = Promotion(
                name="Welcome Offer",
                code="WELCOME20",
                description="20% off on first order",
                discount_type="percentage",
                discount_value=20.0,
                is_active=True,
                start_date=datetime.utcnow(),
                end_date=datetime.utcnow() + timedelta(days=365),
                usage_limit=1000
            )
            db.add(promo1)
            print("Added WELCOME20")

        # Check if FLAT50 exists
        promo2 = db.query(Promotion).filter(Promotion.code == "FLAT50").first()
        if not promo2:
            promo2 = Promotion(
                name="Flat Discount",
                code="FLAT50",
                description="Flat $50 off",
                discount_type="fixed",
                discount_value=50.0,
                is_active=True,
                start_date=datetime.utcnow(),
                end_date=datetime.utcnow() + timedelta(days=365),
                usage_limit=1000
            )
            db.add(promo2)
            print("Added FLAT50")

        db.commit()
    except Exception as e:
        print(f"Error seeding promos: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_promos()
