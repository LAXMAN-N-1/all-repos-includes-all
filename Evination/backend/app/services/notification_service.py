from sqlalchemy.orm import Session
from app.models.notification_m import Notification
from app.models.vendor_m import Vendor
from datetime import datetime

class NotificationService:
    def __init__(self, db: Session):
        self.db = db

    def notify_vendors_of_new_event(self, event_id: int, event_name: str, message: str):
        """Create a notification for all vendors about a new event/lead."""
        vendors = self.db.query(Vendor).all()
        
        notifications = []
        for vendor in vendors:
            notif = Notification(
                recipient_type="VENDOR",
                recipient_id=vendor.id,
                title=f"New Lead: {event_name}",
                message=message,
                reference_type="BOOKING",
                reference_id=str(event_id),
                created_at=datetime.utcnow()
            )
            notifications.append(notif)
        
        self.db.add_all(notifications)
        self.db.commit()
        return len(notifications)

    def notify_customer_of_curated_bids(self, event_id: int, customer_user_id: int, event_name: str):
        """Create a notification for a customer when admin pushes curated bids."""
        notif = Notification(
            recipient_type="USER", # Customers are logged in as users
            recipient_id=customer_user_id,
            title=f"Curated Bids Ready: {event_name}",
            message=f"Admin has shortlisted the best quotes for your event. Please review and select one to proceed.",
            reference_type="BID_SELECTION",
            reference_id=str(event_id),
            created_at=datetime.utcnow()
        )
        self.db.add(notif)
        self.db.commit()
        return notif

    def notify_vendor_of_event_assignment(self, vendor_id: int, event_id: int, event_name: str, 
                                          event_date: datetime, event_location: str, venue: str):
        """Notify vendor they won the bid with full event details."""
        notif = Notification(
            recipient_type="VENDOR",
            recipient_id=vendor_id,
            title=f"🎉 Congratulations! You won: {event_name}",
            message=f"Event Date: {event_date.strftime('%B %d, %Y')} | Location: {event_location} | Venue: {venue or 'TBD'}. Please prepare for the event and contact the customer.",
            reference_type="EVENT_ASSIGNMENT",
            reference_id=str(event_id),
            created_at=datetime.utcnow()
        )
        self.db.add(notif)
        self.db.commit()
        return notif

    def get_my_notifications(self, recipient_type: str, recipient_id: int):
        return self.db.query(Notification).filter(
            Notification.recipient_type == recipient_type,
            Notification.recipient_id == recipient_id
        ).order_by(Notification.created_at.desc()).limit(20).all()

    def mark_as_read(self, notification_id: int):
        notif = self.db.query(Notification).get(notification_id)
        if notif:
            notif.is_read = True
            notif.read_at = datetime.utcnow()
            self.db.commit()
        return notif
