#!/usr/bin/env python3
"""
Ensure the battery inventory has at least N batteries (default: 10,000).

What this script does:
1. Counts current batteries in DB.
2. If count < target, creates only the missing rows.
3. Distributes most new batteries across active stations.
4. Backfills station slots and recalculates station availability counters.

Safe to rerun: this script only tops up missing batteries.
"""

from __future__ import annotations

import os
import random
import sys
import uuid
from datetime import datetime, timezone

from sqlmodel import Session, select, func

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(CURRENT_DIR)
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from app.db.session import engine
from app.models.battery import Battery, BatteryStatus, BatteryHealth, LocationType
from app.models.battery_catalog import BatteryCatalog
from app.models.station import Station, StationSlot

UTC = timezone.utc
SEED_TAG = "seed_topup_10k_v1"


def _coerce_scalar(value):
    if isinstance(value, (tuple, list)):
        return value[0] if value else 0
    return value


def _count_batteries(session: Session) -> int:
    row = session.exec(select(func.count(Battery.id))).one()
    return int(_coerce_scalar(row) or 0)


def _ensure_station_slots(session: Session, station: Station) -> int:
    if not station.id:
        return 0
    current_slots = session.exec(
        select(StationSlot).where(StationSlot.station_id == station.id)
    ).all()
    missing = max((station.total_slots or 0) - len(current_slots), 0)
    if missing <= 0:
        return 0

    start_no = len(current_slots) + 1
    for i in range(missing):
        session.add(
            StationSlot(
                station_id=station.id,
                slot_number=start_no + i,
                status="empty",
                is_locked=True,
            )
        )
    return missing


def _battery_status_for_seed() -> BatteryStatus:
    roll = random.random()
    if roll < 0.80:
        return BatteryStatus.AVAILABLE
    if roll < 0.92:
        return BatteryStatus.CHARGING
    if roll < 0.98:
        return BatteryStatus.RESERVED
    return BatteryStatus.MAINTENANCE


def _battery_health_for_status(status: BatteryStatus) -> BatteryHealth:
    if status == BatteryStatus.MAINTENANCE:
        return BatteryHealth.FAIR
    if status == BatteryStatus.RESERVED:
        return BatteryHealth.GOOD
    return BatteryHealth.GOOD


def _create_topup_batteries(session: Session, target_count: int) -> tuple[int, int, int]:
    existing_count = _count_batteries(session)
    missing = max(target_count - existing_count, 0)
    if missing == 0:
        return existing_count, 0, existing_count

    stations = session.exec(
        select(Station).where(
            Station.is_deleted == False,  # noqa: E712
            Station.status.in_(["active", "maintenance"]),
        )
    ).all()
    if not stations:
        stations = session.exec(
            select(Station).where(Station.is_deleted == False)  # noqa: E712
        ).all()

    sku_ids = session.exec(select(BatteryCatalog.id)).all()
    sku_ids = [sid for sid in sku_ids if sid is not None]

    created = 0
    assigned_to_stations = 0
    warehouse_seeded = 0
    batch: list[Battery] = []

    for i in range(missing):
        assign_station = bool(stations) and random.random() < 0.75
        station = stations[i % len(stations)] if assign_station else None
        status = _battery_status_for_seed()

        battery = Battery(
            serial_number=f"WZ-TOPUP-{uuid.uuid4().hex[:12].upper()}",
            qr_code_data=f"WZQR-{uuid.uuid4().hex[:14].upper()}",
            sku_id=random.choice(sku_ids) if sku_ids else None,
            station_id=station.id if station and station.id else None,
            status=status,
            health_status=_battery_health_for_status(status),
            current_charge=round(random.uniform(35.0, 100.0), 2),
            health_percentage=round(random.uniform(70.0, 100.0), 2),
            cycle_count=random.randint(0, 1200),
            total_cycles=2000,
            temperature_c=round(random.uniform(22.0, 42.0), 1),
            battery_type="48V/30Ah",
            location_type=LocationType.STATION if station else LocationType.WAREHOUSE,
            location_id=station.id if station and station.id else None,
            state_of_health=round(random.uniform(70.0, 100.0), 2),
            charge_cycles=random.randint(0, 1200),
            notes=SEED_TAG,
            created_at=datetime.now(UTC),
            updated_at=datetime.now(UTC),
        )
        batch.append(battery)

        if station:
            assigned_to_stations += 1
        else:
            warehouse_seeded += 1

        if len(batch) >= 1000:
            session.add_all(batch)
            session.commit()
            created += len(batch)
            batch.clear()

    if batch:
        session.add_all(batch)
        session.commit()
        created += len(batch)

    return existing_count, created, existing_count + created


def _sync_station_inventory(session: Session) -> tuple[int, int]:
    stations = session.exec(
        select(Station).where(Station.is_deleted == False)  # noqa: E712
    ).all()
    if not stations:
        return 0, 0

    slot_rows_created = 0
    stations_updated = 0

    for station in stations:
        if not station.id:
            continue

        slot_rows_created += _ensure_station_slots(session, station)
        session.commit()

        used_ids = session.exec(
            select(StationSlot.battery_id).where(
                StationSlot.station_id == station.id,
                StationSlot.battery_id != None,  # noqa: E711
            )
        ).all()
        used_ids = {
            int(_coerce_scalar(bid))
            for bid in used_ids
            if _coerce_scalar(bid) is not None
        }

        empty_slots = session.exec(
            select(StationSlot).where(
                StationSlot.station_id == station.id,
                StationSlot.battery_id == None,  # noqa: E711
            )
        ).all()

        if empty_slots:
            battery_query = select(Battery).where(
                Battery.station_id == station.id,
                Battery.status.in_(
                    [
                        BatteryStatus.AVAILABLE,
                        BatteryStatus.CHARGING,
                        BatteryStatus.RESERVED,
                        BatteryStatus.READY,
                    ]
                ),
            )
            if used_ids:
                battery_query = battery_query.where(Battery.id.notin_(used_ids))

            candidate_batteries = session.exec(
                battery_query.limit(len(empty_slots))
            ).all()

            for slot, battery in zip(empty_slots, candidate_batteries):
                slot.battery_id = battery.id
                slot.status = "ready" if battery.status in [
                    BatteryStatus.AVAILABLE,
                    BatteryStatus.RESERVED,
                    BatteryStatus.READY,
                ] else "charging"
                slot.is_locked = True
                session.add(slot)

        available_count_row = session.exec(
            select(func.count(Battery.id)).where(
                Battery.station_id == station.id,
                Battery.status.in_(
                    [
                        BatteryStatus.AVAILABLE,
                        BatteryStatus.READY,
                        BatteryStatus.RESERVED,
                    ]
                ),
            )
        ).one()
        available_count = int(_coerce_scalar(available_count_row) or 0)

        occupied_slots_row = session.exec(
            select(func.count(StationSlot.id)).where(
                StationSlot.station_id == station.id,
                StationSlot.battery_id != None,  # noqa: E711
            )
        ).one()
        occupied_slots = int(_coerce_scalar(occupied_slots_row) or 0)

        station.available_batteries = available_count
        station.available_slots = max((station.total_slots or 0) - occupied_slots, 0)
        station.updated_at = datetime.now(UTC)
        session.add(station)
        session.commit()
        stations_updated += 1

    return slot_rows_created, stations_updated


def run(target_count: int = 10000) -> None:
    random.seed(20260426)
    with Session(engine) as session:
        before_count, created, after_count = _create_topup_batteries(session, target_count)
        slot_rows_created, stations_updated = _sync_station_inventory(session)

        print("=" * 72)
        print("Battery Top-Up Summary")
        print("=" * 72)
        print(f"Target battery count       : {target_count}")
        print(f"Batteries before top-up    : {before_count}")
        print(f"New batteries created      : {created}")
        print(f"Batteries after top-up     : {after_count}")
        print(f"New slot rows created      : {slot_rows_created}")
        print(f"Stations inventory updated : {stations_updated}")
        if created == 0:
            print("No top-up needed. Existing battery count already meets target.")
        else:
            print(f"Top-up completed with seed tag: {SEED_TAG}")


if __name__ == "__main__":
    target = 10000
    if len(sys.argv) > 1:
        try:
            target = int(sys.argv[1])
        except ValueError:
            raise SystemExit("Usage: python scripts/seed_batteries_topup_10k.py [target_count]")
    run(target)
