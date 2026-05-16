from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.models.tax_commission_m import TaxCommissionMaster, MasterType

class FinanceService:
    # Fallback Constants
    DEFAULT_COMMISSION = 0.08
    DEFAULT_GST = 0.18
    DEFAULT_TDS = 0.01

    @staticmethod
    def get_rate(db: Session, rate_type: MasterType, default: float) -> float:
        """Fetch active rate from DB or return default."""
        rate_obj = db.query(TaxCommissionMaster).filter(
            TaxCommissionMaster.type == rate_type,
            TaxCommissionMaster.is_active == True,
            TaxCommissionMaster.effective_date <= datetime.now().date()
        ).order_by(TaxCommissionMaster.effective_date.desc()).first()
        
        return rate_obj.rate if rate_obj else default
    
    @staticmethod
    @staticmethod
    def calculate_platform_fees(amount: float, db: Session = None):
        """
        Calculates Breakdown: Commission, GST on Comm, Gateway Fee, Final Price.
        Returns Dictionary.
        """
        comm_rate = FinanceService.get_rate(db, MasterType.COMMISSION, FinanceService.DEFAULT_COMMISSION)
        gst_rate = FinanceService.get_rate(db, MasterType.TAX, FinanceService.DEFAULT_GST)
        
        commission = round(amount * comm_rate, 2)
        gst_on_comm = round(commission * gst_rate, 2)
        
        # Gateway Fee (e.g. 2% on Total currently? Or on Base? Usually on Total)
        # Simplified: Gateway Fee on (Base + Comm + GST)
        subtotal = amount + commission + gst_on_comm
        gateway_rate = 0.02 # Hardcoded or DB? Let's assume 2% standard
        gateway_fee = round(subtotal * gateway_rate, 2)
        
        final_price = round(subtotal + gateway_fee, 2)
        
        return {
            "base_amount": amount,
            "commission": commission,
            "gst_on_commission": gst_on_comm,
            "gateway_fee": gateway_fee,
            "final_price": final_price,
            "rates": {"commission": comm_rate, "gst": gst_rate}
        }

    def calculate_commission(amount: float, db: Session = None):
        # ... exists
        """
        Calculate Commission using dynamic rates if DB session provided.
        """
        commission_rate = FinanceService.DEFAULT_COMMISSION
        gst_rate = FinanceService.DEFAULT_GST
        
        if db:
            commission_rate = FinanceService.get_rate(db, MasterType.COMMISSION, FinanceService.DEFAULT_COMMISSION)
            gst_rate = FinanceService.get_rate(db, MasterType.TAX, FinanceService.DEFAULT_GST) # Assuming TAX is GST on Comm

        commission = round(amount * commission_rate, 2)
        gst = round(commission * gst_rate, 2)
        net_to_vendor = round(amount - (commission + gst), 2)
        
        return {
            "total_amount": amount,
            "commission": commission,
            "gst_on_commission": gst,
            "net_to_vendor": net_to_vendor,
            "rates_used": {
                "commission": commission_rate,
                "gst": gst_rate
            }
        }

    @staticmethod
    def calculate_cancellation_penalty(booking, cancelled_by: str):
        """
        Calculate cancellation penalty based on policy.
        """
        if not booking.event_date: 
            return 0.0
            
        # Parse event date (assuming string 'YYYY-MM-DD' or datetime)
        try:
            if isinstance(booking.event_date, str):
                event_date = datetime.strptime(booking.event_date, "%Y-%m-%d").date() # Adjust format if needed
            else:
                event_date = booking.event_date.date()
        except:
            # Fallback for safety if format differs
             return 0.0
             
        days_to_event = (event_date - datetime.now().date()).days
        # Use Booking amount/budget
        booking_amount = booking.budget if booking.budget else 0.0
        
        if cancelled_by == "USER":
            # Early Cancellation (> 5 days) -> No Penalty
            if days_to_event >= 5:
                return 0.0
            
            # Late Cancellation (< 24 hours - treated as manual/high risk, but let's define base logic)
            # Policy: "Up to 20% or vendor charge"
            if days_to_event < 1:
                return round(booking_amount * 0.20, 2)
                
            # Between 1 and 5 days? Policy implies Vendor Terms apply.
            # For automation, lets assume check Vendor Terms (Not implemented yet, so return 0 or Manual Flag)
            return 0.0 # Requires Manual Review

        elif cancelled_by == "VENDOR":
            # Vendor Penalty: Max(1000, 5% of value)
            penalty = max(1000.0, booking_amount * 0.05)
            # Cap at 10,000
            return min(penalty, 10000.0)
            
        return 0.0
