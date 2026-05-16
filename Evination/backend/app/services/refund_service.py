from sqlalchemy.orm import Session
from datetime import datetime
from app.models.booking_m import Booking, BookingStatus
from app.models.refund_m import Refund, RefundStatus, RefundType
from app.services.finance_service import FinanceService

class RefundService:
    def __init__(self, db: Session):
        self.db = db

    def create_refund_request(self, booking_id: int, user_id: int, reason: str, amount: float = None, is_automatic: bool = False):
        """
        Create a refund record.
        """
        # If amount not provided, assume full amount (Need logic to fetch paid amount - using budget as placeholder for now or passed val)
        booking = self.db.query(Booking).filter(Booking.id == booking_id).first()
        if not booking:
            raise ValueError("Booking not found")
            
        final_amount = amount if amount is not None else booking.budget # Replace with Actual Paid Amount lookup later
        
        refund = Refund(
            booking_id=booking_id,
            user_id=user_id,
            amount=final_amount,
            reason=reason,
            status=RefundStatus.PROCESSED if is_automatic else RefundStatus.PENDING,
            refund_type=RefundType.AUTOMATIC if is_automatic else RefundType.MANUAL,
            processed_at=datetime.utcnow() if is_automatic else None
        )
        
        self.db.add(refund)
        self.db.commit()
        self.db.refresh(refund)
        return refund

    def process_cancellation_refund(self, booking: Booking, cancelled_by: str, current_user_id: int):
        """
        Determines if refund should be Automatic or Manual based on policy.
        """
        # 1. Vendor Cancellation -> Full Refund (Automatic)
        if cancelled_by == "VENDOR":
             return self.create_refund_request(
                 booking.id, 
                 booking.customer_id, 
                 "Vendor Cancelled", 
                 amount=booking.budget, 
                 is_automatic=True
             )
             
        # 2. User Cancellation
        # Check Work Started
        if booking.work_started:
            # Manual Review Required
            return self.create_refund_request(
                 booking.id, 
                 booking.customer_id, 
                 f"User Cancelled (Work Started) - {booking.cancellation_reason}",
                 amount=booking.budget,
                 is_automatic=False # Manual
             )

        # Check Timing
        # Parse event date logic duplicated from FinanceService, maybe helper needed
        try:
             if isinstance(booking.event_date, str):
                event_date = datetime.strptime(booking.event_date, "%Y-%m-%d").date()
             else:
                event_date = booking.event_date.date()
             days_to_event = (event_date - datetime.now().date()).days
        except:
             days_to_event = 0 # Default to Late
        
        # Late Cancellation (< 24 hrs) -> Manual Review
        if days_to_event < 1:
             return self.create_refund_request(
                 booking.id, 
                 current_user_id, 
                 "Late Cancellation (<24 hrs)", 
                 amount=booking.budget,
                 is_automatic=False
             )
             
        # Early Cancellation (> 5 days) + No Work Started -> Automatic Full Refund
        if days_to_event >= 5:
             # Deduct Gateway Charges (FinanceService doesn't handle GW logic yet, assuming full refund for MVP or add logic)
             return self.create_refund_request(
                 booking.id, 
                 current_user_id, 
                 "Early Cancellation", 
                 amount=booking.budget,
                 is_automatic=True
             )
             
        # Between 1-5 days -> Manual (Vendor Terms apply)
        return self.create_refund_request(
             booking.id, 
             current_user_id, 
             "Cancellation (1-5 Days before event)", 
             amount=booking.budget,
             is_automatic=False
         )

    def get_refunds(self, skip: int = 0, limit: int = 100):
        return self.db.query(Refund).offset(skip).limit(limit).all()

    def approve_refund(self, refund_id: int, admin_notes: str):
        refund = self.db.query(Refund).filter(Refund.id == refund_id).first()
        if refund:
            refund.status = RefundStatus.APPROVED
            refund.admin_notes = admin_notes
            self.db.commit()
            return refund
        return None
