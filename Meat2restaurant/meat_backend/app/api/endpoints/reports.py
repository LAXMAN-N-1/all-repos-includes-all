from typing import Any, Dict, List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from sqlalchemy import func, text, cast, Date
from app.api import deps
from app import schemas, models

router = APIRouter()
from cachetools import TTLCache
report_cache = TTLCache(maxsize=1, ttl=30)
from app.features.orders.models.invoice import Invoice
from app.features.orders.models.order import OrderItem, Order
from app.features.customers.models.customer import Customer
from app.features.catalog.models.product import Product
from app.features.orders.models.order import OrderStatusUpdate

@router.get("/summary", response_model=Dict[str, Any])
def get_reports_summary(
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff)
):
    """
    Get aggregated report data for the admin panel dashboard.
    """
    cache_key = "summary"
    if cache_key in report_cache:
        return report_cache[cache_key]

    # Consolidated Order Metrics
    order_metrics = db.query(
        func.sum(Order.total_amount).filter(Order.status != "cancelled").label("total_sales"),
        func.count(Order.id).filter(Order.status != "cancelled").label("order_count"),
        func.count(Order.id).filter(Order.status.in_(["shipped", "out_for_delivery"])).label("active_deliveries"),
        func.count(Order.id).filter(Order.status == "delivered").label("fulfilled_orders"),
        func.count(Order.id).filter(Order.status == "pending").label("orders_pending")
    ).first()

    total_sales = order_metrics.total_sales or 0.0
    order_count = order_metrics.order_count or 0
    fulfilled_orders = order_metrics.fulfilled_orders or 0
    
    # Simple result dict
    result = {
        "financials": {
            "total_sales": total_sales,
            "average_order_value": total_sales / order_count if order_count > 0 else 0,
            "fulfillment_rate": (fulfilled_orders / order_count * 100) if order_count > 0 else 0.0,
        },
        "counts": {
            "orders": order_count,
            "products": db.query(Product).count(),
            "customers": db.query(Customer).count(),
            "active_deliveries": order_metrics.active_deliveries or 0,
            "orders_pending": order_metrics.orders_pending or 0,
        },
        "recent_orders": [
            {"id": o.id, "total": o.total_amount, "status": o.status, "date": o.created_at}
            for o in db.query(Order).order_by(Order.created_at.desc()).limit(5).all()
        ]
    }
    
    report_cache[cache_key] = result
    return result

@router.get("/insights", response_model=schemas.ReportsInsights)
def get_reports_insights(
    days: int = 30,
    section: str = "sales",
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff)
):
    """
    Get consolidated report data for specific sections and time range.
    """
    # Calculation range
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=days or 30)
    prev_start_date = start_date - timedelta(days=days or 30)
    
    # KPIs Calculation
    def get_kpi(query_filter, prev_filter=None):
        current = db.query(func.sum(Order.total_amount)).filter(query_filter).scalar() or 0.0
        if prev_filter:
            previous = db.query(func.sum(Order.total_amount)).filter(prev_filter).scalar() or 0.0
        else:
            previous = 0.0
        
        change_pct = ((current - previous) / previous * 100) if previous > 0 else 0.0
        return schemas.ReportsMetric(value=float(current), change_pct=float(change_pct))

    kpis = {}
    if section == "sales" or section == "revenue":
        kpis["revenue"] = get_kpi(
            (Order.created_at >= start_date) & (Order.status != "cancelled"),
            (Order.created_at >= prev_start_date) & (Order.created_at < start_date) & (Order.status != "cancelled")
        )
        # Orders count KPI
        count_curr = db.query(func.count(Order.id)).filter((Order.created_at >= start_date) & (Order.status != "cancelled")).scalar() or 0
        count_prev = db.query(func.count(Order.id)).filter((Order.created_at >= prev_start_date) & (Order.created_at < start_date) & (Order.status != "cancelled")).scalar() or 0
        change = ((count_curr - count_prev) / count_prev * 100) if count_prev > 0 else 0.0
        kpis["orders"] = schemas.ReportsMetric(value=float(count_curr), change_pct=float(change))

    # Sales series (last N days)
    sales_history = db.query(
        cast(Order.created_at, Date).label("date"),
        func.sum(Order.total_amount).label("total")
    ).filter(
        Order.status != "cancelled",
        Order.created_at >= start_date
    ).group_by(cast(Order.created_at, Date)).order_by(cast(Order.created_at, Date)).all()

    # Meta
    meta = {
        "section": section,
        "days": days,
        "generated_at": datetime.utcnow().isoformat(),
        "start_date": start_date.strftime("%Y-%m-%d"),
        "end_date": end_date.strftime("%Y-%m-%d")
    }

    # Revenue by Category
    revenue_by_cat = db.query(
        func.coalesce(Product.category, "Uncategorized").label("category"),
        func.sum(OrderItem.total_price).label("value")
    ).join(Product, OrderItem.product_id == Product.id).join(Order, OrderItem.order_id == Order.id).filter(
        Order.status != "cancelled",
        Order.created_at >= start_date
    ).group_by(Product.category).all()

    # Top Products
    top_products = db.query(
        Product.name,
        func.sum(OrderItem.quantity).label("amount")
    ).join(OrderItem).join(Order).filter(
        Order.status != "cancelled",
        Order.created_at >= start_date
    ).group_by(Product.name).order_by(func.sum(OrderItem.quantity).desc()).limit(5).all()

    return schemas.ReportsInsights(
        meta=meta,
        kpis=kpis,
        sales_series=[{"date": str(s.date), "total": float(s.total)} for s in sales_history],
        revenue_by_category=[{"name": str(r.category), "value": float(r.value)} for r in revenue_by_cat],
        top_products=[{"name": str(p.name), "value": float(p.amount)} for p in top_products],
        order_status_breakdown=[],
        # Other lists can be populated as needed
    )

@router.get("/export")
def export_reports(
    days: int = 30,
    section: str = "sales",
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_staff)
):
    """
    Export report data as CSV.
    """
    import csv
    import io
    
    # Simple export of recent orders for the section
    orders = db.query(Order).filter(Order.created_at >= (datetime.utcnow() - timedelta(days=days))).all()
    
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["ID", "Customer", "Total", "Status", "Date"])
    for o in orders:
        name = o.customer.name if o.customer else "Guest"
        writer.writerow([o.id, name, o.total_amount, o.status, o.created_at.strftime("%Y-%m-%d")])
    
    return output.getvalue()

