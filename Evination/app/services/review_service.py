from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.review_m import Review
from app.models.user_m import User
from app.schemas.review_schema import ReviewCreate

class ReviewService:
    @staticmethod
    def create_review(db: Session, review_data: ReviewCreate, consumer_id: int):
        # Check if review already exists for this booking/vendor? (Optional constraint)
        new_review = Review(
            consumer_id=consumer_id,
            vendor_id=review_data.vendor_id,
            event_id=review_data.event_id,
            rating=review_data.rating,
            comment=review_data.comment,
            created_by=str(consumer_id)
        )
        db.add(new_review)
        db.commit()
        db.refresh(new_review)
        return new_review

    @staticmethod
    def get_vendor_reviews(db: Session, vendor_id: int, skip: int = 0, limit: int = 20):
        reviews = db.query(Review).filter(Review.vendor_id == vendor_id).offset(skip).limit(limit).all()
        # Enrich with consumer name
        result = []
        for r in reviews:
            consumer = db.query(User).filter(User.id == r.consumer_id).first()
            result.append({
                "id": r.id,
                "consumer_name": f"{consumer.first_name} {consumer.last_name}" if consumer else "Anonymous",
                "rating": r.rating,
                "comment": r.comment,
                "created_at": r.created_at
            })
        return result
