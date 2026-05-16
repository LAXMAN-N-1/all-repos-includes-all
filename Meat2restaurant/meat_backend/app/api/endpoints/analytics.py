from typing import Any, List, Dict
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func, desc

from app.api import deps
from app import models, schemas
from app.features.orders.models.order import Order, OrderItem, OrderStatusUpdate
from app.features.customers.models.customer import Customer
from app.features.catalog.models.product import Product
from app.features.customers.models.location import Location
from datetime import datetime, timedelta

router = APIRouter()

@router.get("/risk", response_model=List[Dict[str, Any]])
def get_credit_risk_analysis(
    threshold_percent: float = 0.8,
    db: Session = Depends(deps.get_db)
):
    """
    Get list of B2B customers who have used more than `threshold_percent` of their credit limit.
    Optimized: Filtering performed in database using multiplication to avoid division issues.
    """
    # Filter for B2B customers with non-zero credit limit and usage > threshold
    # Using balance >= limit * threshold to avoid division by zero or SQL issues
    risky_customers = db.query(Customer).filter(
        Customer.customer_type == "b2b",
        Customer.credit_limit > 0,
        Customer.current_balance >= Customer.credit_limit * threshold_percent
    ).order_by(desc(Customer.current_balance)).all()
    
    return [
        {
            "id": customer.id,
            "name": customer.business_name or customer.name,
            "credit_limit": customer.credit_limit,
            "current_balance": customer.current_balance,
            "usage_percent": round((customer.current_balance / customer.credit_limit) * 100, 1) if customer.credit_limit > 0 else 0,
            "status": customer.status
        } for customer in risky_customers
    ]

@router.get("/sales/trends", response_model=List[Dict[str, Any]])
def get_sales_trends(
    days: int = 30,
    db: Session = Depends(deps.get_db)
):
    """
    Get daily sales totals for the last `days`.
    """
    sales = db.query(
        func.date(Order.created_at).label("date"),
        func.sum(Order.total_amount).label("total_sales"),
        func.count(Order.id).label("order_count")
    ).filter(
        Order.status != "cancelled"
    ).group_by(
        func.date(Order.created_at)
    ).order_by(
        func.date(Order.created_at).desc()
    ).limit(days).all()
    
    return [
        {
            "date": str(s.date),
            "total_sales": s.total_sales,
            "order_count": s.order_count
        } for s in sales
    ]

@router.get("/operations/status", response_model=Dict[str, int])
def get_order_status_counts(db: Session = Depends(deps.get_db)):
    """
    Get count of orders by status.
    """
    counts = db.query(
        Order.status,
        func.count(Order.id).label("order_count")
    ).group_by(Order.status).all()
    
    # Ensure keys are strings for JSON serialization
    return {str(c.status) if c.status is not None else "unknown": c.order_count for c in counts}

@router.get("/performance", response_model=Dict[str, Any])
def get_performance_metrics(db: Session = Depends(deps.get_db)):
    """
    Get executive performance metrics (Revenue, Orders, AOV) with Period-over-Period growth.
    Comparing Last 30 Days vs Previous 30 Days.
    """
    today = datetime.utcnow()
    last_30_start = today - timedelta(days=30)
    prev_30_start = last_30_start - timedelta(days=30)
    
    def get_period_stats(start_date, end_date):
        return db.query(
            func.sum(Order.total_amount).label("revenue"),
            func.count(Order.id).label("orders"),
            func.count(func.distinct(Order.customer_id)).label("active_partners")
        ).filter(
            Order.created_at >= start_date,
            Order.created_at < end_date,
            Order.status != "cancelled"
        ).first()

    current = get_period_stats(last_30_start, today)
    previous = get_period_stats(prev_30_start, last_30_start)
    
    # Safe defaults
    curr_rev = current.revenue or 0.0
    prev_rev = previous.revenue or 0.0
    curr_orders = current.orders or 0
    prev_orders = previous.orders or 0
    
    # Calculate Deltas
    revenue_growth = ((curr_rev - prev_rev) / prev_rev * 100) if prev_rev > 0 else 100.0 if curr_rev > 0 else 0.0
    orders_growth = ((curr_orders - prev_orders) / prev_orders * 100) if prev_orders > 0 else 100.0 if curr_orders > 0 else 0.0
    
    curr_aov = curr_rev / curr_orders if curr_orders > 0 else 0
    prev_aov = prev_rev / prev_orders if prev_orders > 0 else 0
    aov_growth = ((curr_aov - prev_aov) / prev_aov * 100) if prev_aov > 0 else 0.0

    return {
        "revenue": {"value": curr_rev, "growth": round(revenue_growth, 1)},
        "orders": {"value": curr_orders, "growth": round(orders_growth, 1)},
        "aov": {"value": round(curr_aov, 2), "growth": round(aov_growth, 1)},
        "active_partners": current.active_partners or 0
    }

@router.get("/products/top", response_model=List[Dict[str, Any]])
def get_top_products_performance(
    limit: int = 10,
    db: Session = Depends(deps.get_db)
):
    """
    Get top products by Revenue share.
    """
    results = db.query(
        Product.name,
        func.sum(OrderItem.total_price).label("revenue"),
        func.sum(OrderItem.quantity).label("units")
    ).join(OrderItem).join(Order).filter(
        Order.status != "cancelled"
    ).group_by(Product.name).order_by(desc("revenue")).limit(limit).all()
    
    return [
        {
            "name": r.name,
            "revenue": r.revenue,
            "units": r.units
        } for r in results
    ]

@router.get("/customers/segments", response_model=Dict[str, int])
def get_customer_segments(db: Session = Depends(deps.get_db)):
    """
    Categorize customers into segments based on activity.
    """
    today = datetime.utcnow()
    thirty_days_ago = today - timedelta(days=30)
    ninety_days_ago = today - timedelta(days=90)

    # Subquery for last order date
    last_order_subquery = db.query(
        Order.customer_id,
        func.max(Order.created_at).label("last_order_date")
    ).group_by(Order.customer_id).subquery()

    segments = {
        "new": db.query(Customer).filter(Customer.created_at >= thirty_days_ago).count(),
        "active": db.query(Customer).join(
            last_order_subquery, Customer.id == last_order_subquery.c.customer_id
        ).filter(last_order_subquery.c.last_order_date >= thirty_days_ago).count(),
        "at_risk": db.query(Customer).join(
            last_order_subquery, Customer.id == last_order_subquery.c.customer_id
        ).filter(
            last_order_subquery.c.last_order_date < thirty_days_ago,
            last_order_subquery.c.last_order_date >= ninety_days_ago
        ).count(),
        "churned": db.query(Customer).join(
            last_order_subquery, Customer.id == last_order_subquery.c.customer_id
        ).filter(last_order_subquery.c.last_order_date < ninety_days_ago).count()
    }
    
    return segments

@router.get("/inventory/health", response_model=List[Dict[str, Any]])
def get_inventory_health(db: Session = Depends(deps.get_db)):
    """
    Get stock status for all active products.
    Categorizes items as 'critical', 'low', or 'healthy'.
    """
    products = db.query(Product).filter(Product.is_active == True).all()
    
    results = []
    for p in products:
        status = "healthy"
        if p.stock_quantity <= p.min_order_quantity:
            status = "critical"
        elif p.stock_quantity <= p.min_order_quantity * 1.5:
            status = "low"
            
        results.append({
            "id": p.id,
            "name": p.name,
            "stock": p.stock_quantity,
            "moq": p.min_order_quantity,
            "status": status
        })
    
    # Sort by status priority (critical first) then name
    priority = {"critical": 0, "low": 1, "healthy": 2}
    results.sort(key=lambda x: (priority[x['status']], x['name']))
    
    return results

@router.get("/sales/locations", response_model=List[Dict[str, Any]])
def get_sales_by_location(db: Session = Depends(deps.get_db)):
    """
    Breakdown of revenue by geographic location (City).
    Includes 'Unspecified' for orders without a linked location.
    """
    # 1. Get orders with locations
    located_sales = db.query(
        Location.city,
        func.sum(Order.total_amount).label("revenue"),
        func.count(Order.id).label("order_count")
    ).join(Order, Order.location_id == Location.id).filter(
        Order.status != "cancelled"
    ).group_by(Location.city).all()
    
    # 2. Get orders without locations
    unspecified_sales = db.query(
        func.sum(Order.total_amount).label("revenue"),
        func.count(Order.id).label("order_count")
    ).filter(
        Order.location_id == None,
        Order.status != "cancelled"
    ).first()
    
    results = [
        {
            "city": r.city,
            "revenue": round(r.revenue, 2),
            "order_count": r.order_count
        } for r in located_sales
    ]
    
    if unspecified_sales and unspecified_sales.order_count > 0:
        results.append({
            "city": "Unspecified",
            "revenue": round(unspecified_sales.revenue, 2),
            "order_count": unspecified_sales.order_count
        })
        
    # Sort by revenue
    results.sort(key=lambda x: x['revenue'], reverse=True)
    
    return results

@router.get("/customers/top-by-ltv", response_model=List[Dict[str, Any]])
def get_top_customers_by_ltv(limit: int = 10, db: Session = Depends(deps.get_db)):
    """
    List top customers by Lifetime Value.
    """
    results = db.query(
        Customer.id,
        func.coalesce(Customer.business_name, Customer.name).label("name"),
        func.sum(Order.total_amount).label("ltv"),
        func.count(Order.id).label("total_orders")
    ).join(Order).filter(
        Order.status != "cancelled"
    ).group_by(Customer.id).order_by(desc("ltv")).limit(limit).all()
    
    return [
        {
            "id": r.id,
            "name": r.name,
            "ltv": round(r.ltv, 2),
            "total_orders": r.total_orders
        } for r in results
    ]

@router.get("/fulfillment/avg-time", response_model=Dict[str, float])
def get_avg_fulfillment_time(db: Session = Depends(deps.get_db)):
    """
    Calculate the average time taken for orders to move from pending to delivered.
    """
    # This requires looking at order_status_updates or using created_at vs delivered status timestamp
    # For now, using created_at vs updated_at for delivered orders as a proxy
    # Ideally, we'd have a specific 'delivered_at' column or query the status updates table.
    
    # Let's use order_status_updates for better accuracy
    from app.features.orders.models.order import OrderStatusUpdate
    
    # Use a more generic approach in case timestampdiff is not supported
    delivery_times = db.query(Order.created_at, Order.updated_at).filter(
        Order.status == "delivered"
    ).all()
    
    if not delivery_times:
        return {"avg_hours": 0.0}
        
    total_seconds = 0
    for created, updated in delivery_times:
        if created and updated:
            diff = updated - created
            total_seconds += diff.total_seconds()
            
    avg_seconds = total_seconds / len(delivery_times)
    return {"avg_hours": round(avg_seconds / 3600, 2)}
