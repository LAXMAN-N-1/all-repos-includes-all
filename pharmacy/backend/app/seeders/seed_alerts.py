from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.notification import Alert, AlertSeverity
from app.models.organization import Organization

def seed_alerts(db: Session):
    print("Seeding alerts...")
    
    # Get an organization for contextual alerts
    org = db.query(Organization).first()
    org_id = org.id if org else None

    alerts_data = [
        {
            "title": "High Server Load",
            "message": "Server US-EAST-1 is experiencing 95% CPU usage. Auto-scaling triggered.",
            "severity": AlertSeverity.CRITICAL,
            "icon_name": "warning_amber_rounded",
            "color_hex": "#F44336", # Red
        },
        {
            "title": "License Expiring",
            "message": f"Organization '{org.name if org else 'System'}' license expires in 3 days. Renewal email sent.",
            "severity": AlertSeverity.WARNING,
            "icon_name": "access_time_filled",
            "color_hex": "#FF9800", # Orange
            "organization_id": org_id
        },
        {
            "title": "Backup Success",
            "message": "Daily database backup completed successfully (4.2 GB). Encrypted and stored.",
            "severity": AlertSeverity.INFO,
            "icon_name": "check_circle",
            "color_hex": "#4CAF50", # Green
        },
        {
            "title": "Payment Failed",
            "message": "Subscription renewal failed for Org #8821. Card declined.",
            "severity": AlertSeverity.ERROR,
            "icon_name": "payment",
            "color_hex": "#E91E63", # Pink/Red
        },
        {
            "title": "Security Alert",
            "message": "Multiple failed login attempts detected from IP 192.168.1.104.",
            "severity": AlertSeverity.CRITICAL,
            "icon_name": "security",
            "color_hex": "#F44336",
        }
    ]

    for data in alerts_data:
        # Check if alert already exists (simple title check for seeding)
        existing = db.query(Alert).filter(Alert.title == data["title"]).first()
        if not existing:
            alert = Alert(**data)
            db.add(alert)
    
    db.commit()
    print(f"  [OK] Seeded {len(alerts_data)} alerts")

if __name__ == "__main__":
    db = SessionLocal()
    try:
        seed_alerts(db)
    finally:
        db.close()
