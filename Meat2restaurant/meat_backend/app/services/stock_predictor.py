from __future__ import annotations
from datetime import datetime, timedelta
from sqlalchemy import func
from sqlalchemy.orm import Session
from typing import List, Dict, Any, TYPE_CHECKING

if TYPE_CHECKING:
    from app import models

class StockPredictorService:
    def get_sales_velocity(self, db: Session, product_id: int, days: int = 14) -> float:
        """
        Calculate avg units sold per day over the last 'days' period.
        """
        from app import models
        since_date = datetime.utcnow() - timedelta(days=days)
        
        # Sum quantities of this product in confirmed/delivered orders
        total_sold = db.query(func.sum(models.OrderItem.quantity)).join(models.Order).filter(
            models.OrderItem.product_id == product_id,
            models.Order.created_at >= since_date,
            models.Order.status.in_(["confirmed", "delivered", "packed", "out_for_delivery"])
        ).scalar() or 0
        
        return total_sold / days if days > 0 else 0

    def predict_days_remaining(self, db: Session, product_id: int) -> Dict[str, Any]:
        """
        Predicts how many days of stock are left based on velocity.
        """
        from app import models
        product = db.query(models.Product).filter(models.Product.id == product_id).first()
        if not product:
            return {"error": "Product not found"}
            
        velocity = self.get_sales_velocity(db, product_id)
        
        if velocity <= 0:
            return {
                "product_id": product_id,
                "name": product.name,
                "days_remaining": float('inf'),
                "velocity": 0,
                "stock": product.stock_quantity
            }
            
        days_left = product.stock_quantity / velocity
        
        return {
            "product_id": product_id,
            "name": product.name,
            "days_remaining": round(days_left, 1),
            "velocity": round(velocity, 2),
            "stock": product.stock_quantity
        }

    def get_low_stock_alerts(self, db: Session, threshold_days: int = 3) -> List[Dict[str, Any]]:
        """
        Returns all products that will run out within 'threshold_days'.
        """
        from app import models
        alerts = []
        products = db.query(models.Product).filter(models.Product.is_active == True).all()
        
        for p in products:
            prediction = self.predict_days_remaining(db, p.id)
            if prediction["days_remaining"] <= threshold_days:
                alerts.append(prediction)
                
        return sorted(alerts, key=lambda x: x["days_remaining"])

stock_predictor = StockPredictorService()
