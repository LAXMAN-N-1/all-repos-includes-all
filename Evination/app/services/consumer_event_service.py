# app/services/consumer_event_service.py

from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException
from datetime import datetime, timedelta
from typing import List

from app.models.event_m import Event, EventStatus, BiddingStatus
from app.models.service_m import Service
from app.models.vendor_m import Vendor
from app.models.vendor_notification_m import VendorNotification
from app.models.category_m import Category
from app.models.event_type_m import EventType
from app.models.vendor_bid_m import VendorBid

from app.schemas.event_schema import (
    EventCreateSchema,
    EventServiceResponse,
    ConsumerEventListSchema
)


class ConsumerEventService:

    # --------------------------------------------------
    # CREATE EVENT
    # --------------------------------------------------
    @staticmethod
    def create_event(
        db: Session,
        event_data: EventCreateSchema,
        consumer_user
    ):
        """
        Consumer creates event with required services
        Automatically notifies matched vendors
        """

        required_services = event_data.required_services
        if not required_services:
            raise HTTPException(400, "At least one service is required")

        # Validate category exists
        category = db.query(Category).filter(
            Category.id == event_data.category_id,
            Category.inactive == False
        ).first()
        if not category:
            raise HTTPException(400, f"Category with ID {event_data.category_id} does not exist")

        # Validate event type exists
        event_type = db.query(EventType).filter(
            EventType.id == event_data.event_type_id,
            EventType.inactive == False
        ).first()
        if not event_type:
            raise HTTPException(400, f"Event type with ID {event_data.event_type_id} does not exist")

        # Validate services
        service_count = db.query(func.count(Service.id)).filter(
            Service.id.in_(required_services),
            Service.is_active == True,
            Service.inactive == False
        ).scalar()

        if service_count != len(required_services):
            raise HTTPException(400, "One or more services are invalid")

        # Create Event
        # Use organization_id from request, or fallback to user's organization
        org_id = event_data.organization_id or consumer_user.organization_id
        if not org_id:
            raise HTTPException(400, "Organization ID is required")
        
        new_event = Event(
            **event_data.dict(exclude={"required_services", "organization_id"}),
            organization_id=org_id,
            required_services=required_services,
            bidding_deadline=datetime.utcnow() + timedelta(days=7),
            status=EventStatus.PLANNING,
            bidding_status=BiddingStatus.OPEN,
            created_by=consumer_user.username
        )

        db.add(new_event)
        db.flush()

        matched_count = ConsumerEventService._notify_matched_vendors(db, new_event)

        db.commit()
        db.refresh(new_event)

        return {
            "event": ConsumerEventService._build_event_response(db, new_event),
            "matched_vendors": matched_count
        }

    # --------------------------------------------------
    # NOTIFY MATCHED VENDORS
    # --------------------------------------------------
    @staticmethod
    def _notify_matched_vendors(db: Session, event: Event) -> int:
        required_services = set(event.required_services)

        vendors = db.query(Vendor).filter(
            Vendor.status == "approved",
            Vendor.inactive == False
        ).all()

        matched_vendors = []

        for vendor in vendors:
            if required_services.issubset(set(vendor.offered_services or [])):
                if vendor.service_areas:
                    if event.city not in vendor.service_areas and event.state not in vendor.service_areas:
                        continue
                matched_vendors.append(vendor)

        service_names = db.query(Service.name).filter(
            Service.id.in_(event.required_services)
        ).all()
        service_list = ", ".join(s[0] for s in service_names)

        for vendor in matched_vendors:
            db.add(VendorNotification(
                vendor_id=vendor.id,
                event_id=event.id,
                notification_type="new_event_match",
                title=f"New Event Opportunity: {event.name}",
                message=(
                    f"A new event matching your services is open for bidding.\n"
                    f"Services: {service_list}\n"
                    f"Budget: ₹{event.budget}"
                ),
                priority="high",
                category="bidding",
                action_url=f"/vendor/events/{event.id}",
                action_text="View Event & Submit Bid",
                expires_at=event.bidding_deadline,
                created_by="system"
            ))

        db.flush()
        return len(matched_vendors)

    # --------------------------------------------------
    # EVENT RESPONSE (Pydantic)
    # --------------------------------------------------
    @staticmethod
    def _build_event_response(
        db: Session,
        event: Event
    ) -> EventServiceResponse:

        category = db.query(Category).filter_by(id=event.category_id).first()
        event_type = db.query(EventType).filter_by(id=event.event_type_id).first()

        services = db.query(Service).filter(
            Service.id.in_(event.required_services)
        ).all()

        return EventServiceResponse(
            id=event.id,
            name=event.name,
            category=category.name if category else None,
            eventType=event_type.name if event_type else None,
            eventDate=event.event_date,
            location=event.location,
            city=event.city,
            state=event.state,
            expectedAttendees=event.expected_attendees,
            budget=event.budget,
            theme=event.theme,
            biddingStatus=event.bidding_status,
            biddingDeadline=event.bidding_deadline,
            status=event.status,
            requiredServices=[
                {
                    "id": s.id,
                    "name": s.name,
                    "code": s.code,
                    "icon": s.icon
                } for s in services
            ]
        )

    # --------------------------------------------------
    # MY EVENTS LIST
    # --------------------------------------------------
    @staticmethod
    def get_my_events(
        db: Session,
        consumer_user,
        status: str = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[ConsumerEventListSchema]:

        # Support both: organization-based and individual consumers
        if consumer_user.organization_id:
            # Corporate user - show all org events
            query = db.query(Event).filter(
                Event.organization_id == consumer_user.organization_id,
                Event.inactive == False
            )
        else:
            # Individual consumer - show only their created events
            query = db.query(Event).filter(
                Event.created_by == consumer_user.username,
                Event.inactive == False
            )

        if status:
            query = query.filter(Event.bidding_status == status)

        events = query.order_by(Event.created_at.desc()).offset(skip).limit(limit).all()

        result = []
        for event in events:
            bid_count = db.query(func.count(VendorBid.id)).filter(
                VendorBid.event_id == event.id,
                VendorBid.inactive == False
            ).scalar()

            result.append(ConsumerEventListSchema(
                id=event.id,
                name=event.name,
                eventDate=event.event_date.strftime("%b %d, %Y"),
                location=(
                    f"{event.city}, {event.state}"
                    if event.city and event.state
                    else event.city or event.location
                ),
                budget=event.budget or 0,
                biddingStatus=event.bidding_status,
                bidCount=bid_count,
                createdAt=event.created_at
            ))

        return result
