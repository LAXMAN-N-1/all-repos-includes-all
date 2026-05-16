from __future__ import annotations

from datetime import UTC, datetime
from typing import Any, Optional

from sqlmodel import Session, select

from app.models.custody import (
    BatteryCustodyEvent,
    DealerMainInventoryBattery,
    StationInventoryBattery,
)


class CustodyService:
    @staticmethod
    def record_battery_event(
        session: Session,
        *,
        battery_id: str,
        battery_pk: Optional[int],
        event_type: str,
        actor_id: Optional[int],
        actor_role: Optional[str],
        tenant_id: Optional[int] = None,
        order_id: Optional[str] = None,
        rental_id: Optional[int] = None,
        dealer_id: Optional[int] = None,
        warehouse_id: Optional[int] = None,
        admin_id: Optional[int] = None,
        warehouse_operator_id: Optional[int] = None,
        driver_id: Optional[int] = None,
        station_id: Optional[int] = None,
        customer_id: Optional[int] = None,
        from_location_type: Optional[str] = None,
        from_location_id: Optional[int] = None,
        to_location_type: Optional[str] = None,
        to_location_id: Optional[int] = None,
        metadata: Optional[dict[str, Any]] = None,
    ) -> BatteryCustodyEvent:
        event = BatteryCustodyEvent(
            tenant_id=tenant_id,
            order_id=order_id,
            rental_id=rental_id,
            battery_id=battery_id,
            battery_pk=battery_pk,
            event_type=event_type,
            actor_id=actor_id,
            actor_role=actor_role,
            dealer_id=dealer_id,
            warehouse_id=warehouse_id,
            admin_id=admin_id,
            warehouse_operator_id=warehouse_operator_id,
            driver_id=driver_id,
            station_id=station_id,
            customer_id=customer_id,
            from_location_type=from_location_type,
            from_location_id=from_location_id,
            to_location_type=to_location_type,
            to_location_id=to_location_id,
            metadata_json=metadata,
            occurred_at=datetime.now(UTC),
        )
        session.add(event)
        return event

    @staticmethod
    def land_battery_in_dealer_main_inventory(
        session: Session,
        *,
        tenant_id: Optional[int],
        dealer_id: int,
        battery_id: str,
        battery_pk: Optional[int],
    ) -> DealerMainInventoryBattery:
        row = session.exec(
            select(DealerMainInventoryBattery)
            .where(DealerMainInventoryBattery.dealer_id == dealer_id)
            .where(DealerMainInventoryBattery.battery_id == battery_id)
            .limit(1)
        ).first()
        if row is None:
            row = DealerMainInventoryBattery(
                tenant_id=tenant_id,
                dealer_id=dealer_id,
                battery_id=battery_id,
                battery_pk=battery_pk,
                status="IN_STOCK",
                assigned_station_id=None,
                station_assignment_status=None,
            )
        else:
            row.tenant_id = tenant_id
            row.battery_pk = battery_pk
            row.status = "IN_STOCK"
            row.assigned_station_id = None
            row.station_assignment_status = None
            row.is_active = True
            row.deleted_at = None
            row.updated_at = datetime.now(UTC)
        session.add(row)
        return row

    @staticmethod
    def assign_battery_to_station(
        session: Session,
        *,
        tenant_id: Optional[int],
        dealer_id: int,
        station_id: int,
        battery_id: str,
        battery_pk: Optional[int],
    ) -> StationInventoryBattery:
        station_row = session.exec(
            select(StationInventoryBattery)
            .where(StationInventoryBattery.station_id == station_id)
            .where(StationInventoryBattery.battery_id == battery_id)
            .limit(1)
        ).first()
        if station_row is None:
            station_row = StationInventoryBattery(
                tenant_id=tenant_id,
                station_id=station_id,
                source_dealer_id=dealer_id,
                battery_id=battery_id,
                battery_pk=battery_pk,
                status="IN_STOCK",
            )
        else:
            station_row.tenant_id = tenant_id
            station_row.source_dealer_id = dealer_id
            station_row.battery_pk = battery_pk
            station_row.status = "IN_STOCK"
            station_row.is_active = True
            station_row.deleted_at = None
            station_row.updated_at = datetime.now(UTC)
        session.add(station_row)

        dealer_row = session.exec(
            select(DealerMainInventoryBattery)
            .where(DealerMainInventoryBattery.dealer_id == dealer_id)
            .where(DealerMainInventoryBattery.battery_id == battery_id)
            .limit(1)
        ).first()
        if dealer_row is not None:
            dealer_row.status = "ASSIGNED_TO_STATION"
            dealer_row.assigned_station_id = station_id
            dealer_row.station_assignment_status = "ACTIVE"
            dealer_row.updated_at = datetime.now(UTC)
            session.add(dealer_row)

        return station_row

    @staticmethod
    def remove_station_inventory_battery(
        session: Session,
        *,
        station_id: int,
        battery_id: str,
    ) -> None:
        row = session.exec(
            select(StationInventoryBattery)
            .where(StationInventoryBattery.station_id == station_id)
            .where(StationInventoryBattery.battery_id == battery_id)
            .where(StationInventoryBattery.is_active == True)  # noqa: E712
            .limit(1)
        ).first()
        if row is None:
            return
        row.is_active = False
        row.deleted_at = datetime.now(UTC)
        row.updated_at = datetime.now(UTC)
        session.add(row)
