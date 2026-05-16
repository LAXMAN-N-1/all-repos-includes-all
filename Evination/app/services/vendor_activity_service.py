# app/services/vendor_activity_service.py

from sqlalchemy.orm import Session
from sqlalchemy import desc
from typing import List
from datetime import datetime

from app.models.vendor_bid_m import VendorBid
from app.models.vendor_order_m import VendorOrder
from app.models.vendor_payment_m import VendorPayment
from app.models.user_m import User
from app.schemas.vendor_activity_schema import ActivityItem, ActivityFeedResponse


class VendorActivityService:
    
    @staticmethod
    def get_activity_feed(
        db: Session, 
        vendor_id: int, 
        user_id: int,
        skip: int = 0, 
        limit: int = 20
    ) -> ActivityFeedResponse:
        """
        Aggregates activities from multiple sources:
        - Bid submissions
        - Order received
        - Payment received
        - Login history
        """
        all_activities: List[ActivityItem] = []
        
        # 1. Get bid submissions
        bids = (
            db.query(VendorBid)
            .filter(
                VendorBid.vendor_id == vendor_id,
                VendorBid.submitted_at.isnot(None)
            )
            .all()
        )
        
        for bid in bids:
            event_name = bid.event.title if bid.event else "Unknown Event"
            all_activities.append(ActivityItem(
                id=f"bid-{bid.id}",
                type="bid_submitted",
                title="Bid Submitted",
                description=f"Submitted bid for '{event_name}'",
                timestamp=bid.submitted_at,
                icon="bid",
                metadata={
                    "bid_id": bid.id,
                    "event_id": bid.event_id,
                    "amount": float(bid.total_amount),
                    "status": bid.status
                }
            ))
        
        # 2. Get orders received
        orders = (
            db.query(VendorOrder)
            .filter(
                VendorOrder.vendor_id == vendor_id,
                VendorOrder.confirmed_at.isnot(None)
            )
            .all()
        )
        
        for order in orders:
            event_name = order.event.title if order.event else "Unknown Event"
            all_activities.append(ActivityItem(
                id=f"order-{order.id}",
                type="order_received",
                title="Order Received",
                description=f"New order for '{event_name}'",
                timestamp=order.confirmed_at,
                icon="order",
                metadata={
                    "order_id": order.id,
                    "order_ref": order.order_ref,
                    "amount": float(order.amount),
                    "status": order.status
                }
            ))
        
        # 3. Get payments received
        payments = (
            db.query(VendorPayment)
            .filter(
                VendorPayment.vendor_id == vendor_id,
                VendorPayment.status == "completed",
                VendorPayment.paid_at.isnot(None)
            )
            .all()
        )
        
        for payment in payments:
            all_activities.append(ActivityItem(
                id=f"payment-{payment.id}",
                type="payment_received",
                title="Payment Received",
                description=f"Payment of ₹{payment.amount:,.2f} received",
                timestamp=payment.paid_at,
                icon="payment",
                metadata={
                    "payment_id": payment.id,
                    "amount": float(payment.amount),
                    "payment_ref": payment.payment_ref
                }
            ))
        
        # 4. Add last login (if available)
        user = db.query(User).filter(User.id == user_id).first()
        if user and user.last_login_at:
            all_activities.append(ActivityItem(
                id=f"login-{user.id}",
                type="login",
                title="Account Login",
                description="Logged into your account",
                timestamp=user.last_login_at,
                icon="login",
                metadata=None
            ))
        
        # Sort all activities by timestamp (newest first)
        all_activities.sort(key=lambda x: x.timestamp, reverse=True)
        
        # Get total count before pagination
        total = len(all_activities)
        
        # Apply pagination
        paginated_activities = all_activities[skip:skip + limit]
        
        return ActivityFeedResponse(
            activities=paginated_activities,
            total=total,
            skip=skip,
            limit=limit
        )
