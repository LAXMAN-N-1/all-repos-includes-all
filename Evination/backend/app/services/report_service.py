from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from app.models.event_m import Event, EventStatus
from app.models.vendor_order_m import VendorOrder
from app.models.vendor_m import Vendor
from app.models.vendor_bid_m import VendorBid
from datetime import datetime, timedelta

class ReportService:
    def __init__(self, db: Session):
        self.db = db

    def get_dashboard_stats(self, organization_id: int):
        # Event Stats
        total_events = self.db.query(func.count(Event.id)).filter(
            Event.organization_id == organization_id,
            Event.inactive == False
        ).scalar()
        
        active_events = self.db.query(func.count(Event.id)).filter(
            Event.organization_id == organization_id,
            Event.status.in_([EventStatus.PLANNING, EventStatus.CONFIRMED, EventStatus.ACTIVE]),
            Event.inactive == False
        ).scalar()
        
        completed_events = self.db.query(func.count(Event.id)).filter(
            Event.organization_id == organization_id,
            Event.status == EventStatus.COMPLETED,
            Event.inactive == False
        ).scalar()
        
        total_budget = self.db.query(func.sum(Event.budget)).filter(
            Event.organization_id == organization_id,
            Event.inactive == False
        ).scalar() or 0
        
        # Financial Stats (with explicit join fix)
        total_revenue = self.db.query(func.sum(VendorOrder.amount)).join(
            Event, VendorOrder.event_id == Event.id
        ).filter(
            Event.organization_id == organization_id,
            VendorOrder.status == 'completed'
        ).scalar() or 0
        
        # Vendor Stats
        total_vendors = self.db.query(func.count(Vendor.id)).join(Vendor.user).filter(
            Vendor.inactive == False
        ).scalar() 
        
        pending_bids = self.db.query(func.count(VendorBid.id)).join(Event).filter(
            Event.organization_id == organization_id,
            VendorBid.status == 'pending'
        ).scalar()
        
        return {
            "totalEvents": total_events,
            "activeEvents": active_events,
            "completedEvents": completed_events,
            "totalBudget": float(total_budget),
            "totalRevenue": float(total_revenue),
            "totalVendors": total_vendors,
            "pendingBids": pending_bids
        }

    def get_dashboard_charts(self, organization_id: int):
        # Events by Status
        status_counts = self.db.query(Event.status, func.count(Event.id)).filter(
            Event.organization_id == organization_id,
            Event.inactive == False
        ).group_by(Event.status).all()
        
        events_by_status = [{"label": status.value, "value": count} for status, count in status_counts]
        
        # Monthly Spend
        today = datetime.now()
        six_months_ago = today - timedelta(days=180)
        
        monthly_spend = self.db.query(
            func.strftime('%Y-%m', VendorOrder.confirmed_at).label('month'),
            func.sum(VendorOrder.amount)
        ).join(
            Event, VendorOrder.event_id == Event.id
        ).filter(
            Event.organization_id == organization_id,
            VendorOrder.confirmed_at >= six_months_ago
        ).group_by('month').all()
        
        monthly_revenue_chart = [{"label": month, "value": float(amount)} for month, amount in monthly_spend]
        
        return {
            "eventsByStatus": events_by_status,
            "budgetVsActual": [{"label": "Budget", "value": total_budget}, {"label": "Actual", "value": total_revenue}], 
            "monthlyRevenue": monthly_revenue_chart
        }

    def get_performance_report(self, organization_id: int):
        # Top Vendors by completed orders
        top_vendors = self.db.query(
            Vendor.company_name, 
            func.count(VendorOrder.id).label('orders_count'),
            func.sum(VendorOrder.amount).label('total_value')
        ).join(VendorOrder).join(
            Event, VendorOrder.event_id == Event.id
        ).filter(
            Event.organization_id == organization_id,
            VendorOrder.status == 'completed'
        ).group_by(Vendor.id).order_by(func.count(VendorOrder.id).desc()).limit(5).all()
        
        return {
            "topVendors": [{"name": v[0], "orders": v[1], "value": v[2]} for v in top_vendors]
        }

    def get_financial_report(self, organization_id: int):
        # Revenue vs Target
        total_revenue = self.db.query(func.sum(VendorOrder.amount)).join(
            Event, VendorOrder.event_id == Event.id
        ).filter(
            Event.organization_id == organization_id,
            VendorOrder.status == 'completed'
        ).scalar() or 0.0
        
        return {
            "totalRevenue": total_revenue,
            "targetRevenue": total_revenue * 1.2, 
            "growth": 15.5 
        }

    def get_profit_report(self, organization_id: int):
        from app.models.settlement_m import Settlement, SettlementStatus
        from app.models.expense_m import Expense
        
        # 1. Gross Revenue (Completed Vendor Orders)
        gross_revenue = self.db.query(func.sum(VendorOrder.amount)).join(
            Event, VendorOrder.event_id == Event.id
        ).filter(
            Event.organization_id == organization_id,
            VendorOrder.status == 'completed'
        ).scalar() or 0.0
        
        # 2. Platform Revenue (Estimated via Commission)
        # Calculate on the fly for all completed orders to ensure sync with Revenue
        orders = self.db.query(VendorOrder).join(
            Event, VendorOrder.event_id == Event.id
        ).filter(
            Event.organization_id == organization_id,
            VendorOrder.status == 'completed'
        ).all()
        
        platform_gross_profit = 0.0
        for order in orders:
            # Standard 8% Commission assumption for now or fetch from FinanceService defaults?
            # Ideally this should be stored on the order, but calculating:
            platform_gross_profit += (order.amount * 0.08)
            
        # 3. Platform Expenses
        total_expenses = self.db.query(func.sum(Expense.amount)).scalar() or 0.0
        
        # 4. Net Profit
        net_profit = platform_gross_profit - total_expenses
        
        return {
             "gross_transaction_value": gross_revenue,
             "vendor_payouts_estimated": gross_revenue - platform_gross_profit,
             "platform_revenue": platform_gross_profit,
             "platform_expenses": total_expenses,
             "net_profit": net_profit,
             "profit_margin": (net_profit / platform_gross_profit * 100) if platform_gross_profit > 0 else 0
        }
