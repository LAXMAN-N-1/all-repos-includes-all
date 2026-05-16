"""
Tests for multi-role login flows and multi-tenancy tenant context resolution.

Covers:
1. Multi-role auth via Supabase JWT (GET /api/v1/auth/me)
   - Single-role user response
   - Multiple assigned roles — all returned, permissions aggregated
   - Superuser synthetic "super_admin" role injection
   - Expired UserRole excluded from response
   - Future effective_from excluded from response
   - Token issued before global logout is rejected with 401

2. Active role resolution (unit — get_active_roles_for_user_id)
   - Expired assignments excluded (expires_at < now)
   - Future assignments excluded (effective_from > now)
   - Inactive roles excluded (is_active=False)
   - Ordering by level DESC (highest-privilege first)

3. Tenant context resolution (unit — _resolve_local_tenant_id / _resolve_tenant_context)
   - Via DealerProfile (user_id match)
   - Via created_by_dealer_id fallback
   - Via TenantMembership (default flag preference)
   - Via single TenantMembership (no default needed)
   - Returns None for bare user with no dealer context
   - Superuser gets scope="global"
   - Global admin role gets scope="global"
   - Dealer user gets scope="tenant" with correct tenant_id
   - No tenant context raises 403 tenant_context_missing

4. Cross-tenant isolation
   - Two dealers each resolve their own independent tenant_id
   - Dealer staff inherits parent dealer's tenant_id
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from typing import Optional
from unittest.mock import MagicMock

import pytest
from fastapi import Request
from sqlmodel import Session, select

from app.api import deps
from app.api.deps import (
    _resolve_local_tenant_id,
    _resolve_actor_context,
    _resolve_tenant_context,
    get_active_roles_for_user_id,
    get_user_role_names,
    TenantContext,
)
from app.core.config import settings
from app.models.access_assignment import WarehouseUserAssignment
from app.models.dealer import DealerProfile
from app.models.rbac import Permission, Role, RolePermission, UserRole
from app.models.tenant import Tenant, TenantMembership
from app.models.user import User, UserStatus, UserType
from app.models.user_identity import UserIdentity
from app.services.auth_service import AuthService, SupabaseTokenValidationError
from app.utils.datetime_utils import utcnow_naive


# ─────────────────────────────────────────────────────────────────────────────
# Shared helpers
# ─────────────────────────────────────────────────────────────────────────────

def _mk_user(
    session: Session,
    email: str,
    *,
    is_superuser: bool = False,
    user_type: UserType = UserType.CUSTOMER,
    created_by_dealer_id: Optional[int] = None,
) -> User:
    phone_suffix = str(abs(hash(email)) % 9_000_000_000 + 1_000_000_000)
    user = User(
        email=email,
        full_name=email.split("@")[0],
        phone_number=phone_suffix,
        status=UserStatus.ACTIVE,
        is_superuser=is_superuser,
        user_type=user_type,
        created_by_dealer_id=created_by_dealer_id,
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    return user


def _mk_role(
    session: Session,
    name: str,
    *,
    level: int = 0,
    is_active: bool = True,
    dealer_id: Optional[int] = None,
) -> Role:
    role = Role(
        name=name,
        is_active=is_active,
        level=level,
        dealer_id=dealer_id,
    )
    session.add(role)
    session.commit()
    session.refresh(role)
    return role


def _mk_permission(session: Session, slug: str, module: str = "test", action: str = "read") -> Permission:
    perm = Permission(slug=slug, module=module, action=action)
    session.add(perm)
    session.commit()
    session.refresh(perm)
    return perm


def _assign_role(
    session: Session,
    user: User,
    role: Role,
    *,
    effective_from: Optional[datetime] = None,
    expires_at: Optional[datetime] = None,
) -> UserRole:
    assignment = UserRole(
        user_id=user.id,
        role_id=role.id,
        effective_from=effective_from or datetime.now(UTC),
        expires_at=expires_at,
    )
    session.add(assignment)
    session.commit()
    return assignment


def _mk_dealer_profile(session: Session, user_id: int, name: str = "Test Dealer") -> DealerProfile:
    profile = DealerProfile(
        user_id=user_id,
        business_name=name,
        contact_person="Owner",
        contact_email=f"{name.lower().replace(' ', '')}@test.dealer",
        contact_phone="9000000001",
        address_line1="1 Test Street",
        city="Hyderabad",
        state="Telangana",
        pincode="500001",
        is_active=True,
    )
    session.add(profile)
    session.commit()
    session.refresh(profile)
    return profile


def _mk_tenant_membership(
    session: Session,
    user: User,
    tenant: Tenant,
    *,
    is_default: bool = False,
    status: str = "active",
) -> TenantMembership:
    membership = TenantMembership(
        tenant_id=tenant.id,
        user_id=user.id,
        is_default=is_default,
        status=status,
    )
    session.add(membership)
    session.commit()
    return membership


def _mock_supabase_verifier(payload_by_token: dict[str, dict]):
    """Factory matching the pattern in test_supabase_auth_cutover.py."""
    def _verify(cls, token: str):
        payload = payload_by_token.get(token)
        if payload is None:
            raise SupabaseTokenValidationError("token_invalid", "invalid test token")
        return payload
    return classmethod(_verify)


def _mock_request(*, auth_subject: Optional[str] = None, auth_tenant_id: Optional[int] = None) -> MagicMock:
    """Minimal Request mock that satisfies _resolve_tenant_context."""
    req = MagicMock(spec=Request)
    req.state = MagicMock()
    req.state.auth_subject = auth_subject
    req.state.auth_tenant_id = auth_tenant_id
    req.headers = {}
    return req


# ─────────────────────────────────────────────────────────────────────────────
# PART 1  Multi-Role Auth via Supabase JWT  (/api/v1/auth/me)
# ─────────────────────────────────────────────────────────────────────────────

@pytest.fixture(autouse=True)
def _force_supabase_mode(monkeypatch):
    monkeypatch.setattr(settings, "AUTH_PROVIDER", "supabase")
    monkeypatch.setattr(settings, "SUPABASE_ENFORCE_EMAIL_VERIFIED", True)


class TestMultiRoleLoginViaSupabase:
    """End-to-end: Supabase JWT → /auth/me returns correct roles & permissions."""

    def _setup_user_with_identity(self, session: Session, email: str, sub: str) -> User:
        user = _mk_user(session, email)
        session.add(UserIdentity(provider="supabase", external_subject=sub, user_id=user.id, email_snapshot=email))
        session.commit()
        return user

    def _supabase_token_payload(self, sub: str, email: str) -> dict:
        return {
            "sub": sub,
            "email": email,
            "email_verified": True,
            "role": "authenticated",
            "iat": 1_700_000_000,
            "exp": 9_999_999_999,
        }

    def test_single_role_returned_in_auth_me(self, client, session: Session, monkeypatch):
        user = self._setup_user_with_identity(session, "single-role@test.com", "sub-single-role")
        role = _mk_role(session, "dealer_owner", level=10)
        _assign_role(session, user, role)

        token = "token-single-role"
        monkeypatch.setattr(
            AuthService,
            "verify_supabase_access_token",
            _mock_supabase_verifier({token: self._supabase_token_payload("sub-single-role", "single-role@test.com")}),
        )
        deps.invalidate_token_cache(token)

        resp = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert "dealer_owner" in body["roles"]
        assert body["user"]["email"] == "single-role@test.com"

    def test_multiple_roles_all_returned_in_auth_me(self, client, session: Session, monkeypatch):
        user = self._setup_user_with_identity(session, "multi-role@test.com", "sub-multi-role")
        role_owner = _mk_role(session, "dealer_owner", level=10)
        role_manager = _mk_role(session, "dealer_manager", level=11)
        _assign_role(session, user, role_owner)
        _assign_role(session, user, role_manager)

        token = "token-multi-role"
        monkeypatch.setattr(
            AuthService,
            "verify_supabase_access_token",
            _mock_supabase_verifier({token: self._supabase_token_payload("sub-multi-role", "multi-role@test.com")}),
        )
        deps.invalidate_token_cache(token)

        resp = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 200, resp.text
        roles = set(resp.json()["roles"])
        assert "dealer_owner" in roles
        assert "dealer_manager" in roles

    def test_permissions_aggregated_from_all_roles(self, client, session: Session, monkeypatch):
        user = self._setup_user_with_identity(session, "perm-agg@test.com", "sub-perm-agg")

        # Use canonical action names: "read" is normalised to "view" by canonicalize_permission_slug
        perm_a = _mk_permission(session, "battery:view:global", "battery", "view")
        perm_b = _mk_permission(session, "station:view:global", "station", "view")

        role_a = _mk_role(session, "fleet_manager_perm_test", level=8)
        role_b = _mk_role(session, "warehouse_manager_perm_test", level=9)
        session.add(RolePermission(role_id=role_a.id, permission_id=perm_a.id))
        session.add(RolePermission(role_id=role_b.id, permission_id=perm_b.id))
        session.commit()

        _assign_role(session, user, role_a)
        _assign_role(session, user, role_b)

        token = "token-perm-agg"
        monkeypatch.setattr(
            AuthService,
            "verify_supabase_access_token",
            _mock_supabase_verifier({token: self._supabase_token_payload("sub-perm-agg", "perm-agg@test.com")}),
        )
        deps.invalidate_token_cache(token)

        resp = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 200, resp.text
        permissions = set(resp.json()["permissions"])
        assert "battery:view:global" in permissions
        assert "station:view:global" in permissions

    def test_superuser_includes_super_admin_in_roles(self, client, session: Session, monkeypatch):
        user = _mk_user(session, "superuser-me@test.com", is_superuser=True)
        session.add(UserIdentity(provider="supabase", external_subject="sub-superuser", user_id=user.id, email_snapshot=user.email))
        session.commit()

        token = "token-superuser"
        monkeypatch.setattr(
            AuthService,
            "verify_supabase_access_token",
            _mock_supabase_verifier({token: self._supabase_token_payload("sub-superuser", "superuser-me@test.com")}),
        )
        deps.invalidate_token_cache(token)

        resp = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 200, resp.text
        assert "super_admin" in resp.json()["roles"]

    def test_expired_user_role_excluded_from_auth_me(self, client, session: Session, monkeypatch):
        user = self._setup_user_with_identity(session, "expired-role@test.com", "sub-expired-role")
        active_role = _mk_role(session, "logistics_manager", level=6)
        expired_role = _mk_role(session, "dispatcher", level=7)

        _assign_role(session, user, active_role)
        _assign_role(
            session, user, expired_role,
            expires_at=datetime.now(UTC) - timedelta(days=1),  # expired yesterday
        )

        token = "token-expired-role"
        monkeypatch.setattr(
            AuthService,
            "verify_supabase_access_token",
            _mock_supabase_verifier({token: self._supabase_token_payload("sub-expired-role", "expired-role@test.com")}),
        )
        deps.invalidate_token_cache(token)

        resp = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 200, resp.text
        roles = resp.json()["roles"]
        assert "logistics_manager" in roles
        assert "dispatcher" not in roles, "Expired role must not appear in /auth/me response"

    def test_future_effective_from_role_excluded_from_auth_me(self, client, session: Session, monkeypatch):
        user = self._setup_user_with_identity(session, "future-role@test.com", "sub-future-role")
        active_role = _mk_role(session, "support_manager_future_test", level=4)
        pending_role = _mk_role(session, "support_agent_future_test", level=5)

        _assign_role(session, user, active_role)
        _assign_role(
            session, user, pending_role,
            effective_from=datetime.now(UTC) + timedelta(days=30),  # starts next month
        )

        token = "token-future-role"
        monkeypatch.setattr(
            AuthService,
            "verify_supabase_access_token",
            _mock_supabase_verifier({token: self._supabase_token_payload("sub-future-role", "future-role@test.com")}),
        )
        deps.invalidate_token_cache(token)

        resp = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 200, resp.text
        roles = resp.json()["roles"]
        assert "support_manager_future_test" in roles
        assert "support_agent_future_test" not in roles, "Future-effective role must not appear"

    def test_token_issued_before_global_logout_is_rejected(self, client, session: Session, monkeypatch):
        user = self._setup_user_with_identity(session, "global-logout@test.com", "sub-global-logout")
        # Set global logout timestamp to now — any token with iat < this is invalid
        user.last_global_logout_at = datetime.now(UTC)
        session.add(user)
        session.commit()

        token = "token-pre-logout"
        monkeypatch.setattr(
            AuthService,
            "verify_supabase_access_token",
            _mock_supabase_verifier({
                token: {
                    "sub": "sub-global-logout",
                    "email": "global-logout@test.com",
                    "email_verified": True,
                    "iat": 1_000_000,   # very old timestamp — before global logout
                    "exp": 9_999_999_999,
                }
            }),
        )
        deps.invalidate_token_cache(token)

        resp = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 401, "Token issued before global logout should be rejected"
        assert resp.json()["detail"] == "token_invalid"

    def test_duplicate_permissions_from_overlapping_roles_deduplicated(self, client, session: Session, monkeypatch):
        """Two roles that both grant the same permission slug → permission appears once."""
        user = self._setup_user_with_identity(session, "dedup-perm@test.com", "sub-dedup-perm")
        # "read" is canonicalised to "view"; use "view" slug to match what /auth/me returns
        shared_perm = _mk_permission(session, "shared:view:global", "shared", "view")

        role_x = _mk_role(session, "role_x_dedup", level=5)
        role_y = _mk_role(session, "role_y_dedup", level=6)
        session.add(RolePermission(role_id=role_x.id, permission_id=shared_perm.id))
        session.add(RolePermission(role_id=role_y.id, permission_id=shared_perm.id))
        session.commit()

        _assign_role(session, user, role_x)
        _assign_role(session, user, role_y)

        token = "token-dedup-perm"
        monkeypatch.setattr(
            AuthService,
            "verify_supabase_access_token",
            _mock_supabase_verifier({token: self._supabase_token_payload("sub-dedup-perm", "dedup-perm@test.com")}),
        )
        deps.invalidate_token_cache(token)

        resp = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 200, resp.text
        permissions = resp.json()["permissions"]
        assert permissions.count("shared:view:global") == 1, "Duplicate permission slug must be deduplicated"


# ─────────────────────────────────────────────────────────────────────────────
# PART 2  Active Role Resolution (unit)
# ─────────────────────────────────────────────────────────────────────────────

class TestActiveRoleResolution:
    """Unit tests for get_active_roles_for_user_id — temporal filtering and ordering."""

    def test_empty_for_user_with_no_role_assignments(self, session: Session):
        user = _mk_user(session, "no-roles@unit.com")
        result = get_active_roles_for_user_id(session, user.id)
        assert result == []

    def test_active_assignment_included(self, session: Session):
        user = _mk_user(session, "active-assign@unit.com")
        role = _mk_role(session, "active_assign_role", level=5)
        _assign_role(session, user, role)

        result = get_active_roles_for_user_id(session, user.id)
        assert len(result) == 1
        assert result[0].name == "active_assign_role"

    def test_expired_assignment_excluded(self, session: Session):
        user = _mk_user(session, "expired-assign@unit.com")
        role = _mk_role(session, "expired_assign_role", level=5)
        _assign_role(session, user, role, expires_at=datetime.now(UTC) - timedelta(hours=1))

        result = get_active_roles_for_user_id(session, user.id)
        assert result == [], "Assignment with past expires_at must be excluded"

    def test_future_effective_from_assignment_excluded(self, session: Session):
        user = _mk_user(session, "future-assign@unit.com")
        role = _mk_role(session, "future_assign_role", level=5)
        _assign_role(session, user, role, effective_from=datetime.now(UTC) + timedelta(days=7))

        result = get_active_roles_for_user_id(session, user.id)
        assert result == [], "Assignment with future effective_from must be excluded"

    def test_inactive_role_excluded_even_with_active_assignment(self, session: Session):
        user = _mk_user(session, "inactive-role@unit.com")
        role = _mk_role(session, "inactive_test_role", level=5, is_active=False)
        _assign_role(session, user, role)

        result = get_active_roles_for_user_id(session, user.id)
        assert result == [], "Assignment pointing to is_active=False role must be excluded"

    def test_active_assignment_with_future_expiry_included(self, session: Session):
        user = _mk_user(session, "valid-expiry@unit.com")
        role = _mk_role(session, "valid_expiry_role", level=5)
        _assign_role(session, user, role, expires_at=datetime.now(UTC) + timedelta(days=365))

        result = get_active_roles_for_user_id(session, user.id)
        assert len(result) == 1

    def test_roles_ordered_by_level_descending(self, session: Session):
        """Higher-privilege roles (higher level) must appear first."""
        user = _mk_user(session, "order-roles@unit.com")
        low = _mk_role(session, "low_priv_role", level=1)
        mid = _mk_role(session, "mid_priv_role", level=5)
        high = _mk_role(session, "high_priv_role", level=10)

        # Assign in non-priority order
        _assign_role(session, user, low)
        _assign_role(session, user, high)
        _assign_role(session, user, mid)

        result = get_active_roles_for_user_id(session, user.id)
        levels = [r.level for r in result]
        assert levels == sorted(levels, reverse=True), f"Expected descending level order, got {levels}"

    def test_multiple_active_assignments_all_returned(self, session: Session):
        user = _mk_user(session, "multi-assign@unit.com")
        roles = [_mk_role(session, f"multi_role_{i}", level=i) for i in range(3)]
        for role in roles:
            _assign_role(session, user, role)

        result = get_active_roles_for_user_id(session, user.id)
        assert len(result) == 3

    def test_mix_of_active_expired_and_future_assignments(self, session: Session):
        user = _mk_user(session, "mixed-assign@unit.com")
        active = _mk_role(session, "mixed_active_role", level=5)
        expired = _mk_role(session, "mixed_expired_role", level=6)
        future = _mk_role(session, "mixed_future_role", level=7)

        _assign_role(session, user, active)
        _assign_role(session, user, expired, expires_at=datetime.now(UTC) - timedelta(minutes=5))
        _assign_role(session, user, future, effective_from=datetime.now(UTC) + timedelta(minutes=5))

        result = get_active_roles_for_user_id(session, user.id)
        assert len(result) == 1
        assert result[0].name == "mixed_active_role"


# ─────────────────────────────────────────────────────────────────────────────
# PART 3  Tenant Context Resolution (unit)
# ─────────────────────────────────────────────────────────────────────────────

class TestResolveTenantIdUnit:
    """Unit tests for _resolve_local_tenant_id — resolution path priority."""

    def test_returns_none_for_user_with_no_dealer_context(self, session: Session):
        user = _mk_user(session, "bare-user@tenant.com")
        result = _resolve_local_tenant_id(session, user)
        assert result is None

    def test_resolves_via_dealer_profile(self, session: Session):
        user = _mk_user(session, "dealer-profile@tenant.com")
        profile = _mk_dealer_profile(session, user.id, "Profile Dealer")

        result = _resolve_local_tenant_id(session, user)
        assert result == profile.id

    def test_resolves_via_created_by_dealer_id(self, session: Session):
        owner = _mk_user(session, "owner-for-staff@tenant.com")
        profile = _mk_dealer_profile(session, owner.id, "Staff Parent Dealer")

        staff = _mk_user(
            session,
            "staff@tenant.com",
            user_type=UserType.DEALER_STAFF,
            created_by_dealer_id=profile.id,
        )

        result = _resolve_local_tenant_id(session, staff)
        assert result == profile.id

    def test_resolves_via_tenant_membership_default_flag(self, session: Session):
        user = _mk_user(session, "membership-default@tenant.com")
        tenant_a = Tenant(slug="tenant-a", name="Tenant A")
        tenant_b = Tenant(slug="tenant-b", name="Tenant B")
        session.add(tenant_a)
        session.add(tenant_b)
        session.commit()
        session.refresh(tenant_a)
        session.refresh(tenant_b)

        _mk_tenant_membership(session, user, tenant_a, is_default=False)
        _mk_tenant_membership(session, user, tenant_b, is_default=True)

        result = _resolve_local_tenant_id(session, user)
        assert result == tenant_b.id, "Default membership must be preferred over non-default"

    def test_resolves_via_single_tenant_membership_without_default(self, session: Session):
        user = _mk_user(session, "membership-single@tenant.com")
        tenant = Tenant(slug="tenant-single", name="Single Tenant")
        session.add(tenant)
        session.commit()
        session.refresh(tenant)

        _mk_tenant_membership(session, user, tenant, is_default=False)

        result = _resolve_local_tenant_id(session, user)
        assert result == tenant.id

    def test_two_dealers_resolve_independent_tenant_ids(self, session: Session):
        owner_a = _mk_user(session, "dealer-a-owner@tenant.com")
        owner_b = _mk_user(session, "dealer-b-owner@tenant.com")
        profile_a = _mk_dealer_profile(session, owner_a.id, "Dealer Alpha")
        profile_b = _mk_dealer_profile(session, owner_b.id, "Dealer Beta")

        result_a = _resolve_local_tenant_id(session, owner_a)
        result_b = _resolve_local_tenant_id(session, owner_b)

        assert result_a == profile_a.id
        assert result_b == profile_b.id
        assert result_a != result_b, "Two distinct dealers must resolve to different tenant IDs"

    def test_dealer_staff_inherits_parent_dealer_tenant_id(self, session: Session):
        owner = _mk_user(session, "parent-dealer@tenant.com")
        profile = _mk_dealer_profile(session, owner.id, "Parent Dealer")

        staff_1 = _mk_user(session, "staff-1@tenant.com", created_by_dealer_id=profile.id)
        staff_2 = _mk_user(session, "staff-2@tenant.com", created_by_dealer_id=profile.id)

        assert _resolve_local_tenant_id(session, staff_1) == profile.id
        assert _resolve_local_tenant_id(session, staff_2) == profile.id

    def test_dealer_profile_resolution_preferred_over_membership(self, session: Session):
        """DealerProfile path must win over TenantMembership when both exist."""
        user = _mk_user(session, "both-paths@tenant.com")
        profile = _mk_dealer_profile(session, user.id, "Both Paths Dealer")

        tenant = Tenant(slug="both-paths-tenant", name="Both Paths Tenant")
        session.add(tenant)
        session.commit()
        session.refresh(tenant)
        _mk_tenant_membership(session, user, tenant, is_default=True)

        # TenantMembership path is checked first in _resolve_local_tenant_id
        result = _resolve_local_tenant_id(session, user)
        # Should resolve to TenantMembership (checked first), not DealerProfile
        assert result == tenant.id


# ─────────────────────────────────────────────────────────────────────────────
# PART 4  Tenant Context (scope resolution) via _resolve_tenant_context
# ─────────────────────────────────────────────────────────────────────────────

class TestResolveTenantContext:
    """Unit tests for _resolve_tenant_context using mock Request in test-env mode."""

    @pytest.fixture(autouse=True)
    def _set_test_environment(self, monkeypatch):
        # Required so the ENVIRONMENT-based shortcut applies in _resolve_tenant_context
        monkeypatch.setattr(settings, "ENVIRONMENT", "testing")

    def test_superuser_gets_global_scope(self, session: Session):
        user = _mk_user(session, "superuser-ctx@tenant.com", is_superuser=True)
        req = _mock_request()

        ctx = _resolve_tenant_context(session, user, req, allow_global=True)

        assert ctx.scope == "global"
        assert ctx.tenant_id is None

    def test_global_admin_role_gets_global_scope(self, session: Session):
        user = _mk_user(session, "admin-ctx@tenant.com")
        admin_role = _mk_role(session, "operations_admin", level=1)
        _assign_role(session, user, admin_role)
        # Populate _active_roles_cache so get_user_role_names picks them up
        active = get_active_roles_for_user_id(session, user.id)
        setattr(user, "_active_roles_cache", active)

        req = _mock_request()
        ctx = _resolve_tenant_context(session, user, req, allow_global=True)

        assert ctx.scope == "global"

    def test_dealer_user_gets_tenant_scope(self, session: Session):
        user = _mk_user(session, "dealer-ctx@tenant.com")
        profile = _mk_dealer_profile(session, user.id, "Scoped Dealer")

        req = _mock_request()
        ctx = _resolve_tenant_context(session, user, req, allow_global=False)

        assert ctx.scope == "tenant"
        assert ctx.tenant_id == profile.id

    def test_user_with_no_tenant_context_raises_403(self, session: Session):
        user = _mk_user(session, "no-ctx@tenant.com")
        req = _mock_request()

        with pytest.raises(Exception) as exc_info:
            _resolve_tenant_context(session, user, req, allow_global=False)

        exc = exc_info.value
        assert getattr(exc, "status_code", None) == 403
        assert exc.detail == "tenant_context_missing"

    def test_superuser_with_allow_global_false_still_gets_global_scope(self, session: Session):
        """Superusers bypass tenant requirement regardless of allow_global flag."""
        user = _mk_user(session, "super-allow-global@tenant.com", is_superuser=True)
        req = _mock_request()

        # Superusers always get global scope; allow_global=True is still needed
        ctx = _resolve_tenant_context(session, user, req, allow_global=True)
        assert ctx.scope == "global"

    def test_tenant_context_contains_correct_user_reference(self, session: Session):
        user = _mk_user(session, "ctx-user-ref@tenant.com")
        _mk_dealer_profile(session, user.id, "Ref Dealer")

        req = _mock_request()
        ctx = _resolve_tenant_context(session, user, req, allow_global=False)

        assert ctx.user.id == user.id

    def test_global_scope_context_has_no_tenant_id(self, session: Session):
        user = _mk_user(session, "global-no-tenant@tenant.com", is_superuser=True)
        req = _mock_request()

        ctx = _resolve_tenant_context(session, user, req, allow_global=True)

        assert ctx.scope == "global"
        assert ctx.tenant_id is None


# ─────────────────────────────────────────────────────────────────────────────
# PART 5  Multi-Tenancy Isolation — Cross-Tenant HTTP Tests
# ─────────────────────────────────────────────────────────────────────────────

class TestCrossTenantIsolation:
    """
    Verify that two dealer users cannot resolve each other's tenant context,
    and that user_type/role combinations produce the correct scope output.
    """

    @pytest.fixture(autouse=True)
    def _set_test_environment(self, monkeypatch):
        monkeypatch.setattr(settings, "ENVIRONMENT", "testing")

    def test_dealer_a_cannot_resolve_dealer_b_tenant_id(self, session: Session):
        owner_a = _mk_user(session, "cross-a@isolation.com")
        owner_b = _mk_user(session, "cross-b@isolation.com")
        profile_a = _mk_dealer_profile(session, owner_a.id, "Cross Dealer A")
        profile_b = _mk_dealer_profile(session, owner_b.id, "Cross Dealer B")

        req = _mock_request()
        ctx_a = _resolve_tenant_context(session, owner_a, req, allow_global=False)
        ctx_b = _resolve_tenant_context(session, owner_b, req, allow_global=False)

        assert ctx_a.tenant_id == profile_a.id
        assert ctx_b.tenant_id == profile_b.id
        assert ctx_a.tenant_id != ctx_b.tenant_id

    def test_admin_user_blocked_from_getting_tenant_scope(self, session: Session):
        """Admin user with no dealer profile must not accidentally get tenant scope."""
        user = _mk_user(session, "admin-no-dealer@isolation.com", user_type=UserType.ADMIN)
        req = _mock_request()

        with pytest.raises(Exception) as exc_info:
            _resolve_tenant_context(session, user, req, allow_global=False)

        assert exc_info.value.status_code == 403

    def test_get_user_role_names_aggregates_all_active_roles(self, session: Session):
        """get_user_role_names uses _active_roles_cache if set, primary role otherwise."""
        user = _mk_user(session, "role-names@isolation.com")
        role_1 = _mk_role(session, "dealer_inventory_staff", level=12)
        role_2 = _mk_role(session, "dealer_finance_staff", level=13)
        _assign_role(session, user, role_1)
        _assign_role(session, user, role_2)

        active = get_active_roles_for_user_id(session, user.id)
        setattr(user, "_active_roles_cache", active)

        role_names = get_user_role_names(user)
        assert "dealer_inventory_staff" in role_names
        assert "dealer_finance_staff" in role_names

    def test_superuser_flag_adds_super_admin_role_name(self, session: Session):
        user = _mk_user(session, "super-flag@isolation.com", is_superuser=True)
        role_names = get_user_role_names(user)
        assert "super_admin" in role_names

    def test_user_type_contributes_to_role_names(self, session: Session):
        user = _mk_user(session, "usertype-role@isolation.com", user_type=UserType.LOGISTICS)
        role_names = get_user_role_names(user)
        # canonical_role_name("logistics") → "logistics_manager" per RBAC alias map
        assert "logistics_manager" in role_names

    def test_has_permission_false_when_role_not_assigned(self, session: Session):
        user = _mk_user(session, "no-perm@isolation.com")
        setattr(user, "_active_roles_cache", [])
        assert user.has_permission("battery:delete:global") is False

    def test_has_permission_true_when_role_with_permission_assigned(self, session: Session):
        user = _mk_user(session, "has-perm@isolation.com")
        perm = _mk_permission(session, "station:create:global", "station", "create")
        role = _mk_role(session, "perm_holder_role", level=5)
        session.add(RolePermission(role_id=role.id, permission_id=perm.id))
        session.commit()
        session.refresh(role)

        setattr(user, "_active_roles_cache", [role])
        assert user.has_permission("station:create:global") is True

    def test_all_permissions_empty_for_user_with_no_roles(self, session: Session):
        user = _mk_user(session, "zero-perms@isolation.com")
        setattr(user, "_active_roles_cache", [])
        assert user.all_permissions == set()

    def test_all_permissions_aggregated_across_multiple_roles(self, session: Session):
        user = _mk_user(session, "multi-perms@isolation.com")
        # "read" → "view" after canonicalization; use canonical slugs
        perm_x = _mk_permission(session, "module_x:view:global", "module_x", "view")
        perm_y = _mk_permission(session, "module_y:write:global", "module_y", "write")

        role_x = _mk_role(session, "role_multi_x", level=3)
        role_y = _mk_role(session, "role_multi_y", level=4)
        session.add(RolePermission(role_id=role_x.id, permission_id=perm_x.id))
        session.add(RolePermission(role_id=role_y.id, permission_id=perm_y.id))
        session.commit()
        session.refresh(role_x)
        session.refresh(role_y)

        setattr(user, "_active_roles_cache", [role_x, role_y])
        perms = user.all_permissions
        assert "module_x:view:global" in perms
        assert "module_y:write:global" in perms

    def test_dealer_staff_cannot_impersonate_global_admin_scope(self, session: Session):
        """A dealer_owner user must not get scope=global through normal resolution."""
        user = _mk_user(session, "staff-no-global@isolation.com")
        profile = _mk_dealer_profile(session, user.id, "Scoped Only Dealer")
        dealer_role = _mk_role(session, "dealer_owner_test", level=10)
        _assign_role(session, user, dealer_role)

        req = _mock_request()
        ctx = _resolve_tenant_context(session, user, req, allow_global=False)

        assert ctx.scope == "tenant"
        assert ctx.tenant_id == profile.id, "Dealer owner must resolve to tenant scope, not global"


class TestActorContextFallback:
    def test_ignores_non_actor_supabase_role_claim_and_derives_admin_from_db(
        self,
        session: Session,
    ):
        admin_role = _mk_role(session, "operations_admin", level=100)
        user = _mk_user(session, "actor-admin@test.com", user_type=UserType.ADMIN)
        _assign_role(session, user, admin_role)

        request = _mock_request(auth_subject="sub-actor-admin")
        request.state.auth_actor_claims = {"role": "authenticated"}

        context = _resolve_actor_context(session, user, request)

        assert context.role == "admin"
        assert context.admin_id == user.id

    def test_derives_warehouse_operator_context_from_assignment_when_token_has_no_actor_claims(
        self,
        session: Session,
    ):
        warehouse_role = _mk_role(session, "logistics_manager", level=80)
        user = _mk_user(session, "warehouse-op@test.com", user_type=UserType.LOGISTICS)
        _assign_role(session, user, warehouse_role)
        session.add(
            WarehouseUserAssignment(
                warehouse_id=77,
                user_id=user.id,
                is_active=True,
            )
        )
        session.commit()

        request = _mock_request(auth_subject="sub-warehouse-op")
        request.state.auth_actor_claims = None

        context = _resolve_actor_context(session, user, request)

        assert context.role == "warehouse_operator"
        assert context.warehouse_id == 77
