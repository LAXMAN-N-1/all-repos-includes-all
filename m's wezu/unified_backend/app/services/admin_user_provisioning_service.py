from __future__ import annotations

from datetime import UTC, datetime
from typing import Iterable, Optional

from fastapi import HTTPException
from sqlmodel import Session, select

from app.models.access_assignment import StationStaffAssignment, WarehouseUserAssignment
from app.models.dealer import DealerProfile
from app.models.station import Station
from app.models.tenant import Tenant, TenantMembership
from app.models.user import User
from app.models.warehouse import Warehouse
from app.schemas.station import StationCreate
from app.schemas.warehouse import WarehouseCreate


class AdminUserProvisioningService:
    @staticmethod
    def create_dealer_profile(
        db: Session,
        *,
        user: User,
        payload,
    ) -> DealerProfile:
        profile = DealerProfile(
            user_id=user.id,
            business_name=payload.business_name,
            contact_person=payload.contact_person or user.full_name or payload.business_name,
            contact_email=str(payload.contact_email or user.email),
            contact_phone=payload.contact_phone or user.phone_number or "",
            address_line1=payload.address_line1 or "",
            city=payload.city or "",
            state=payload.state or "",
            pincode=payload.pincode or "",
            gst_number=payload.gst_number,
            pan_number=payload.pan_number,
            is_active=True,
            created_at=datetime.now(UTC),
        )
        db.add(profile)
        db.flush()
        return profile

    @staticmethod
    def ensure_dealer_tenant(db: Session, *, dealer: DealerProfile) -> Tenant:
        if dealer.id is None:
            db.flush()
        if dealer.tenant_id:
            existing = db.get(Tenant, dealer.tenant_id)
            if existing:
                return existing

        preferred_id = int(dealer.id)
        slug = f"dealer-{preferred_id}"
        tenant = db.get(Tenant, preferred_id)
        if tenant is None:
            tenant = db.exec(select(Tenant).where(Tenant.slug == slug)).first()
        if tenant is None:
            tenant = Tenant(
                id=preferred_id,
                slug=slug,
                name=dealer.business_name or f"Dealer {preferred_id}",
                is_active=bool(dealer.is_active),
                created_at=datetime.now(UTC),
                updated_at=datetime.now(UTC),
            )
            db.add(tenant)
            db.flush()
        else:
            tenant.name = dealer.business_name or tenant.name
            tenant.is_active = bool(dealer.is_active)
            tenant.updated_at = datetime.now(UTC)
            db.add(tenant)
            db.flush()

        dealer.tenant_id = tenant.id
        db.add(dealer)
        db.flush()
        return tenant

    @staticmethod
    def ensure_membership(
        db: Session,
        *,
        tenant_id: int,
        user_id: int,
        scope: str,
        is_default: bool,
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
        db.flush()
        return membership

    @staticmethod
    def create_stations_for_dealer(
        db: Session,
        *,
        dealer: DealerProfile,
        payloads: Iterable[StationCreate],
    ) -> list[Station]:
        stations: list[Station] = []
        for payload in payloads:
            station = Station(
                name=payload.name,
                tenant_id=dealer.tenant_id,
                owner_id=dealer.user_id,
                dealer_id=dealer.id,
                address=payload.address,
                city=payload.city,
                latitude=payload.latitude,
                longitude=payload.longitude,
                zone_id=payload.zone_id,
                station_type=payload.station_type,
                total_slots=payload.total_slots,
                power_rating_kw=payload.power_rating_kw,
                contact_phone=payload.contact_phone,
                operating_hours=payload.operating_hours,
                is_24x7=payload.is_24x7,
                amenities=payload.amenities,
                status=payload.status,
                available_slots=payload.total_slots,
            )
            db.add(station)
            db.flush()
            stations.append(station)
        return stations

    @staticmethod
    def create_warehouses(
        db: Session,
        *,
        payloads: Iterable[WarehouseCreate],
        manager_user_id: Optional[int],
    ) -> list[Warehouse]:
        warehouses: list[Warehouse] = []
        seen_codes: set[str] = set()
        for payload in payloads:
            normalized_code = payload.code.strip().upper()
            if not normalized_code:
                raise HTTPException(status_code=400, detail="warehouse code is required")
            if normalized_code in seen_codes:
                raise HTTPException(status_code=400, detail=f"duplicate warehouse code: {normalized_code}")
            seen_codes.add(normalized_code)

            existing = db.exec(
                select(Warehouse).where(Warehouse.code == normalized_code)
            ).first()
            if existing:
                raise HTTPException(
                    status_code=400,
                    detail=f"warehouse code already exists: {normalized_code}",
                )

            warehouse = Warehouse(
                name=payload.name,
                code=normalized_code,
                address=payload.address,
                city=payload.city,
                state=payload.state,
                pincode=payload.pincode,
                branch_id=payload.branch_id,
                manager_id=manager_user_id or payload.manager_id,
                is_active=payload.is_active,
            )
            db.add(warehouse)
            db.flush()
            warehouses.append(warehouse)
        return warehouses

    @staticmethod
    def assign_station_scope(
        db: Session,
        *,
        user: User,
        dealer_id: int,
        station_ids: list[int],
        current_user: User,
    ) -> None:
        for station_id in station_ids:
            station = db.get(Station, station_id)
            if not station or station.dealer_id != dealer_id:
                raise HTTPException(status_code=404, detail=f"station_not_found:{station_id}")
            existing = db.exec(
                select(StationStaffAssignment).where(
                    StationStaffAssignment.user_id == user.id,
                    StationStaffAssignment.station_id == station_id,
                )
            ).first()
            if existing:
                existing.is_active = True
                existing.dealer_id = dealer_id
                existing.assigned_by_user_id = current_user.id
                existing.updated_at = datetime.now(UTC)
                db.add(existing)
            else:
                db.add(
                    StationStaffAssignment(
                        user_id=user.id,
                        dealer_id=dealer_id,
                        station_id=station_id,
                        assigned_by_user_id=current_user.id,
                    )
                )
        db.flush()

    @staticmethod
    def assign_warehouse_scope(
        db: Session,
        *,
        user: User,
        warehouse_ids: list[int],
        current_user: User,
    ) -> None:
        for warehouse_id in warehouse_ids:
            warehouse = db.get(Warehouse, warehouse_id)
            if not warehouse or not warehouse.is_active:
                raise HTTPException(status_code=404, detail=f"warehouse_not_found:{warehouse_id}")
            existing = db.exec(
                select(WarehouseUserAssignment).where(
                    WarehouseUserAssignment.user_id == user.id,
                    WarehouseUserAssignment.warehouse_id == warehouse_id,
                )
            ).first()
            if existing:
                existing.is_active = True
                existing.assigned_by_user_id = current_user.id
                existing.updated_at = datetime.now(UTC)
                db.add(existing)
            else:
                db.add(
                    WarehouseUserAssignment(
                        user_id=user.id,
                        warehouse_id=warehouse_id,
                        assigned_by_user_id=current_user.id,
                    )
                )
        db.flush()
