import logging
from sqlmodel import Session, select
from app.db.session import engine
from app.core.security import get_password_hash
# Import from app.models.all so SQLAlchemy mappers are fully registered.
from app.models.all import (
    User, UserType, UserStatus, Role, UserRole,
    UserProfile, Station, StationStatus, Battery, BatteryStatus,
    BatteryHealth, BatteryCatalog, Wallet,
    DealerProfile
)
from datetime import datetime, UTC, timedelta

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

import os
_SEED_PASSWORD = os.environ.get("SEED_ADMIN_PASSWORD", "ChangeMe!Seed2026")


def _get_or_create_role(session: Session, preferred_names: list[str], description: str, *, is_system_role: bool = False) -> Role:
    for role_name in preferred_names:
        existing = session.exec(select(Role).where(Role.name == role_name)).first()
        if existing:
            return existing

    role = Role(
        name=preferred_names[0],
        description=description,
        is_system_role=is_system_role,
        is_active=True,
    )
    session.add(role)
    session.commit()
    session.refresh(role)
    logger.info(f"Created Role: {role.name}")
    return role


def _upsert_login_user(
    session: Session,
    *,
    email: str,
    phone_number: str,
    full_name: str,
    user_type: UserType,
    role: Role,
    is_superuser: bool = False,
    password: str,
) -> User:
    user = session.exec(select(User).where(User.email == email)).first()
    if not user:
        user = session.exec(select(User).where(User.phone_number == phone_number)).first()

    if not user:
        user = User(email=email, phone_number=phone_number)
        session.add(user)
        logger.info(f"Created User shell: {email}")

    # Always normalize auth-critical fields so reruns repair bad seed data.
    user.email = email
    user.phone_number = phone_number
    user.full_name = full_name
    user.user_type = user_type
    user.status = UserStatus.ACTIVE
    user.is_superuser = is_superuser
    user.failed_login_attempts = 0
    user.locked_until = None
    user.force_password_change = False
    user.is_deleted = False
    user.deleted_at = None
    user.deletion_reason = None
    user.role_id = role.id
    user.hashed_password = get_password_hash(password)
    user.updated_at = datetime.now(UTC)

    session.add(user)
    session.commit()
    session.refresh(user)

    # Ensure active role assignment exists for /auth/login role resolution.
    link = session.exec(
        select(UserRole).where(
            UserRole.user_id == user.id,
            UserRole.role_id == role.id,
        )
    ).first()
    if not link:
        session.add(
            UserRole(
                user_id=user.id,
                role_id=role.id,
                effective_from=datetime.now(UTC),
                expires_at=None,
            )
        )
        session.commit()
        logger.info(f"Linked role {role.name} to user {email}")

    return user


def _ensure_dealer_profile(session: Session, dealer_user: User) -> DealerProfile:
    profile = session.exec(
        select(DealerProfile).where(DealerProfile.user_id == dealer_user.id)
    ).first()
    if profile:
        return profile

    profile = DealerProfile(
        user_id=dealer_user.id,
        business_name="WEZU Dealer Hyderabad",
        contact_person=dealer_user.full_name or "Dealer User",
        contact_email=dealer_user.email or "dealer@wezu.com",
        contact_phone=dealer_user.phone_number or "8888888888",
        address_line1="Madhapur",
        city="Hyderabad",
        state="Telangana",
        pincode="500081",
        is_active=True,
    )
    session.add(profile)
    session.commit()
    session.refresh(profile)
    logger.info(f"Created DealerProfile for {dealer_user.email}")
    return profile


def seed_db():
    with Session(engine) as session:
        logger.info("🌱 Seeding Database...")
        
        # 1. Create / resolve baseline roles
        admin_role = _get_or_create_role(
            session,
            ["super_admin", "admin"],
            "Administrator",
            is_system_role=True,
        )
        dealer_role = _get_or_create_role(
            session,
            ["dealer_owner", "dealer"],
            "Dealer/Franchise Owner",
        )
        customer_role = _get_or_create_role(
            session,
            ["customer"],
            "End User",
        )

        # 2. Upsert demo login users
        _upsert_login_user(
            session,
            email="admin@wezu.com",
            phone_number="9999999999",
            full_name="Super Admin",
            user_type=UserType.ADMIN,
            role=admin_role,
            is_superuser=True,
            password=_SEED_PASSWORD,
        )
        dealer_user = _upsert_login_user(
            session,
            email="dealer@wezu.com",
            phone_number="8888888888",
            full_name="Hyderabad Dealer",
            user_type=UserType.DEALER,
            role=dealer_role,
            password=_SEED_PASSWORD,
        )
        _ensure_dealer_profile(session, dealer_user)
        customer = _upsert_login_user(
            session,
            email="customer@wezu.com",
            phone_number="9646852893",
            full_name="Demo Customer",
            user_type=UserType.CUSTOMER,
            role=customer_role,
            password=_SEED_PASSWORD,
        )
        
        # 3. Create Wallets
        if not session.exec(select(Wallet).where(Wallet.user_id == customer.id)).first():
            wallet = Wallet(user_id=customer.id, balance=500.0)
            session.add(wallet)

        # 4. Create Battery Catalog (SKUs)
        sku_lithium = session.exec(select(BatteryCatalog).where(BatteryCatalog.name == "Wezu Pro 72V")).first()
        if not sku_lithium:
            sku_lithium = BatteryCatalog(
                name="Wezu Pro 72V",
                brand="Wezu",
                model="LFP-72-40",
                capacity_mah=40000,
                voltage=72.0,
                price_per_day=150.0,
                price_full_purchase=85000.0,
                description="High performance LFP battery for heavy duty use.",
                image_url="https://images.unsplash.com/photo-1620619767323-b95a89183081?q=80&w=2940&auto=format&fit=crop"
            )
            session.add(sku_lithium)
            session.commit()
            session.refresh(sku_lithium)
            logger.info("Created Wezu Pro 72V SKU")
            
        sku_std = session.exec(select(BatteryCatalog).where(BatteryCatalog.name == "Wezu Standard 60V")).first()
        if not sku_std:
            sku_std = BatteryCatalog(
                name="Wezu Standard 60V",
                brand="Wezu",
                model="NMC-60-30",
                capacity_mah=30000,
                voltage=60.0,
                price_per_day=100.0,
                price_full_purchase=60000.0,
                description="Standard NMC battery for daily commute.",
                image_url="https://images.unsplash.com/photo-1620619767323-b95a89183081?q=80&w=2940&auto=format&fit=crop"
            )
            session.add(sku_std)
            session.commit()
            session.refresh(sku_std)
            logger.info("Created Wezu Standard 60V SKU")

        # 5. Create Stations & Batteries
        stations_data = [
            {"name": "Hitech City Hub", "lat": 17.4474, "lng": 78.3762, "address": "Madhapur, Hyderabad"},
            {"name": "Gachibowli PowerPt", "lat": 17.4401, "lng": 78.3489, "address": "Gachibowli, Hyderabad"},
            {"name": "Kondapur Center", "lat": 17.4622, "lng": 78.3568, "address": "Kondapur, Hyderabad"},
            {"name": "Jubilee Hills Stn", "lat": 17.4325, "lng": 78.4070, "address": "Jubilee Hills, Hyderabad"},
            {"name": "Banjara Hills Stn", "lat": 17.4126, "lng": 78.4397, "address": "Banjara Hills, Hyderabad"},
        ]
        
        for idx, st_data in enumerate(stations_data):
            station = session.exec(select(Station).where(Station.name == st_data["name"])).first()
            if not station:
                station = Station(
                    name=st_data["name"],
                    latitude=st_data["lat"],
                    longitude=st_data["lng"],
                    address=st_data["address"],
                    owner_id=dealer_user.id,
                    total_slots=10,
                    available_slots=5,
                    available_batteries=5,
                    status=StationStatus.ACTIVE,
                    image_url="https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&q=80&w=2072"
                )
                session.add(station)
                session.commit()
                session.refresh(station)
                logger.info(f"Created Station: {station.name}")
                
                # Add Batteries to Station
                for b_idx in range(5):
                    sku = sku_lithium if b_idx % 2 == 0 else sku_std
                    sn = f"WZ-{idx}-{b_idx}-{int(datetime.now(UTC).timestamp())}"
                    
                    batt = Battery(
                        serial_number=sn,
                        sku_id=sku.id,
                        station_id=station.id,
                        status=BatteryStatus.AVAILABLE,
                        health_status=BatteryHealth.GOOD,
                        current_charge=95.0 - (b_idx * 5),
                        cycle_count=10 + b_idx
                    )
                    session.add(batt)
                session.commit()

        logger.info("✅ Database Seeding Complete!")
        logger.info(f"🔐 Seed login password for demo users: {_SEED_PASSWORD}")

if __name__ == "__main__":
    seed_db()
