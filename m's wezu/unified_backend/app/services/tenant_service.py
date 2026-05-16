from __future__ import annotations

from datetime import UTC, datetime
from typing import Optional

from sqlmodel import Session, select

from app.models.dealer import DealerProfile
from app.models.tenant import Tenant, TenantMembership


class TenantService:
    @staticmethod
    def ensure_dealer_tenant(db: Session, dealer: DealerProfile) -> Tenant:
        if dealer.tenant_id:
            existing = db.get(Tenant, dealer.tenant_id)
            if existing:
                return existing

        now = datetime.now(UTC)
        preferred_id = int(dealer.id) if dealer.id is not None else None
        tenant: Optional[Tenant] = db.get(Tenant, preferred_id) if preferred_id else None
        if tenant is None:
            tenant = db.exec(
                select(Tenant).where(Tenant.slug == f"dealer-{preferred_id}")
            ).first() if preferred_id else None

        if tenant is None:
            tenant_kwargs = {
                "slug": f"dealer-{preferred_id}" if preferred_id else f"dealer-{dealer.user_id}",
                "name": dealer.business_name or f"Dealer {preferred_id or dealer.user_id}",
                "is_active": bool(dealer.is_active),
                "created_at": now,
                "updated_at": now,
            }
            if preferred_id is not None:
                tenant_kwargs["id"] = preferred_id
            tenant = Tenant(**tenant_kwargs)
            db.add(tenant)
            try:
                db.commit()
            except Exception:
                db.rollback()
                tenant = Tenant(
                    slug=f"dealer-{dealer.user_id}-{int(now.timestamp())}",
                    name=dealer.business_name or f"Dealer {dealer.user_id}",
                    is_active=bool(dealer.is_active),
                    created_at=now,
                    updated_at=now,
                )
                db.add(tenant)
                db.commit()
            db.refresh(tenant)
        else:
            tenant.name = dealer.business_name or tenant.name
            tenant.is_active = bool(dealer.is_active)
            tenant.updated_at = now
            db.add(tenant)
            db.commit()
            db.refresh(tenant)

        dealer.tenant_id = tenant.id
        db.add(dealer)
        db.commit()
        db.refresh(dealer)
        return tenant

    @staticmethod
    def ensure_membership(
        db: Session,
        *,
        tenant_id: int,
        user_id: int,
        scope: str,
        is_default: bool = False,
    ) -> TenantMembership:
        membership = db.exec(
            select(TenantMembership).where(
                TenantMembership.tenant_id == tenant_id,
                TenantMembership.user_id == user_id,
            )
        ).first()
        now = datetime.now(UTC)
        if membership is None:
            membership = TenantMembership(
                tenant_id=tenant_id,
                user_id=user_id,
                status="active",
                scope=scope,
                is_default=is_default,
                linked_at=now,
                created_at=now,
                updated_at=now,
            )
        else:
            membership.status = "active"
            membership.scope = scope
            membership.is_default = bool(is_default or membership.is_default)
            membership.updated_at = now
        db.add(membership)
        db.commit()
        db.refresh(membership)
        return membership
