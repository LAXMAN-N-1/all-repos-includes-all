from sqlalchemy import Column, String, Integer, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import relationship
from app.models.base_model import BaseModel


class User(BaseModel):
    __tablename__ = "users"

    organization_id = Column(Integer, ForeignKey("organizations.id"), nullable=True)
    branch_id = Column(Integer, ForeignKey("branches.id"), nullable=True)
    department_id = Column(Integer, ForeignKey("departments.id"), nullable=True)
    role_id = Column(Integer, ForeignKey("roles.id"), nullable=False)

    username = Column(String(100), nullable=False, unique=True, index=True)
    email = Column(String(100), nullable=False, unique=True, index=True)
    password_hash = Column(String(255), nullable=False)

    first_name = Column(String(100), nullable=True)
    last_name = Column(String(100), nullable=True)

    phone = Column(String(20), nullable=True)
    avatar_url = Column(String(500), nullable=True)
    last_login_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    organization = relationship("Organization", back_populates="users")
    branch = relationship("Branch", back_populates="users", foreign_keys=[branch_id])
    department = relationship("Department", back_populates="users")
    role = relationship("Role", back_populates="users")

    # Customer specific fields
    location = Column(String(255), nullable=True)
    is_verified = Column(Boolean, default=False)
    # is_active is typically handled by 'inactive' in BaseModel, but Customer app had explicit is_active. 
    # We will map Customer is_active to NOT inactive. 

    vendor_profile = relationship(
        "Vendor",
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan"
    )
    event_manager_profile = relationship(
        "EventManagerProfile",
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan"
    )
    managed_events = relationship(
        "Event",
        back_populates="event_manager",
        foreign_keys="Event.event_manager_id"
    )

    # Customer Relationships
    bookings = relationship("Booking", back_populates="customer")
    # notifications = relationship("Notification", back_populates="user")