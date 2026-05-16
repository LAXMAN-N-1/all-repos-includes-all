from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from datetime import datetime, timedelta
from typing import Optional
from app.models.order import Order, OrderStatus
from app.models.prescription import Prescription, PrescriptionStatus
from app.models.inventory import InventoryBatch
from app.models.store import Store

class DashboardService:
    def __init__(self, db: Session):
        self.db = db
    
    def _get_date_range(self, period: str):
        """Get start and end dates for period"""
        now = datetime.utcnow()
        
        if period == "today":
            start = now.replace(hour=0, minute=0, second=0, microsecond=0)
            end = now
        elif period == "this_week":
            start = now - timedelta(days=now.weekday())
            start = start.replace(hour=0, minute=0, second=0, microsecond=0)
            end = now
        else:  # this_month
            start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            end = now
        
        return start, end
    
    async def get_hq_dashboard(self, period: str):
        """Get cross-store metrics for HQ Admin"""
        start_date, end_date = self._get_date_range(period)
        
        # Total orders
        total_orders = self.db.query(func.count(Order.id)).filter(
            and_(
                Order.created_at >= start_date,
                Order.created_at <= end_date,
                Order.inactive == False
            )
        ).scalar()
        
        # Total revenue
        total_revenue = self.db.query(func.sum(Order.total_amount)).filter(
            and_(
                Order.created_at >= start_date,
                Order.created_at <= end_date,
                Order.status == OrderStatus.COMPLETED,
                Order.inactive == False
            )
        ).scalar() or 0
        
        # Pending prescriptions
        pending_prescriptions = self.db.query(func.count(Prescription.id)).filter(
            and_(
                Prescription.status == PrescriptionStatus.PENDING,
                Prescription.inactive == False
            )
        ).scalar()
        
        # Active stores
        active_stores = self.db.query(func.count(Store.id)).filter(
            and_(
                Store.inactive == False,
                Store.inactive == False
            )
        ).scalar()
        
        # Store-wise performance
        store_performance = self.db.query(
            Store.name,
            func.count(Order.id).label('order_count'),
            func.sum(Order.total_amount).label('revenue')
        ).join(Order).filter(
            and_(
                Order.created_at >= start_date,
                Order.created_at <= end_date,
                Order.status == OrderStatus.COMPLETED
            )
        ).group_by(Store.id, Store.name).all()
        
        return {
            "period": period,
            "total_orders": total_orders,
            "total_revenue": float(total_revenue),
            "pending_prescriptions": pending_prescriptions,
            "active_stores": active_stores,
            "store_performance": [
                {
                    "store_name": sp[0],
                    "order_count": sp[1],
                    "revenue": float(sp[2] or 0)
                }
                for sp in store_performance
            ]
        }
    
    async def get_store_dashboard(self, store_id: int, period: str):
        """Get metrics for specific store"""
        start_date, end_date = self._get_date_range(period)
        
        # Orders by status
        orders_by_status = self.db.query(
            Order.status,
            func.count(Order.id)
        ).filter(
            and_(
                Order.store_id == store_id,
                Order.created_at >= start_date,
                Order.created_at <= end_date,
                Order.inactive == False
            )
        ).group_by(Order.status).all()
        
        # Revenue
        revenue = self.db.query(func.sum(Order.total_amount)).filter(
            and_(
                Order.store_id == store_id,
                Order.created_at >= start_date,
                Order.created_at <= end_date,
                Order.status == OrderStatus.COMPLETED
            )
        ).scalar() or 0
        
        # Inventory value
        inventory_value = self.db.query(
            func.sum(InventoryBatch.quantity * InventoryBatch.cost_price)
        ).filter(
            and_(
                InventoryBatch.store_id == store_id,
                InventoryBatch.inactive == False
            )
        ).scalar() or 0
        
        # Low stock items
        low_stock_count = self.db.query(func.count(InventoryBatch.id)).filter(
            and_(
                InventoryBatch.store_id == store_id,
                InventoryBatch.quantity < 10,  # Threshold
                InventoryBatch.inactive == False
            )
        ).scalar()
        
        # Expiring soon (next 30 days)
        expiring_soon = self.db.query(func.count(InventoryBatch.id)).filter(
            and_(
                InventoryBatch.store_id == store_id,
                InventoryBatch.expiry_date <= datetime.utcnow() + timedelta(days=30),
                InventoryBatch.expiry_date > datetime.utcnow(),
                InventoryBatch.inactive == False
            )
        ).scalar()
        
        return {
            "period": period,
            "orders_by_status": {status.value: count for status, count in orders_by_status},
            "revenue": float(revenue),
            "inventory_value": float(inventory_value),
            "low_stock_items": low_stock_count,
            "expiring_soon": expiring_soon
        }
    
    async def get_pharmacist_dashboard(self, store_id: int):
        """Get prescription queue and fulfillment metrics"""
        # Pending prescriptions
        pending = self.db.query(Prescription).filter(
            and_(
                Prescription.store_id == store_id,
                Prescription.status == PrescriptionStatus.PENDING,
                Prescription.inactive == False
            )
        ).count()
        
        # Orders awaiting fulfillment
        awaiting_fulfillment = self.db.query(Order).filter(
            and_(
                Order.store_id == store_id,
                Order.status.in_([OrderStatus.CONFIRMED, OrderStatus.PACKED]),
                Order.inactive == False
            )
        ).count()
        
        return {
            "pending_prescriptions": pending,
            "awaiting_fulfillment": awaiting_fulfillment
        }
    
    async def get_customer_dashboard(self, customer_id: int):
        """Get customer's order history and active orders"""
        # Active orders
        active_orders = self.db.query(Order).filter(
            and_(
                Order.customer_id == customer_id,
                Order.status.in_([
                    OrderStatus.PENDING,
                    OrderStatus.CONFIRMED,
                    OrderStatus.PACKED,
                    OrderStatus.READY_FOR_PICKUP
                ]),
                Order.inactive == False
            )
        ).count()
        
        # Total orders
        total_orders = self.db.query(func.count(Order.id)).filter(
            and_(
                Order.customer_id == customer_id,
                Order.inactive == False
            )
        ).scalar()
        
        return {
            "active_orders": active_orders,
            "total_orders": total_orders
        }
