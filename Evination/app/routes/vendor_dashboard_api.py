from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
from datetime import datetime, timedelta

from app.database import get_db
from app.dependencies_vendor import get_current_vendor
from app.schemas.analytics_schema import (
    VendorStatsResponse, VendorChartsResponse, NotificationItem, StatItem, ChartDataPoint
)
from app.models.vendor_m import Vendor
from app.models.vendor_bid_m import VendorBid
from app.models.vendor_order_m import VendorOrder
from app.utils.logger_config import setup_logger

router = APIRouter(prefix="/api/vendor/analytics", tags=["Vendor Analytics"])
logger = setup_logger(__name__)

# Valid time range options
VALID_TIME_RANGES = {'week', 'month', 'year'}

def validate_time_range(time_range: str) -> str:
    """Validate and normalize time_range parameter."""
    if time_range not in VALID_TIME_RANGES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid time_range. Must be one of: {', '.join(VALID_TIME_RANGES)}"
        )
    return time_range

def get_start_date(time_range: str) -> datetime:
    """Calculate start date based on time range."""
    now = datetime.utcnow()
    if time_range == 'week':
        return now - timedelta(days=7)
    elif time_range == 'month':
        return now - timedelta(days=30)
    elif time_range == 'year':
        return now - timedelta(days=365)
    return now - timedelta(days=30)

@router.get("/stats", response_model=VendorStatsResponse)
def get_vendor_stats(
    time_range: str = 'month',
    db: Session = Depends(get_db),
    vendor: Vendor = Depends(get_current_vendor)
):
    """
    Get vendor statistics for the specified time range.
    Requires vendor authentication.
    """
    try:
        # Validate time_range parameter
        time_range = validate_time_range(time_range)
        
        logger.info(f"Fetching stats for vendor_id={vendor.id}, time_range={time_range}")
        start_date = get_start_date(time_range)
    
        # REAL QUERIES
        active_bids_count = db.query(VendorBid).filter(
            VendorBid.vendor_id == vendor.id,
            VendorBid.status == 'submitted',
            VendorBid.submitted_at >= start_date
        ).count()

        won_contracts_count = db.query(VendorBid).filter(
            VendorBid.vendor_id == vendor.id,
            VendorBid.status == 'accepted',
            VendorBid.selected_at >= start_date
        ).count()

        orders_count = db.query(VendorOrder).filter(
            VendorOrder.vendor_id == vendor.id,
            VendorOrder.status == 'confirmed',
            VendorOrder.confirmed_at >= start_date
        ).count()

        revenue_val = db.query(func.sum(VendorOrder.amount)).filter(
            VendorOrder.vendor_id == vendor.id,
            VendorOrder.status == 'confirmed',
            VendorOrder.confirmed_at >= start_date
        ).scalar() or 0.0
        
        pending_payment_val = db.query(func.sum(VendorOrder.amount)).filter(
            VendorOrder.vendor_id == vendor.id,
            VendorOrder.status == 'confirmed' 
        ).scalar() or 0.0

        # IF DB EMPTY use Demo Logic
        if orders_count == 0 and revenue_val == 0 and active_bids_count == 0:
            multiplier = 1.0
            if time_range == 'week': multiplier = 0.25
            elif time_range == 'year': multiplier = 12.0
            
            active_bids_count = int(12 * multiplier)
            orders_count = int(48 * multiplier)
            revenue_val = 540000.0 * multiplier
            pending_payment_val = 45000.0 * multiplier
        
        stats = [
            StatItem(title="Total Orders", value=str(orders_count), change_pct="+12%", subtext=f"vs last {time_range}", icon_name="Package", color_code="purple"),
            StatItem(title="Total Revenue", value=f"₹{revenue_val/1000:.0f}K", change_pct="+23%", subtext=f"vs last {time_range}", icon_name="DollarSign", color_code="green"),
            StatItem(title="Active Bids", value=str(active_bids_count), change_pct="+3", subtext="pending", icon_name="Target", color_code="blue"),
            StatItem(title="Pending Payments", value=f"₹{pending_payment_val/1000:.0f}K", change_pct="-8%", subtext="urgent", icon_name="Wallet", color_code="orange"),
            StatItem(title="Success Rate", value="94%", change_pct="+2%", subtext="win rate", icon_name="TrendingUp", color_code="teal"),
            StatItem(title="Rating", value="4.8", change_pct="+0.2", subtext="avg rating", icon_name="Award", color_code="yellow"),
        ]
        
        logger.info(f"Successfully fetched {len(stats)} stats for vendor_id={vendor.id}")
        return VendorStatsResponse(stats=stats)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching vendor stats for vendor_id={vendor.id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch vendor statistics"
        )

@router.get("/notifications", response_model=List[NotificationItem])
def get_notifications(
    db: Session = Depends(get_db),
    vendor: Vendor = Depends(get_current_vendor)
):
    """
    Get notifications for the authenticated vendor.
    Requires vendor authentication.
    """
    try:
        logger.info(f"Fetching notifications for vendor_id={vendor.id}")
        
        recent_orders = db.query(VendorOrder).filter(
            VendorOrder.vendor_id == vendor.id
        ).order_by(VendorOrder.confirmed_at.desc()).limit(3).all()
        
        mock_notifs = [
            {"id": 1, "category": "urgent", "type": "urgent", "title": "Payment Overdue", "message": "Payment for Order #ORD-2024-089 is overdue by 3 days", "time": "10m ago", "priority": "high", "order_id": "ORD-2024-089"},
            {"id": 2, "category": "urgent", "type": "urgent", "title": "Bid Expiring Soon", "message": "Your bid for 'Corporate Annual Gala' expires in 2 hours", "time": "1h ago", "priority": "high", "order_id": "BID-2024-156"},
            {"id": 3, "category": "payments", "type": "payment", "title": "Payment Released", "message": "Payment of ₹25,000 has been released for Order #ORD-2024-075", "time": "2h ago", "priority": "normal", "order_id": "ORD-2024-075"},
            {"id": 4, "category": "orders", "type": "order", "title": "New Order Confirmed", "message": "Order #ORD-2024-092 has been confirmed and assigned to you", "time": "3h ago", "priority": "normal", "order_id": "ORD-2024-092"},
            {"id": 5, "category": "bids", "type": "bid", "title": "Bid Accepted", "message": "Your bid for 'Wedding Reception Catering' has been accepted", "time": "5h ago", "priority": "normal", "order_id": "BID-2024-145"},
            {"id": 6, "category": "update", "type": "update", "title": "Order Updated", "message": "Order #ORD-2024-088 details have been updated by the client", "time": "1d ago", "priority": "low", "order_id": "ORD-2024-088"},
        ]

        if not recent_orders:
            logger.info(f"No recent orders found for vendor_id={vendor.id}, returning mock notifications")
            return mock_notifs

        for order in recent_orders:
            mock_notifs.append(NotificationItem(
                id=order.id + 100,
                category="orders",
                type="order",
                title="Recent Order Status",
                message=f"Order {order.order_ref} is now {order.status}",
                time="Currently",
                priority="normal",
                order_id=order.order_ref
            ))
        
        logger.info(f"Successfully fetched {len(mock_notifs)} notifications for vendor_id={vendor.id}")
        return mock_notifs
        
    except Exception as e:
        logger.error(f"Error fetching notifications for vendor_id={vendor.id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch notifications"
        )

@router.get("/charts", response_model=VendorChartsResponse)
def get_vendor_charts(
    time_range: str = 'month',
    db: Session = Depends(get_db),
    vendor: Vendor = Depends(get_current_vendor)
):
    """
    Get chart data for the authenticated vendor.
    Requires vendor authentication.
    """
    try:
        time_range = validate_time_range(time_range)
        
        logger.info(f"Fetching charts for vendor_id={vendor.id}, time_range={time_range}")
        start_date = get_start_date(time_range)
        
        orders = db.query(VendorOrder).filter(
            VendorOrder.vendor_id == vendor.id,
            VendorOrder.status == 'confirmed',
            VendorOrder.confirmed_at >= start_date
        ).all()
        
        if not orders:
            if time_range == 'week':
                revenue_chart = [
                    {"label": 'Mon', "value": 5000.0},
                    {"label": 'Tue', "value": 7200.0},
                    {"label": 'Wed', "value": 4800.0},
                    {"label": 'Thu', "value": 6100.0},
                    {"label": 'Fri', "value": 8500.0},
                ]
            else:
                 revenue_chart = [
                    {"label": 'Jan', "value": 45000.0},
                    {"label": 'Feb', "value": 52000.0},
                    {"label": 'Mar', "value": 48000.0},
                    {"label": 'Apr', "value": 61000.0},
                    {"label": 'May', "value": 55000.0},
                    {"label": 'Jun', "value": 67000.0},
                ]
            bid_chart = [
                {"label": 'Catering', "value": 8.0},
                {"label": 'Decoration', "value": 5.0},
            ]
            return VendorChartsResponse(revenue_trend=revenue_chart, bids_by_category=bid_chart)

        from collections import defaultdict
        rev_map = defaultdict(float)
        
        for o in orders:
            if not o.confirmed_at: continue
            if time_range == 'week':
                 label = o.confirmed_at.strftime("%a")
            elif time_range == 'year':
                label = o.confirmed_at.strftime("%b")
            else:
                label = o.confirmed_at.strftime("%d")
            rev_map[label] += o.amount

        revenue_chart = [{"label": k, "value": v} for k, v in rev_map.items()]
        
        bid_chart = [
            {"label": 'Catering', "value": 8.0},
            {"label": 'Decoration', "value": 5.0},
        ]

        logger.info(f"Successfully fetched charts for vendor_id={vendor.id}")
        return VendorChartsResponse(revenue_trend=revenue_chart, bids_by_category=bid_chart)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching charts for vendor_id={vendor.id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch chart data"
        )
