from __future__ import annotations
from app.models.station import Station, StationImage, StationSlot, StationStatus
from sqlmodel import Session, select, func
from datetime import datetime, timezone; UTC = timezone.utc
from math import radians, cos, sin, asin, sqrt
from app.models.alert import Alert
from app.models.station_heartbeat import StationHeartbeat

from app.models.battery import Battery
from app.models.rental import Rental
from app.schemas.station import StationCreate, StationUpdate
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta, timezone; UTC = timezone.utc
from sqlmodel import Session, select, func

class StationService:
    @staticmethod
    def get_stations(db: Session, skip: int = 0, limit: int = 100) -> List[Station]:
        from sqlalchemy.orm import selectinload
        return db.exec(
            select(Station)
            .options(selectinload(Station.images))
            .offset(skip).limit(limit)
        ).all()

    @staticmethod
    def get_nearby(
        db: Session, 
        lat: float, 
        lon: float, 
        radius_km: float = 50.0,
        status: Optional[str] = None,
        is_24x7: Optional[bool] = None,
        sort_by: str = "distance",
        filters: Optional['NearbyFilterSchema'] = None
    ) -> List['NearbyStationResponse']:
        from app.schemas.station import NearbyStationResponse, StationImageResponse, NearbyFilterSchema
        from app.models.battery_catalog import BatteryCatalog
        from sqlalchemy.orm import selectinload

        normalized_radius_km = float(radius_km or 50.0)
        if normalized_radius_km <= 0:
            normalized_radius_km = 50.0

        # 1. Base Query — eager-load images to avoid N+1 in the loop below
        # (station.images is accessed per-station during response construction).
        # Apply a coarse lat/lon bounding box first so we do not scan all
        # stations in Python for every request.
        lat_delta = normalized_radius_km / 111.0
        cos_lat = max(cos(radians(lat)), 0.1)
        lon_delta = normalized_radius_km / (111.0 * cos_lat)

        query = select(Station).options(selectinload(Station.images))
        query = query.where(
            Station.latitude >= (lat - lat_delta),
            Station.latitude <= (lat + lat_delta),
            Station.longitude >= (lon - lon_delta),
            Station.longitude <= (lon + lon_delta),
        )
        if status:
            query = query.where(Station.status == status)
        if filters and getattr(filters, "min_rating", None) is not None:
            query = query.where(Station.rating >= filters.min_rating)
        if is_24x7:
             query = query.where(Station.is_24x7 == True)
             
        stations = db.exec(query).all()
        if not stations:
            return []

        station_ids = [station.id for station in stations if station.id is not None]
        
        # 2. Get Availability Map (Filtered by battery specs)
        # We join StationSlot -> Battery -> BatteryCatalog to evaluate specs
        availability_query = (
            select(StationSlot.station_id, func.count(StationSlot.id))
            .join(Battery, StationSlot.battery_id == Battery.id)
            .join(BatteryCatalog, Battery.sku_id == BatteryCatalog.id)
            .where(StationSlot.status == "ready")
        )
        if station_ids:
            availability_query = availability_query.where(StationSlot.station_id.in_(station_ids))
        
        # Apply filters to availability count
        if filters:
            if filters.battery_type:
                availability_query = availability_query.where(BatteryCatalog.battery_type == filters.battery_type)
            if filters.capacity_min is not None:
                availability_query = availability_query.where(BatteryCatalog.capacity_mah >= filters.capacity_min)
            if filters.capacity_max is not None:
                availability_query = availability_query.where(BatteryCatalog.capacity_mah <= filters.capacity_max)
            if filters.price_max is not None:
                availability_query = availability_query.where(BatteryCatalog.price_per_day <= filters.price_max)
            if filters.price_min is not None:
                availability_query = availability_query.where(BatteryCatalog.price_per_day >= filters.price_min)
                
        availability_query = availability_query.group_by(StationSlot.station_id)
        
        availability_results = db.exec(availability_query).all()
        availability_map = {r[0]: r[1] for r in availability_results}
        
        nearby = []
        for station in stations:
            # If availability is required, skip stations with 0 matching batteries
            if filters and filters.availability and availability_map.get(station.id, 0) == 0:
                continue
                
            dist = StationService.haversine(lon, lat, station.longitude, station.latitude)
            if dist <= normalized_radius_km:
                station_data = station.model_dump()
                station_data.pop("available_batteries", None)
                images = [StationImageResponse(url=img.url, is_primary=img.is_primary) for img in station.images]
                # Use slot-computed count when slots exist; fall back to denormalized field
                slot_count = availability_map.get(station.id)
                avail = slot_count if slot_count is not None else station.available_batteries

                nearby_station = NearbyStationResponse(
                    **station_data,
                    images=images,
                    distance=dist,
                    available_batteries=avail
                )
                nearby.append(nearby_station)
        
        # 3. Sort
        if sort_by == "rating":
            nearby.sort(key=lambda s: s.rating, reverse=True)
        elif sort_by == "availability":
            nearby.sort(key=lambda s: s.available_batteries, reverse=True)
        else: # distance (default)
            nearby.sort(key=lambda s: s.distance)
            
        return nearby

    @staticmethod
    def haversine(lon1, lat1, lon2, lat2):
        # convert decimal degrees to radians 
        lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
        # haversine formula 
        dlon = lon2 - lon1 
        dlat = lat2 - lat1 
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * asin(sqrt(a)) 
        r = 6371 # Radius of earth in kilometers
        return c * r

    @staticmethod
    def create_station(db: Session, station_in: StationCreate) -> Station:
        station = Station(**station_in.dict())
        db.add(station)
        db.commit()
        db.refresh(station)
        
        # Generate QR Code Data
        station.qr_code_data = f"wezu://station/{station.id}"
        db.add(station)
        db.commit()
        db.refresh(station)
        return station

    @staticmethod
    def get_qr(station_id: int) -> str:
        from app.services.qr_service import QRCodeService
        return QRCodeService.generate_station_qr(station_id)

    @staticmethod
    def get_available_slots(db: Session, station_id: int) -> List[StationSlot]:
        return db.execute(
            select(StationSlot).where(
                StationSlot.station_id == station_id, 
                StationSlot.status == "empty"
            )
        ).scalars().all()

    @staticmethod
    def assign_battery_to_slot(db: Session, slot_id: int, battery_id: int):
        slot = db.get(StationSlot, slot_id)
        if not slot:
            return None
        
        slot.battery_id = battery_id
        slot.status = "charging"
        slot.is_locked = True
        
        # Update Battery location
        battery = db.get(Battery, battery_id)
        if battery:
            battery.location_type = "station"
            battery.location_id = slot.station_id
            db.add(battery)
            
        db.add(slot)
        db.commit()
        db.refresh(slot)
        return slot

    @staticmethod
    def release_battery_from_slot(db: Session, slot_id: int):
        slot = db.get(StationSlot, slot_id)
        if not slot:
            return None
        
        slot.battery_id = None
        slot.status = "empty"
        slot.is_locked = False
        
        db.add(slot)
        db.commit()
        db.refresh(slot)
        return slot

    @staticmethod
    def update_station(db: Session, station_id: int, station_in: StationUpdate) -> Optional[Station]:
        station = db.get(Station, station_id)
        if not station:
            return None
        
        update_data = station_in.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(station, key, value)
            
        station.updated_at = datetime.now(UTC)
        db.add(station)
        db.commit()
        db.refresh(station)
        return station

    @staticmethod
    def deactivate_station(db: Session, station_id: int) -> bool:
        station = db.get(Station, station_id)
        if not station:
            return False
        
        station.status = StationStatus.CLOSED
        station.updated_at = datetime.now(UTC)
        db.add(station)
        db.commit()
        return True

    @staticmethod
    def get_performance_metrics(db: Session, station_id: int) -> Dict[str, Any]:
        # Last 24 hours stats
        day_ago = datetime.now(UTC) - timedelta(days=1)
        rentals_stmt = select(Rental).where(Rental.start_station_id == station_id, Rental.start_time >= day_ago)
        rentals = db.exec(rentals_stmt).all()
        
        total_rentals = len(rentals)
        total_revenue = sum(r.total_amount for r in rentals if r.total_amount)
        
        # Calculate avg duration for completed rentals
        completed_rentals = [r for r in rentals if r.end_time]
        avg_duration = 0.0
        if completed_rentals:
            total_dur = sum((r.end_time - r.start_time).total_seconds() for r in completed_rentals)
            avg_duration = (total_dur / len(completed_rentals)) / 60.0 # in minutes
            
        station = db.get(Station, station_id)
        utilization = 0.0
        if station and station.total_slots > 0:
            # Let's define utilization as (available_batteries / total_slots) for capacity check
            utilization = (station.available_batteries / station.total_slots * 100)
            
        return {
            "daily_rentals": total_rentals,
            "daily_revenue": round(total_revenue, 2),
            "avg_duration_minutes": round(avg_duration, 2),
            "satisfaction_score": station.rating if station else 0.0,
            "utilization_percentage": round(utilization, 2)
        }

    @staticmethod
    def get_rental_history(db: Session, station_id: int, limit: int = 50) -> List[Rental]:
        return db.exec(
            select(Rental)
            .where(Rental.start_station_id == station_id)
            .order_by(Rental.start_time.desc())
            .limit(limit)
        ).all()

    @staticmethod
    def record_heartbeat(db: Session, station_id: int, status: str, metrics: dict):
        """
        Simplified heartbeat recorder for tests. Creates a StationHeartbeat and raises alerts on high temperature.
        """
        hb = StationHeartbeat(
            station_id=station_id,
            status=status,
            temperature=metrics.get("temperature"),
            power_consumption=metrics.get("power_consumption"),
            network_latency_ms=metrics.get("network_latency"),
            recorded_at=datetime.now(UTC)
        )
        db.add(hb)

        # High temperature alert
        if metrics.get("temperature", 0) >= 80:
            alert = Alert(
                station_id=station_id,
                alert_type="HARDWARE",
                severity="CRITICAL",
                message=f"High temperature detected: {metrics.get('temperature')}",
                created_at=datetime.now(UTC)
            )
            db.add(alert)
        db.commit()

    @staticmethod
    def get_heatmap_data(db: Session) -> List[Dict[str, Any]]:
        # Aggregate demand by recent rentals per station
        week_ago = datetime.now(UTC) - timedelta(days=7)
        demand_stmt = (
            select(Station.latitude, Station.longitude, func.count(Rental.id))
            .join(Rental, Rental.start_station_id == Station.id)
            .where(Rental.start_time >= week_ago)
            .group_by(Station.id)
        )
        results = db.exec(demand_stmt).all()
        
        if not results:
            return []
            
        max_demand = max(r[2] for r in results) if results else 1
        
        return [
            {
                "latitude": r[0],
                "longitude": r[1],
                "intensity": round(r[2] / max_demand, 2)
            }
            for r in results
        ]
