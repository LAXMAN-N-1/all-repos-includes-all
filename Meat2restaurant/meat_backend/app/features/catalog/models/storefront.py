from sqlalchemy import Column, Integer, String, Boolean, Date, DateTime
from app.db.base_class import Base, TimestampMixin
from datetime import datetime


class ServiceLocation(Base, TimestampMixin):
    __tablename__ = "service_locations"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    address = Column(String(500), nullable=True)
    city = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    zip_code = Column(String(20), nullable=True)
    country = Column(String(100), default="UAE")
    is_active = Column(Boolean, default=True)


class BirthdayClubEntry(Base, TimestampMixin):
    __tablename__ = "birthday_club_entries"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), nullable=False)
    phone = Column(String(50), nullable=True)
    date_of_birth = Column(Date, nullable=True)


class NewsletterSubscription(Base, TimestampMixin):
    __tablename__ = "newsletter_subscriptions"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    subscribed_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)
