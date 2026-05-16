from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from app.models.settlement_m import Settlement, SettlementStatus
from app.models.vendor_m import Vendor
from app.models.booking_m import Booking, BookingStatus
from app.services.finance_service import FinanceService

class SettlementService:
    def __init__(self, db: Session):
        self.db = db

    def generate_weekly_settlements(self):
        """
        Generate settlements for all vendors for the completed week.
        This would typically be a background job.
        For MVP, we can trigger via API.
        """
        # Determine Cycle (Last 7 days)
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=7)
        
        # Find all completed bookings in this range
        # Start date/end date logic needs to match 'event_date' or 'completion_date'
        # Simplified: Get all 'completed' bookings not yet settled (Need a settled flag on booking? Or just date range)
        # For MVP, let's just create a dummy settlement logic
        
        # 1. Get Active Vendors
        vendors = self.db.query(Vendor).all()
        settlements = []
        
        for vendor in vendors:
            # Find eligible bookings (Mock logic: bookings completed in range)
            # In real app: Filter Booking.vendor_id == vendor.id, Booking.status == completed, Booking.event_date in range
            # total_amount = sum([b.budget for b in bookings])
            
            total_amount = 0.0 # Placeholder
            
            if total_amount > 0:
                fin_calc = FinanceService.calculate_commission(total_amount, self.db)
                
                settlement = Settlement(
                    vendor_id=vendor.id,
                    start_date=start_date,
                    end_date=end_date,
                    total_bookings_amount=total_amount,
                    total_commission=fin_calc['commission'],
                    total_gst=fin_calc['gst_on_commission'],
                    net_payout=fin_calc['net_to_vendor'],
                    status=SettlementStatus.PROCESSING
                )
                self.db.add(settlement)
                settlements.append(settlement)
        
        self.db.commit()
        return settlements

    def get_settlements(self, vendor_id: int = None, skip: int = 0, limit: int = 100):
        query = self.db.query(Settlement)
        if vendor_id:
            query = query.filter(Settlement.vendor_id == vendor_id)
        return query.offset(skip).limit(limit).all()
