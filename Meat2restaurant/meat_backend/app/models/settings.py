from sqlalchemy import Column, Integer, String, Boolean, Float, Text, DateTime
from app.db.base_class import Base, TimestampMixin

class Configuration(Base, TimestampMixin):
    __tablename__ = "configurations"
    id = Column(Integer, primary_key=True, index=True)
    key = Column(String(255), unique=True, index=True)
    value = Column(String(500))
    description = Column(String(500), nullable=True)

class ShippingMethod(Base, TimestampMixin):
    __tablename__ = "shipping_methods"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)
    description = Column(String(500), nullable=True)
    price = Column(Float, default=0.0)
    is_active = Column(Boolean, default=True)
    estimated_days = Column(Integer, default=3)

class DeliveryZone(Base, TimestampMixin):
    __tablename__ = "delivery_zones"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True) # e.g., "Chicago Metro"
    zip_codes = Column(Text) # Comma separated list of zips
    fee = Column(Float, default=0.0)

class ApiAccessKey(Base, TimestampMixin):
    __tablename__ = "api_access_keys"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), index=True)
    key_prefix = Column(String(20), index=True)
    key_hash = Column(String(255), unique=True)  # Matches actual DB column
    scopes = Column(Text) # Comma separated scopes
    is_active = Column(Boolean, default=True)
    last_used_at = Column(DateTime, nullable=True)
    expires_at = Column(DateTime, nullable=True)
    created_by_user_id = Column(Integer, nullable=True)

class SettingsActivity(Base, TimestampMixin):
    __tablename__ = "settings_activity"
    id = Column(Integer, primary_key=True, index=True)
    section = Column(String(100), index=True)
    event = Column(String(100))
    subject = Column(String(255))
    actor = Column(String(255), nullable=True)
    metadata_json = Column(Text, nullable=True) # JSON stored as string for simplicity in basic SQL
