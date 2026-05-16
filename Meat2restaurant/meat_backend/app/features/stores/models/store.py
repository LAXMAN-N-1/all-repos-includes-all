"""
Store Location Master — SQLAlchemy Models
9 tables: stores, timings, special hours, services, delivery zones,
whatsapp config, media, staff, audit log.
"""
from sqlalchemy import (
    Column, Integer, String, Boolean, Float, Text, DateTime, Date, Time,
    ForeignKey
)
from sqlalchemy.orm import relationship
from app.db.base_class import Base, TimestampMixin


class Store(Base, TimestampMixin):
    __tablename__ = "stores"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    store_code = Column(String(50), unique=True, nullable=False, index=True)
    slug = Column(String(255), unique=True, index=True)
    store_type = Column(String(50), default="outlet")  # flagship, outlet, dark_kitchen, pickup_only
    address_line1 = Column(String(500))
    address_line2 = Column(String(500), nullable=True)
    city = Column(String(100), index=True)
    state = Column(String(100))
    zip_code = Column(String(20))
    country = Column(String(100), default="US")
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    google_place_id = Column(String(255), nullable=True)
    display_order = Column(Integer, default=0)
    status = Column(String(30), default="active", index=True)  # active, inactive, coming_soon
    is_deleted = Column(Boolean, default=False, index=True)
    cover_image_url = Column(String(500), nullable=True)

    # Relationships
    timings = relationship("StoreTiming", back_populates="store", cascade="all, delete-orphan")
    special_hours = relationship("StoreSpecialHours", back_populates="store", cascade="all, delete-orphan")
    services = relationship("StoreService", back_populates="store", uselist=False, cascade="all, delete-orphan")
    delivery_zones = relationship("StoreDeliveryZone", back_populates="store", cascade="all, delete-orphan")
    whatsapp_config = relationship("StoreWhatsappConfig", back_populates="store", uselist=False, cascade="all, delete-orphan")
    media = relationship("StoreMedia", back_populates="store", cascade="all, delete-orphan")
    staff = relationship("StoreStaff", back_populates="store", cascade="all, delete-orphan")
    audit_logs = relationship("StoreAuditLog", back_populates="store", cascade="all, delete-orphan")


class StoreTiming(Base, TimestampMixin):
    __tablename__ = "store_timings"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id", ondelete="CASCADE"), nullable=False, index=True)
    day_of_week = Column(Integer, nullable=False)  # 0=Monday .. 6=Sunday
    is_open = Column(Boolean, default=True)
    open_time = Column(Time, nullable=True)
    close_time = Column(Time, nullable=True)

    store = relationship("Store", back_populates="timings")


class StoreSpecialHours(Base, TimestampMixin):
    __tablename__ = "store_special_hours"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id", ondelete="CASCADE"), nullable=False, index=True)
    date = Column(Date, nullable=False)
    label = Column(String(255), nullable=True)  # e.g. "Christmas Day"
    is_closed = Column(Boolean, default=True)
    open_time = Column(Time, nullable=True)
    close_time = Column(Time, nullable=True)

    store = relationship("Store", back_populates="special_hours")


class StoreService(Base, TimestampMixin):
    __tablename__ = "store_services"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    web_orders_enabled = Column(Boolean, default=False)
    app_orders_enabled = Column(Boolean, default=False)
    whatsapp_orders_enabled = Column(Boolean, default=False)
    walkin_enabled = Column(Boolean, default=False)
    home_delivery_enabled = Column(Boolean, default=False)
    pickup_enabled = Column(Boolean, default=False)
    bulk_orders_enabled = Column(Boolean, default=False)
    cod_enabled = Column(Boolean, default=False)
    card_on_delivery_enabled = Column(Boolean, default=False)
    online_payment_enabled = Column(Boolean, default=False)

    store = relationship("Store", back_populates="services")


class StoreDeliveryZone(Base, TimestampMixin):
    __tablename__ = "store_delivery_zones"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id", ondelete="CASCADE"), nullable=False, index=True)
    zone_name = Column(String(255), nullable=False)
    polygon_geojson = Column(Text, nullable=True)  # GeoJSON coordinate array
    delivery_fee = Column(Float, default=0.0)
    min_order = Column(Float, default=0.0)
    estimated_time_minutes = Column(Integer, default=45)
    priority = Column(Integer, default=0)

    store = relationship("Store", back_populates="delivery_zones")


class StoreWhatsappConfig(Base, TimestampMixin):
    __tablename__ = "store_whatsapp_configs"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    whatsapp_phone = Column(String(30), nullable=True)
    business_account_id = Column(String(255), nullable=True)
    greeting_template = Column(Text, nullable=True)
    default_language = Column(String(10), default="en")
    keyword_triggers = Column(Text, nullable=True)  # JSON array stored as text, e.g. '["dallas","tx branch"]'

    store = relationship("Store", back_populates="whatsapp_config")


class StoreMedia(Base, TimestampMixin):
    __tablename__ = "store_medias"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id", ondelete="CASCADE"), nullable=False, index=True)
    media_url = Column(String(500), nullable=False)
    media_type = Column(String(30), default="image")  # image, video
    display_order = Column(Integer, default=0)
    is_cover = Column(Boolean, default=False)

    store = relationship("Store", back_populates="media")


class StoreStaff(Base, TimestampMixin):
    __tablename__ = "store_staffs"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    role = Column(String(100), nullable=True)
    phone = Column(String(30), nullable=True)

    store = relationship("Store", back_populates="staff")


class StoreAuditLog(Base, TimestampMixin):
    __tablename__ = "store_audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id", ondelete="CASCADE"), nullable=False, index=True)
    admin_user_id = Column(Integer, nullable=True)
    action = Column(String(50), nullable=False)  # create, update, delete, status_change
    changes_json = Column(Text, nullable=True)  # JSON diff of what changed

    store = relationship("Store", back_populates="audit_logs")
