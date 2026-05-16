from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.vendor_bid_m import VendorBid
from app.models.vendor_order_m import VendorOrder
from app.models.vendor_category_m import VendorCategory
from app.schemas.vendor_dashboard_schema import (
    VendorDashboardResponse,
    VendorStats,
    RevenuePoint,
    CategoryBid,
    NotificationModel,
)
import datetime


def get_vendor_dashboard(db: Session, vendor_id: int) -> VendorDashboardResponse:

    # -----------------------------
    # 1️⃣ Dynamic Stats
    # -----------------------------
    
    # Active bids = pending + submitted
    active_bids = (
        db.query(func.count(VendorBid.id))
        .filter(
            VendorBid.vendor_id == vendor_id,
            VendorBid.status.in_(["pending", "submitted"])
        )
        .scalar()
    ) or 0

    # Won contracts = bids accepted
    won_contracts = (
        db.query(func.count(VendorBid.id))
        .filter(
            VendorBid.vendor_id == vendor_id,
            VendorBid.status == "accepted"
        )
        .scalar()
    ) or 0

    # Monthly Revenue (sum of order.amount for last 30 days)
    monthly_revenue = (
        db.query(func.sum(VendorOrder.amount))
        .filter(
            VendorOrder.vendor_id == vendor_id,
            VendorOrder.confirmed_at >= datetime.datetime.now() - datetime.timedelta(days=30)
        )
        .scalar()
    ) or 0

    stats = VendorStats(
        active_bids=active_bids,
        won_contracts=won_contracts,
        monthly_revenue=monthly_revenue,
    )

    # -----------------------------
    # 2️⃣ Revenue Chart (Last 6 Months)
    # -----------------------------
    revenue_chart = []
    for i in range(6):
        month_date = datetime.date.today().replace(day=1) - datetime.timedelta(days=30 * i)
        month_name = month_date.strftime("%b")

        revenue = (
            db.query(func.sum(VendorOrder.amount))
            .filter(
                VendorOrder.vendor_id == vendor_id,
                VendorOrder.confirmed_at >= month_date.replace(day=1),
                VendorOrder.confirmed_at < (month_date.replace(day=28) + datetime.timedelta(days=4)).replace(day=1)
            )
            .scalar()
        ) or 0

        revenue_chart.append(
            RevenuePoint(month=month_name, revenue=revenue)
        )

    revenue_chart.reverse()  # Show in correct order

    # -----------------------------
    # 3️⃣ Bid Categories (Count by Category)
    # -----------------------------
    category_counts = (
        db.query(VendorBid.category_id, func.count(VendorBid.id))
        .filter(VendorBid.vendor_id == vendor_id)
        .group_by(VendorBid.category_id)
        .all()
    )

    bid_categories = [
        CategoryBid(
            category=f"Category {cat_id or 'N/A'}",
            count=count
        )
        for cat_id, count in category_counts
    ]

    # -----------------------------
    # 4️⃣ Notifications (Static Example) — Replace later with DB table
    # -----------------------------
    notifications = [
        NotificationModel(
            id=1,
            category="bidding",
            type="bid-opportunity",
            title="New Bid Opportunity",
            message="A new bid opportunity has been posted.",
            time="just now",
            urgent=False,
        ),
        NotificationModel(
            id=2,
            category="orders",
            type="order-confirmed",
            title="Order Confirmed",
            message="You received a new confirmed order.",
            time="5 minutes ago",
            urgent=True,
        ),
    ]

    return VendorDashboardResponse(
        stats=stats,
        revenue_chart=revenue_chart,
        bid_categories=bid_categories,
        notifications=notifications,
    )
