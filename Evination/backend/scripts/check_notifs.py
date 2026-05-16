from app.database import SessionLocal
from app.models.notification_m import Notification

db = SessionLocal()
notifs = db.query(Notification).filter(Notification.recipient_type == 'VENDOR').all()
print(f'Found {len(notifs)} vendor notifications')
for n in notifs[:5]:
    print(f'  - ID: {n.id}, Title: {n.title}, RefType: {n.reference_type}, Read: {n.is_read}')
db.close()
