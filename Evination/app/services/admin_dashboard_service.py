from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from app.models.vendor_order_m import VendorOrder
from app.models.event_m import Event
from app.models.vendor_m import Vendor
from app.models.user_m import User
from app.schemas.admin_dashboard_schema import FinancialStatsResponse, ActivityItem, ActivityFeedResponse
from typing import List

class AdminDashboardService:
    @staticmethod
    def get_financial_stats(db: Session) -> FinancialStatsResponse:
        # Calculate total orders value
        total_orders_value = db.query(func.sum(VendorOrder.amount)).scalar() or 0.0
        
        # Assuming platform revenue is 10% of total orders for now, or 
        # later we can have a specific logic if there is a commission field.
        # Since no explicit commission field was seen in VendorOrder, we'll use a placeholder logic.
        total_revenue = total_orders_value * 0.10 

        return FinancialStatsResponse(
            total_revenue=total_revenue,
            total_orders_value=total_orders_value
        )

    @staticmethod
    def get_recent_activity(db: Session, limit: int = 10) -> ActivityFeedResponse:
        activities = []

        # 1. New Events
        recent_events = db.query(Event).order_by(desc(Event.created_at)).limit(limit).all()
        for event in recent_events:
            activities.append(ActivityItem(
                id=f"event_{event.id}",
                type="event",
                description=f"New event created: {event.name}",
                timestamp=event.created_at,
                metadata={"event_id": event.id, "status": event.status}
            ))

        # 2. New Orders
        recent_orders = db.query(VendorOrder).order_by(desc(VendorOrder.created_at)).limit(limit).all()
        for order in recent_orders:
            activities.append(ActivityItem(
                id=f"order_{order.id}",
                type="order",
                description=f"New order placed: {order.order_ref}",
                timestamp=order.created_at,
                metadata={"amount": order.amount, "vendor_id": order.vendor_id}
            ))

        # 3. New Vendors (Users with role linked to vendor profile or checking Vendor table directly)
        recent_vendors = db.query(Vendor).order_by(desc(Vendor.created_at)).limit(limit).all()
        for vendor in recent_vendors:
            activities.append(ActivityItem(
                id=f"vendor_{vendor.id}",
                type="vendor",
                description=f"New vendor registered: {vendor.company_name}",
                timestamp=vendor.created_at,
                metadata={"status": vendor.status}
            ))

        # Sort combined list by timestamp desc
        activities.sort(key=lambda x: x.timestamp, reverse=True)

        # Return top N
        return ActivityFeedResponse(activities=activities[:limit])
