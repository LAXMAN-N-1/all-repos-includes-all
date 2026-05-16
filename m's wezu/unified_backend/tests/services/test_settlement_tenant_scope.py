from __future__ import annotations

from datetime import UTC, datetime

import pytest
from sqlmodel import Session

from app.models.commission import CommissionLog
from app.models.dealer import DealerProfile
from app.models.settlement import Settlement
from app.models.user import User
from app.services.dispute_service import DisputeService
from app.services.settlement_service import SettlementService


def _mk_user(session: Session, email: str) -> User:
    unique_digits = "".join(ch for ch in email if ch.isdigit())[-6:]
    if not unique_digits:
        unique_digits = f"{abs(hash(email)) % 1_000_000:06d}"
    user = User(
        email=email,
        hashed_password="pw",
        full_name=email.split("@")[0],
        phone_number=f"9000{unique_digits}",
        is_active=True,
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    return user


def _mk_dealer_profile(session: Session, user_id: int, *, name: str = "Dealer Test") -> DealerProfile:
    profile = DealerProfile(
        user_id=user_id,
        business_name=name,
        contact_person="Owner",
        contact_email=f"{name.lower().replace(' ', '')}@dealer.test",
        contact_phone="9000000000",
        address_line1="Address",
        city="Bengaluru",
        state="KA",
        pincode="560001",
        is_active=True,
    )
    session.add(profile)
    session.commit()
    session.refresh(profile)
    return profile


def test_resolve_dealer_scope_ids_prefers_profile_for_owner_user(session: Session):
    user = _mk_user(session, "dealer-scope-owner@test.com")
    profile = _mk_dealer_profile(session, user.id, name="Dealer Scope")

    profile_id, owner_user_id = SettlementService.resolve_dealer_scope_ids(session, user.id)

    assert profile_id == profile.id
    assert owner_user_id == user.id


def test_generate_monthly_settlement_persists_profile_scoped_owner(session: Session):
    owner = _mk_user(session, "dealer-settlement-owner@test.com")
    profile = _mk_dealer_profile(session, owner.id, name="Settlement Dealer")

    session.add(
        CommissionLog(
            transaction_id=1,
            dealer_id=owner.id,
            amount=123.45,
            status="pending",
            created_at=datetime(2025, 3, 10),
        )
    )
    session.commit()

    settlement = SettlementService.generate_monthly_settlement(session, owner.id, "2025-03")

    assert settlement.dealer_id == profile.id
    assert settlement.total_commission == 123.45


def test_dispute_service_enforces_settlement_owner_via_profile_scope(session: Session):
    owner = _mk_user(session, "dealer-dispute-owner@test.com")
    profile = _mk_dealer_profile(session, owner.id, name="Dispute Dealer")
    intruder = _mk_user(session, "dealer-dispute-intruder@test.com")

    settlement = Settlement(
        dealer_id=profile.id,
        settlement_month="2025-04",
        start_date=datetime(2025, 4, 1),
        end_date=datetime(2025, 4, 30, 23, 59, 59),
        due_date=datetime(2025, 5, 10),
        total_revenue=0.0,
        total_commission=50.0,
        chargeback_amount=0.0,
        net_payable=50.0,
        status="generated",
        created_at=datetime.now(UTC),
    )
    session.add(settlement)
    session.commit()
    session.refresh(settlement)

    dispute = DisputeService.create_dispute(
        session,
        settlement_id=settlement.id,
        requester_user_id=owner.id,
        reason="charge mismatch",
    )
    assert dispute.dealer_id == owner.id

    with pytest.raises(PermissionError):
        DisputeService.create_dispute(
            session,
            settlement_id=settlement.id,
            requester_user_id=intruder.id,
            reason="unauthorized dispute",
        )
