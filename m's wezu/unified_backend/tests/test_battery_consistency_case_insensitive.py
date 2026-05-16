from __future__ import annotations

import uuid

import pytest
from fastapi import HTTPException
from sqlmodel import Session

from app.models.battery import Battery
from app.models.inventory import InventoryTransferItem
from app.models.order import OrderBattery
from app.models.warehouse import Rack, Shelf, ShelfBattery, Warehouse
from app.services.battery_consistency import (
    _get_shelf_assignment,
    fetch_batteries_by_serials,
    get_battery_by_serial,
)


def _make_battery(session: Session, serial_number: str) -> Battery:
    battery = Battery(serial_number=serial_number)
    session.add(battery)
    session.commit()
    session.refresh(battery)
    return battery


def _make_shelf(session: Session) -> Shelf:
    suffix = uuid.uuid4().hex[:6].upper()
    warehouse = Warehouse(
        name=f"Warehouse {suffix}",
        code=f"WH-{suffix}",
        address="Address",
        city="Hyderabad",
        state="Telangana",
        pincode="500001",
    )
    session.add(warehouse)
    session.commit()
    session.refresh(warehouse)

    rack = Rack(warehouse_id=int(warehouse.id), name=f"Rack {suffix}")
    session.add(rack)
    session.commit()
    session.refresh(rack)

    shelf = Shelf(rack_id=int(rack.id), name=f"Shelf {suffix}", capacity=10)
    session.add(shelf)
    session.commit()
    session.refresh(shelf)
    return shelf


def test_fetch_batteries_by_serials_is_case_insensitive_and_preserves_input_order(session: Session):
    first = _make_battery(session, "bat-100")
    second = _make_battery(session, "BAT-200")

    batteries = fetch_batteries_by_serials(
        session,
        [" bat-200 ", "BAT-100"],
        require_non_empty=True,
    )

    assert [battery.id for battery in batteries] == [second.id, first.id]
    assert [battery.serial_number for battery in batteries] == ["BAT-200", "bat-100"]


def test_get_battery_by_serial_raises_on_case_insensitive_duplicates(session: Session):
    _make_battery(session, "BAT-DUP")
    _make_battery(session, "bat-dup")

    with pytest.raises(HTTPException) as exc_info:
        get_battery_by_serial(session, "Bat-Dup")
    assert exc_info.value.status_code == 409
    assert "multiple battery rows found" in exc_info.value.detail


def test_get_shelf_assignment_raises_on_case_insensitive_duplicates(session: Session):
    battery = _make_battery(session, "BAT-SHELF-DUP")
    first_shelf = _make_shelf(session)
    second_shelf = _make_shelf(session)
    session.add(ShelfBattery(shelf_id=int(first_shelf.id), battery_id=battery.serial_number))
    session.add(ShelfBattery(shelf_id=int(second_shelf.id), battery_id=battery.serial_number.lower()))
    session.commit()

    with pytest.raises(HTTPException) as exc_info:
        _get_shelf_assignment(session, "bat-shelf-dup")
    assert exc_info.value.status_code == 409
    assert "multiple shelf assignments found" in exc_info.value.detail


def test_case_insensitive_lookup_indexes_exist():
    index_names = {
        *(index.name for index in Battery.__table__.indexes),
        *(index.name for index in ShelfBattery.__table__.indexes),
        *(index.name for index in InventoryTransferItem.__table__.indexes),
        *(index.name for index in OrderBattery.__table__.indexes),
    }
    assert "ix_batteries_serial_number_upper" in index_names
    assert "ix_shelf_batteries_battery_id_upper" in index_names
    assert "ix_inventory_transfer_items_battery_id_upper" in index_names
    assert "ix_logistics_order_batteries_battery_id_upper" in index_names
