#!/usr/bin/env python3
"""Test booking creation to verify notification flow"""
import requests
import json

# Customer login (using the seeded customer credentials)
login_url = "http://localhost:8000/api/auth/login"
booking_url = "http://localhost:8000/api/bookings/"

# Login as customer
login_data = {
    "email": "laxmanlaxman1629@gmail.com",  # Customer from seed data
    "password": "customer123"
}

print("1. Logging in as customer...")
response = requests.post(login_url, json=login_data)
if response.status_code != 200:
    print(f"Login failed: {response.status_code} - {response.text}")
    exit(1)

token = response.json().get("access_token")
print(f"   ✓ Logged in successfully")

# Create a booking
headers = {"Authorization": f"Bearer {token}"}
booking_data = {
    "event_name": "Test Birthday Party",
    "location": "Mumbai, Maharashtra",
    "budget": 50000,
    "services": ["Food & Catering"],
    "requirements": "Need catering for 100 guests with vegetarian options",
    "status": "pending"
}

print("\n2. Creating booking...")
response = requests.post(booking_url, json=booking_data, headers=headers)
if response.status_code not in [200, 201]:
    print(f"Booking creation failed: {response.status_code}")
    print(f"Response: {response.text}")
    exit(1)

booking_result = response.json()
print(f"   ✓ Booking created: ID={booking_result.get('id')}, Name={booking_result.get('event_name')}")

# Check notifications were created
print("\n3. Checking if vendor notifications were created...")
from app.database import SessionLocal
from app.models.notification_m import Notification

db = SessionLocal()
notifs = db.query(Notification).filter(Notification.recipient_type == 'VENDOR').all()
print(f"   Total vendor notifications: {len(notifs)}")
for n in notifs[-3:]:  # Show last 3
    print(f"   - {n.title} (Type: {n.reference_type}, Read: {n.is_read})")
db.close()

print("\n✅ Test completed successfully!")
