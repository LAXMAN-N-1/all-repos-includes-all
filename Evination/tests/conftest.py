"""
Pytest Configuration and Fixtures
==================================
Shared fixtures for all integration tests including:
- Test database setup/teardown
- FastAPI TestClient
- Authentication helpers
- Test data factories
"""

import os
import pytest
from typing import Generator, Dict, Any
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool

# Load test environment before importing app modules
os.environ["DATABASE_URL"] = os.getenv(
    "TEST_DATABASE_URL", 
    "mysql+pymysql://root:ravi%401234@localhost:3306/evination_test"
)
os.environ["SECRET_KEY"] = "test-secret-key-for-testing-only"

from app.database import Base, get_db
from app.main import app
from app.models.user_m import User
from app.models.role_m import Role
from app.models.organization_m import Organization
from app.models.vendor_m import Vendor
from app.utils.password_utils import hash_password
from app.utils.jwt_utils import create_access_token
from datetime import timedelta


# =============================================================================
# DATABASE CONFIGURATION
# =============================================================================

TEST_DATABASE_URL = os.getenv(
    "TEST_DATABASE_URL", 
    "mysql+pymysql://root:ravi%401234@localhost:3306/evination_test"
)

engine = create_engine(
    TEST_DATABASE_URL,
    pool_pre_ping=True,
    echo=False
)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# =============================================================================
# DATABASE FIXTURES
# =============================================================================

@pytest.fixture(scope="function")
def db() -> Generator[Session, None, None]:
    """
    Creates a fresh database for each test function.
    Tables are created before the test and dropped after.
    """
    # Create all tables
    Base.metadata.create_all(bind=engine)
    
    # Create session
    session = TestingSessionLocal()
    
    try:
        yield session
    finally:
        session.close()
        # Drop all tables after test
        Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def client(db: Session) -> Generator[TestClient, None, None]:
    """
    FastAPI TestClient with database dependency override.
    Uses the test database session.
    """
    def override_get_db():
        try:
            yield db
        finally:
            pass
    
    # Override the database dependency
    app.dependency_overrides[get_db] = override_get_db
    
    # raise_server_exceptions=True to see actual errors during debugging
    with TestClient(app, raise_server_exceptions=True) as test_client:
        yield test_client
    
    # Clear overrides after test
    app.dependency_overrides.clear()


# =============================================================================
# SEED DATA FIXTURES
# =============================================================================

@pytest.fixture
def seed_role(db: Session) -> Role:
    """Get or create a basic admin role for testing"""
    role = db.query(Role).filter(Role.code == "ADMIN").first()
    if role:
        return role
    role = Role(
        name="Test Admin",
        code="ADMIN",
        description="Test admin role",
        inactive=False
    )
    db.add(role)
    db.commit()
    db.refresh(role)
    return role


@pytest.fixture
def seed_superadmin_role(db: Session) -> Role:
    """Get or create a superadmin role for testing"""
    role = db.query(Role).filter(Role.code == "SUPERADMIN").first()
    if role:
        return role
    role = Role(
        name="Super Admin",
        code="SUPERADMIN",
        description="Super admin role with all permissions",
        inactive=False
    )
    db.add(role)
    db.commit()
    db.refresh(role)
    return role


@pytest.fixture
def seed_vendor_role(db: Session) -> Role:
    """Get or create a vendor role for testing"""
    role = db.query(Role).filter(Role.code == "VENDOR").first()
    if role:
        return role
    role = Role(
        name="Vendor",
        code="VENDOR",
        description="Vendor role",
        inactive=False
    )
    db.add(role)
    db.commit()
    db.refresh(role)
    return role


@pytest.fixture
def seed_consumer_role(db: Session) -> Role:
    """Get or create a consumer role for testing"""
    role = db.query(Role).filter(Role.code == "CONSUMER").first()
    if role:
        return role
    role = Role(
        name="Consumer",
        code="CONSUMER",
        description="Consumer role",
        inactive=False
    )
    db.add(role)
    db.commit()
    db.refresh(role)
    return role


@pytest.fixture
def seed_organization(db: Session) -> Organization:
    """Create a test organization"""
    org = Organization(
        name="Test Organization",
        code="TESTORG",
        address="123 Test Street",
        city="Test City",
        state="Test State",
        country="Test Country",
        pincode="12345",
        inactive=False
    )
    db.add(org)
    db.commit()
    db.refresh(org)
    return org


# =============================================================================
# USER FIXTURES
# =============================================================================

@pytest.fixture
def admin_user(db: Session, seed_superadmin_role: Role, seed_organization: Organization) -> User:
    """Create an admin user for testing with organization"""
    user = User(
        username="testadmin",
        email="admin@test.com",
        password_hash=hash_password("Admin@123"),
        first_name="Test",
        last_name="Admin",
        role_id=seed_superadmin_role.id,
        organization_id=seed_organization.id,
        inactive=False
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@pytest.fixture
def vendor_user(db: Session, seed_vendor_role: Role) -> User:
    """Create a vendor user for testing"""
    user = User(
        username="testvendor",
        email="vendor@test.com",
        password_hash=hash_password("Vendor@123"),
        first_name="Test",
        last_name="Vendor",
        role_id=seed_vendor_role.id,
        inactive=False
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@pytest.fixture
def consumer_user(db: Session, seed_consumer_role: Role) -> User:
    """Create a consumer user for testing"""
    user = User(
        username="testconsumer",
        email="consumer@test.com",
        password_hash=hash_password("Consumer@123"),
        first_name="Test",
        last_name="Consumer",
        role_id=seed_consumer_role.id,
        inactive=False
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


# =============================================================================
# AUTHENTICATION FIXTURES
# =============================================================================

@pytest.fixture
def admin_token(admin_user: User) -> str:
    """Generate JWT token for admin user"""
    token = create_access_token(
        data={
            "sub": str(admin_user.id),
            "username": admin_user.username,
            "email": admin_user.email,
            "role_id": admin_user.role_id,
        },
        expires_delta=timedelta(minutes=30)
    )
    return token


@pytest.fixture
def vendor_token(vendor_user: User) -> str:
    """Generate JWT token for vendor user"""
    token = create_access_token(
        data={
            "sub": str(vendor_user.id),
            "username": vendor_user.username,
            "email": vendor_user.email,
            "role_id": vendor_user.role_id,
        },
        expires_delta=timedelta(minutes=30)
    )
    return token


@pytest.fixture
def consumer_token(consumer_user: User) -> str:
    """Generate JWT token for consumer user"""
    token = create_access_token(
        data={
            "sub": str(consumer_user.id),
            "username": consumer_user.username,
            "email": consumer_user.email,
            "role_id": consumer_user.role_id,
        },
        expires_delta=timedelta(minutes=30)
    )
    return token


# =============================================================================
# AUTH HEADER HELPERS
# =============================================================================

@pytest.fixture
def admin_headers(admin_token: str) -> Dict[str, str]:
    """Auth headers for admin requests"""
    return {"Authorization": f"Bearer {admin_token}"}


@pytest.fixture
def vendor_headers(vendor_token: str) -> Dict[str, str]:
    """Auth headers for vendor requests"""
    return {"Authorization": f"Bearer {vendor_token}"}


@pytest.fixture
def consumer_headers(consumer_token: str) -> Dict[str, str]:
    """Auth headers for consumer requests"""
    return {"Authorization": f"Bearer {consumer_token}"}


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

def create_test_user(
    db: Session,
    username: str,
    email: str,
    password: str,
    role_id: int,
    first_name: str = "Test",
    last_name: str = "User",
    organization_id: int = None
) -> User:
    """Helper function to create test users"""
    user = User(
        username=username,
        email=email,
        password_hash=hash_password(password),
        first_name=first_name,
        last_name=last_name,
        role_id=role_id,
        organization_id=organization_id,
        inactive=False
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def get_auth_headers(user: User) -> Dict[str, str]:
    """Generate auth headers for any user"""
    token = create_access_token(
        data={
            "sub": str(user.id),
            "username": user.username,
            "email": user.email,
            "role_id": user.role_id,
        },
        expires_delta=timedelta(minutes=30)
    )
    return {"Authorization": f"Bearer {token}"}


# =============================================================================
# ADDITIONAL FIXTURES FOR ADMIN FLOW TESTS
# =============================================================================

@pytest.fixture
def seed_branch(db: Session, seed_organization: Organization):
    """Create a test branch"""
    from app.models.branch_m import Branch
    branch = Branch(
        organization_id=seed_organization.id,
        name="Test Branch",
        code="TESTBRANCH",
        email="branch@test.com",
        phone="1234567890",
        address="123 Branch Street",
        city="Test City",
        state="Test State",
        country="Test Country",
        pincode="12345",
        is_head_office=1,
        inactive=False
    )
    db.add(branch)
    db.commit()
    db.refresh(branch)
    return branch


@pytest.fixture
def seed_category(db: Session):
    """Create a test event category"""
    from app.models.category_m import Category
    category = Category(
        name="Test Category",
        code="TEST_CAT",
        description="Test category description",
        icon="🎉",
        color="purple",
        inactive=False
    )
    db.add(category)
    db.commit()
    db.refresh(category)
    return category


@pytest.fixture
def seed_services(db: Session):
    """Create or get test services for event creation"""
    from app.models.service_m import Service
    services = []
    service_data = [
        ("Catering", "CATERING", "🍽️"),
        ("Decoration", "DECORATION", "🎨"),
        ("Photography", "PHOTOGRAPHY", "📷"),
    ]
    for name, code, icon in service_data:
        # Check if service already exists (from app seeders)
        service = db.query(Service).filter(Service.code == code).first()
        if not service:
            service = Service(
                name=name,
                code=code,
                icon=icon,
                description=f"{name} services",
                inactive=False
            )
            db.add(service)
        services.append(service)
    db.commit()
    return services


@pytest.fixture
def seed_event_type(db: Session, seed_category):
    """Create a test event type"""
    from app.models.event_type_m import EventType
    event_type = EventType(
        category_id=seed_category.id,
        name="Test Event Type",
        code="TEST_EVT_TYPE",
        color="blue",
        inactive=False
    )
    db.add(event_type)
    db.commit()
    db.refresh(event_type)
    return event_type


@pytest.fixture
def seed_event(db: Session, seed_category, seed_event_type, seed_organization: Organization):
    """Create a test event"""
    from app.models.event_m import Event, EventStatus
    from datetime import datetime, timedelta
    event = Event(
        organization_id=seed_organization.id,
        category_id=seed_category.id,
        event_type_id=seed_event_type.id,
        name="Test Event",
        description="Test event description",
        event_date=datetime.now() + timedelta(days=30),
        venue="Test Venue",
        city="Test City",
        state="Test State",
        expected_attendees=100,
        budget=50000,
        required_services=[1, 2],
        status=EventStatus.PLANNING,
        inactive=False
    )
    db.add(event)
    db.commit()
    db.refresh(event)
    return event


@pytest.fixture
def seed_vendor(db: Session, seed_vendor_role: Role) -> tuple:
    """Create a test vendor with user"""
    # Create vendor user
    vendor_user = User(
        username="seedvendor",
        email="seedvendor@test.com",
        password_hash=hash_password("Vendor@123"),
        first_name="Seed",
        last_name="Vendor",
        role_id=seed_vendor_role.id,
        inactive=False
    )
    db.add(vendor_user)
    db.commit()
    db.refresh(vendor_user)
    
    # Create vendor profile
    from app.models.vendor_m import Vendor
    vendor = Vendor(
        user_id=vendor_user.id,
        company_name="Test Vendor Company",
        business_type="Event Services",
        phone="9876543210",
        address="456 Vendor Street",
        city="Vendor City",
        state="Vendor State",
        zip_code="54321",
        description="Test vendor description",
        offered_services=[1, 2],
        status="approved",
        rating=4.5,
        total_reviews=10,
        completed_events=5,
        inactive=False
    )
    db.add(vendor)
    db.commit()
    db.refresh(vendor)
    
    return vendor, vendor_user


@pytest.fixture
def seed_pending_vendor(db: Session, seed_vendor_role: Role) -> tuple:
    """Create a pending vendor for approval testing"""
    # Create vendor user
    pending_user = User(
        username="pendingvendor",
        email="pending@test.com",
        password_hash=hash_password("Vendor@123"),
        first_name="Pending",
        last_name="Vendor",
        role_id=seed_vendor_role.id,
        inactive=False
    )
    db.add(pending_user)
    db.commit()
    db.refresh(pending_user)
    
    from app.models.vendor_m import Vendor
    pending_vendor = Vendor(
        user_id=pending_user.id,
        company_name="Pending Vendor Company",
        business_type="Event Planning",
        phone="5555555555",
        city="Pending City",
        state="Pending State",
        status="pending",
        offered_services=[1],
        inactive=False
    )
    db.add(pending_vendor)
    db.commit()
    db.refresh(pending_vendor)
    
    return pending_vendor, pending_user


@pytest.fixture
def seed_vendor_bid(db: Session, seed_vendor: tuple, seed_event):
    """Create a test vendor bid"""
    from app.models.vendor_bid_m import VendorBid
    vendor, vendor_user = seed_vendor
    
    bid = VendorBid(
        vendor_id=vendor.id,
        event_id=seed_event.id,
        total_amount=25000.00,
        proposal_description="Test bid description",
        timeline_days=7,
        status="submitted",
        inactive=False
    )
    db.add(bid)
    db.commit()
    db.refresh(bid)
    return bid


# =============================================================================
# VENDOR NOTIFICATION FIXTURES
# =============================================================================

@pytest.fixture
def seed_notification(db: Session, seed_vendor: tuple, seed_event):
    """Create a test notification for a vendor"""
    from app.models.vendor_notification_m import VendorNotification
    vendor, vendor_user = seed_vendor
    
    notification = VendorNotification(
        vendor_id=vendor.id,
        event_id=seed_event.id,
        notification_type="new_event_match",
        title="New Event Match",
        message="A new event matches your services",
        priority="normal",
        category="bidding",
        is_read=False,
        inactive=False
    )
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification


@pytest.fixture
def seed_multiple_notifications(db: Session, seed_vendor: tuple, seed_event):
    """Create multiple test notifications for a vendor"""
    from app.models.vendor_notification_m import VendorNotification
    vendor, vendor_user = seed_vendor
    
    notifications = []
    notification_types = [
        ("new_event_match", "New Event Match", "A new event matches your services", False),
        ("bid_status_update", "Bid Status Updated", "Your bid status has changed", False),
        ("event_awarded", "Event Awarded", "Congratulations! You won the bid", True),
    ]
    
    for ntype, title, message, is_read in notification_types:
        notification = VendorNotification(
            vendor_id=vendor.id,
            event_id=seed_event.id,
            notification_type=ntype,
            title=title,
            message=message,
            priority="normal",
            category="bidding",
            is_read=is_read,
            inactive=False
        )
        db.add(notification)
        notifications.append(notification)
    
    db.commit()
    for n in notifications:
        db.refresh(n)
    return notifications


# =============================================================================
# VENDOR ORDER FIXTURES
# =============================================================================

@pytest.fixture
def seed_vendor_order(db: Session, seed_vendor: tuple, seed_event):
    """Create a test order for a vendor"""
    from app.models.vendor_order_m import VendorOrder
    from datetime import datetime
    import uuid
    
    vendor, vendor_user = seed_vendor
    
    order = VendorOrder(
        vendor_id=vendor.id,
        event_id=seed_event.id,
        order_ref=f"ORD-{uuid.uuid4().hex[:8].upper()}",
        amount=25000.00,
        status="confirmed",
        confirmed_at=datetime.now(),
        inactive=False
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return order


@pytest.fixture
def seed_multiple_orders(db: Session, seed_vendor: tuple, seed_event):
    """Create multiple test orders for a vendor"""
    from app.models.vendor_order_m import VendorOrder
    from datetime import datetime, timedelta
    import uuid
    
    vendor, vendor_user = seed_vendor
    
    orders = []
    statuses = ["confirmed", "in_progress", "completed"]
    
    for i, status in enumerate(statuses):
        order = VendorOrder(
            vendor_id=vendor.id,
            event_id=seed_event.id,
            order_ref=f"ORD-{uuid.uuid4().hex[:8].upper()}",
            amount=25000.00 + (i * 5000),
            status=status,
            confirmed_at=datetime.now() - timedelta(days=i),
            inactive=False
        )
        db.add(order)
        orders.append(order)
    
    db.commit()
    for o in orders:
        db.refresh(o)
    return orders


# =============================================================================
# VENDOR PAYMENT FIXTURES
# =============================================================================

@pytest.fixture
def seed_vendor_payment(db: Session, seed_vendor: tuple, seed_vendor_order):
    """Create a test payment for a vendor"""
    from app.models.vendor_payment_m import VendorPayment
    from datetime import datetime
    import uuid
    
    vendor, vendor_user = seed_vendor
    
    payment = VendorPayment(
        vendor_id=vendor.id,
        order_id=seed_vendor_order.id,
        amount=25000.00,
        payment_method="bank_transfer",
        payment_ref=f"PAY-{uuid.uuid4().hex[:8].upper()}",
        status="completed",
        paid_at=datetime.now(),
        inactive=False
    )
    db.add(payment)
    db.commit()
    db.refresh(payment)
    return payment


@pytest.fixture
def seed_multiple_payments(db: Session, seed_vendor: tuple, seed_multiple_orders):
    """Create multiple test payments for a vendor"""
    from app.models.vendor_payment_m import VendorPayment
    from datetime import datetime, timedelta
    import uuid
    
    vendor, vendor_user = seed_vendor
    
    payments = []
    statuses = ["completed", "pending", "completed"]
    
    for i, (order, status) in enumerate(zip(seed_multiple_orders, statuses)):
        payment = VendorPayment(
            vendor_id=vendor.id,
            order_id=order.id,
            amount=order.amount,
            payment_method="bank_transfer",
            payment_ref=f"PAY-{uuid.uuid4().hex[:8].upper()}",
            status=status,
            paid_at=datetime.now() - timedelta(days=i) if status == "completed" else None,
            inactive=False
        )
        db.add(payment)
        payments.append(payment)
    
    db.commit()
    for p in payments:
        db.refresh(p)
    return payments

