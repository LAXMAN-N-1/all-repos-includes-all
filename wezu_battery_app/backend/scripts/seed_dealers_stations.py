#!/usr/bin/env python3
"""
Seed 51 dealers with stations across India via raw SQL (avoids ORM relationship conflicts).
- 1 dealer at Kakinada (user request)
- 50 more across major Indian cities
Each dealer gets 1 swap station with ~18 available batteries.
"""
import os, sys, hashlib, bcrypt
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dotenv import load_dotenv
load_dotenv()

from sqlalchemy import create_engine, text

DB_URL = os.environ["DATABASE_URL"]
engine = create_engine(DB_URL)

LOCATIONS = [
    # Kakinada first (user-requested)
    {"city": "Kakinada",          "state": "Andhra Pradesh",   "lat": 16.9891, "lon": 82.2475, "area": "Main Road"},
    {"city": "Hyderabad",         "state": "Telangana",        "lat": 17.3850, "lon": 78.4867, "area": "Banjara Hills"},
    {"city": "Hyderabad",         "state": "Telangana",        "lat": 17.4449, "lon": 78.3498, "area": "Kukatpally"},
    {"city": "Bangalore",         "state": "Karnataka",        "lat": 12.9716, "lon": 77.5946, "area": "Indiranagar"},
    {"city": "Bangalore",         "state": "Karnataka",        "lat": 12.9279, "lon": 77.6271, "area": "Koramangala"},
    {"city": "Bangalore",         "state": "Karnataka",        "lat": 13.0358, "lon": 77.5970, "area": "Hebbal"},
    {"city": "Chennai",           "state": "Tamil Nadu",       "lat": 13.0827, "lon": 80.2707, "area": "T Nagar"},
    {"city": "Chennai",           "state": "Tamil Nadu",       "lat": 13.0418, "lon": 80.2341, "area": "Adyar"},
    {"city": "Vijayawada",        "state": "Andhra Pradesh",   "lat": 16.5062, "lon": 80.6480, "area": "MG Road"},
    {"city": "Visakhapatnam",     "state": "Andhra Pradesh",   "lat": 17.6868, "lon": 83.2185, "area": "Dwaraka Nagar"},
    {"city": "Tirupati",          "state": "Andhra Pradesh",   "lat": 13.6288, "lon": 79.4192, "area": "Balaji Nagar"},
    {"city": "Kochi",             "state": "Kerala",           "lat": 9.9312,  "lon": 76.2673, "area": "MG Road"},
    {"city": "Thiruvananthapuram","state": "Kerala",           "lat": 8.5241,  "lon": 76.9366, "area": "Palayam"},
    {"city": "Coimbatore",        "state": "Tamil Nadu",       "lat": 11.0168, "lon": 76.9558, "area": "Peelamedu"},
    {"city": "Madurai",           "state": "Tamil Nadu",       "lat": 9.9252,  "lon": 78.1198, "area": "Anna Nagar"},
    {"city": "Mumbai",            "state": "Maharashtra",      "lat": 19.0760, "lon": 72.8777, "area": "Andheri"},
    {"city": "Mumbai",            "state": "Maharashtra",      "lat": 19.1136, "lon": 72.8697, "area": "Borivali"},
    {"city": "Pune",              "state": "Maharashtra",      "lat": 18.5204, "lon": 73.8567, "area": "Kothrud"},
    {"city": "Pune",              "state": "Maharashtra",      "lat": 18.5822, "lon": 73.9197, "area": "Viman Nagar"},
    {"city": "Ahmedabad",         "state": "Gujarat",          "lat": 23.0225, "lon": 72.5714, "area": "Navrangpura"},
    {"city": "Surat",             "state": "Gujarat",          "lat": 21.1702, "lon": 72.8311, "area": "Adajan"},
    {"city": "Nagpur",            "state": "Maharashtra",      "lat": 21.1458, "lon": 79.0882, "area": "Dharampeth"},
    {"city": "Goa",               "state": "Goa",              "lat": 15.2993, "lon": 74.1240, "area": "Panaji"},
    {"city": "Delhi",             "state": "Delhi",            "lat": 28.6139, "lon": 77.2090, "area": "Connaught Place"},
    {"city": "Delhi",             "state": "Delhi",            "lat": 28.7041, "lon": 77.1025, "area": "Rohini"},
    {"city": "Delhi",             "state": "Delhi",            "lat": 28.5355, "lon": 77.3910, "area": "Noida Sector 18"},
    {"city": "Gurugram",          "state": "Haryana",          "lat": 28.4595, "lon": 77.0266, "area": "DLF Cyber City"},
    {"city": "Jaipur",            "state": "Rajasthan",        "lat": 26.9124, "lon": 75.7873, "area": "Malviya Nagar"},
    {"city": "Lucknow",           "state": "Uttar Pradesh",    "lat": 26.8467, "lon": 80.9462, "area": "Hazratganj"},
    {"city": "Chandigarh",        "state": "Punjab",           "lat": 30.7333, "lon": 76.7794, "area": "Sector 17"},
    {"city": "Amritsar",          "state": "Punjab",           "lat": 31.6340, "lon": 74.8723, "area": "Lawrence Road"},
    {"city": "Agra",              "state": "Uttar Pradesh",    "lat": 27.1767, "lon": 78.0081, "area": "Taj Nagri"},
    {"city": "Varanasi",          "state": "Uttar Pradesh",    "lat": 25.3176, "lon": 82.9739, "area": "Lanka"},
    {"city": "Kanpur",            "state": "Uttar Pradesh",    "lat": 26.4499, "lon": 80.3319, "area": "Kidwai Nagar"},
    {"city": "Kolkata",           "state": "West Bengal",      "lat": 22.5726, "lon": 88.3639, "area": "Park Street"},
    {"city": "Kolkata",           "state": "West Bengal",      "lat": 22.6203, "lon": 88.4103, "area": "Salt Lake"},
    {"city": "Bhubaneswar",       "state": "Odisha",           "lat": 20.2961, "lon": 85.8245, "area": "Saheed Nagar"},
    {"city": "Patna",             "state": "Bihar",            "lat": 25.5941, "lon": 85.1376, "area": "Fraser Road"},
    {"city": "Ranchi",            "state": "Jharkhand",        "lat": 23.3441, "lon": 85.3096, "area": "Main Road"},
    {"city": "Guwahati",          "state": "Assam",            "lat": 26.1445, "lon": 91.7362, "area": "Pan Bazar"},
    {"city": "Indore",            "state": "Madhya Pradesh",   "lat": 22.7196, "lon": 75.8577, "area": "Vijay Nagar"},
    {"city": "Bhopal",            "state": "Madhya Pradesh",   "lat": 23.2599, "lon": 77.4126, "area": "MP Nagar"},
    {"city": "Raipur",            "state": "Chhattisgarh",     "lat": 21.2514, "lon": 81.6296, "area": "Shankar Nagar"},
    {"city": "Nellore",           "state": "Andhra Pradesh",   "lat": 14.4426, "lon": 79.9865, "area": "Trunk Road"},
    {"city": "Guntur",            "state": "Andhra Pradesh",   "lat": 16.2960, "lon": 80.4365, "area": "Brodipet"},
    {"city": "Rajamahendravaram", "state": "Andhra Pradesh",   "lat": 17.0005, "lon": 81.8040, "area": "Innespet"},
    {"city": "Warangal",          "state": "Telangana",        "lat": 17.9784, "lon": 79.5941, "area": "Hanamkonda"},
    {"city": "Mangalore",         "state": "Karnataka",        "lat": 12.9141, "lon": 74.8560, "area": "Hampankatta"},
    {"city": "Mysore",            "state": "Karnataka",        "lat": 12.2958, "lon": 76.6394, "area": "Saraswathipuram"},
    {"city": "Hubli",             "state": "Karnataka",        "lat": 15.3647, "lon": 75.1240, "area": "Vidya Nagar"},
    {"city": "Tirunelveli",       "state": "Tamil Nadu",       "lat": 8.7139,  "lon": 77.7567, "area": "Palayamkottai"},
]

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def seed():
    pw_hash = hash_password("dealer@123")
    created_users = created_dealers = created_stations = 0

    with engine.begin() as conn:
        for i, loc in enumerate(LOCATIONS):
            email = f"dealer_{loc['city'].lower().replace(' ', '_').replace(',', '')}_{i+1}@wezu.com"
            phone = f"+91{9000000001 + i}"
            full_name = f"WEZU Dealer {loc['city']} {i+1}"
            business = f"WEZU Energy Station - {loc['area']}, {loc['city']}"
            address = f"{loc['area']}, {loc['city']}, {loc['state']}"
            pincode = str(500001 + i)

            # Upsert user
            row = conn.execute(text("SELECT id FROM users WHERE email = :e"), {"e": email}).first()
            if row:
                user_id = row[0]
            else:
                row = conn.execute(text("""
                    INSERT INTO users (email, phone_number, full_name, hashed_password, user_type, status,
                                       is_superuser, kyc_status, two_factor_enabled, is_email_verified,
                                       biometric_login_enabled, is_deleted, created_at, updated_at)
                    VALUES (:email, :phone, :name, :pw, 'DEALER', 'ACTIVE',
                            false, 'NOT_SUBMITTED', false, false,
                            false, false, NOW(), NOW())
                    RETURNING id
                """), {"email": email, "phone": phone, "name": full_name, "pw": pw_hash}).first()
                user_id = row[0]
                created_users += 1

            # Upsert dealer_profile
            row = conn.execute(text("SELECT id FROM dealer_profiles WHERE user_id = :u"), {"u": user_id}).first()
            if row:
                dealer_id = row[0]
            else:
                row = conn.execute(text("""
                    INSERT INTO dealer_profiles
                        (user_id, business_name, contact_person, contact_email, contact_phone,
                         address_line1, city, state, pincode, is_active, created_at)
                    VALUES
                        (:uid, :biz, :cp, :ce, :cph, :addr, :city, :state, :pin, true, NOW())
                    RETURNING id
                """), {
                    "uid": user_id, "biz": business, "cp": full_name,
                    "ce": email, "cph": phone, "addr": address,
                    "city": loc['city'], "state": loc['state'], "pin": pincode,
                }).first()
                dealer_id = row[0]
                created_dealers += 1

            # Upsert station (check by lat/lon)
            row = conn.execute(
                text("SELECT id FROM stations WHERE latitude = :lat AND longitude = :lon"),
                {"lat": loc['lat'], "lon": loc['lon']}
            ).first()
            if not row:
                rating = round(4.0 + (i % 8) * 0.1, 1)
                conn.execute(text("""
                    INSERT INTO stations
                        (name, address, city, latitude, longitude,
                         dealer_id, owner_id, station_type, total_slots,
                         available_batteries, available_slots, status, approval_status,
                         is_24x7, contact_phone, operating_hours, amenities,
                         rating, total_reviews, temperature_control, is_deleted, created_at, updated_at)
                    VALUES
                        (:name, :addr, :city, :lat, :lon,
                         :did, :oid, 'automated', 20,
                         18, 2, 'active', 'approved',
                         true, :phone, '{"all": "00:00-23:59"}', '["parking","wifi"]',
                         :rating, :reviews, false, false, NOW(), NOW())
                """), {
                    "name": f"WEZU Swap Station - {loc['area']}",
                    "addr": address, "city": loc['city'],
                    "lat": loc['lat'], "lon": loc['lon'],
                    "did": dealer_id, "oid": user_id,
                    "phone": phone, "rating": rating,
                    "reviews": 10 + i * 3,
                })
                created_stations += 1

    print(f"✓ Created {created_users} users, {created_dealers} dealers, {created_stations} stations")
    print(f"  Total locations: {len(LOCATIONS)}")

if __name__ == "__main__":
    seed()
