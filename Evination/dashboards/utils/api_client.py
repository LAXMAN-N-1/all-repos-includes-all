import requests
import streamlit as st

BASE_URL = "http://localhost:8000"

# Set to True to see debug info in Streamlit
DEBUG_MODE = True

class APIClient:
    
    @staticmethod
    def get_token():
        return st.session_state.get('auth_token', None)

    @staticmethod
    def get_headers():
        token = APIClient.get_token()
        if token:
            return {"Authorization": f"Bearer {token}"}
        return {}
    
    @staticmethod
    def _debug(endpoint, status_code, data=None):
        """Show debug info in Streamlit sidebar"""
        if DEBUG_MODE:
            if status_code == 200:
                st.sidebar.success(f"✅ {endpoint}: {status_code}")
            elif status_code == 401:
                st.sidebar.error(f"🔐 {endpoint}: 401 - Need valid token!")
            elif status_code == 403:
                st.sidebar.warning(f"⛔ {endpoint}: 403 - Wrong role")
            else:
                st.sidebar.warning(f"⚠️ {endpoint}: {status_code}")

    # ------------------ ADMIN ------------------
    @staticmethod
    def get_admin_stats(time_range="month"):
        endpoint = "/admin/analytics/stats"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}?time_range={time_range}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback data
            return {
                "stats": [
                    {"title": "Total Events", "value": "156", "change_pct": "+12%", "subtext": "vs last month", "icon_name": "Calendar", "color_code": "yellow"},
                    {"title": "Active Vendors", "value": "89", "change_pct": "+8%", "subtext": "total active", "icon_name": "Store", "color_code": "yellow"},
                    {"title": "Total Revenue", "value": "₹2.84Cr", "change_pct": "+18%", "subtext": "vs last month", "icon_name": "TrendingUp", "color_code": "green"},
                    {"title": "Pending Bids", "value": "24", "change_pct": "-5%", "subtext": "require action", "icon_name": "Gavel", "color_code": "orange"},
                    {"title": "Completed Events", "value": "128", "change_pct": "+15%", "subtext": "96% satisfaction", "icon_name": "CheckCircle", "color_code": "green"},
                    {"title": "Active Bookings", "value": "45", "change_pct": "+22%", "subtext": "confirmed orders", "icon_name": "Clock", "color_code": "blue"},
                    {"title": "Avg Event Value", "value": "₹1.82k", "change_pct": "+9%", "subtext": "avg order val", "icon_name": "Target", "color_code": "purple"},
                    {"title": "Conversion Rate", "value": "68%", "change_pct": "+4%", "subtext": "Industry avg: 52%", "icon_name": "Award", "color_code": "yellow"},
                ]
            }
        except Exception as e:
            st.sidebar.error(f"❌ {endpoint}: {str(e)}")
            return None

    @staticmethod
    def get_admin_revenue_trends(time_range="month"):
        endpoint = "/admin/analytics/revenue-trends"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}?time_range={time_range}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback
            return [
                {"month": "Jan", "revenue": 185000.0, "target": 180000.0},
                {"month": "Feb", "revenue": 220000.0, "target": 200000.0},
                {"month": "Mar", "revenue": 198000.0, "target": 210000.0},
                {"month": "Apr", "revenue": 248000.0, "target": 230000.0},
                {"month": "May", "revenue": 235000.0, "target": 240000.0},
                {"month": "Jun", "revenue": 284000.0, "target": 250000.0},
            ]
        except: return []
        
    @staticmethod
    def get_admin_event_analytics(time_range="month"):
        endpoint = "/admin/analytics/event-analytics"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}?time_range={time_range}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback
            return [
                {"status": "Upcoming", "count": 28, "color": "#fdb913"},
                {"status": "Ongoing", "count": 17, "color": "#e5a711"},
                {"status": "Completed", "count": 92, "color": "#10b981"},
                {"status": "Cancelled", "count": 8, "color": "#ef4444"},
            ]
        except: return []

    @staticmethod
    def get_admin_revenue_by_category():
        endpoint = "/admin/analytics/revenue-by-category"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback
            return [
                {"category": "Weddings", "revenue": 1240000, "percentage": 44},
                {"category": "Corporate", "revenue": 850000, "percentage": 30},
                {"category": "Birthdays", "revenue": 420000, "percentage": 15},
                {"category": "Conferences", "revenue": 310000, "percentage": 11},
            ]
        except: return []

    @staticmethod
    def get_admin_top_vendors():
        endpoint = "/admin/analytics/top-vendors"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback
            return [
                {"name": 'Elegant Caterers', "revenue": 485000},
                {"name": 'Grand Venues Co.', "revenue": 420000},
                {"name": 'Dream Decorators', "revenue": 385000},
                {"name": 'Elite Photography', "revenue": 340000},
                {"name": 'Sound & Lights Pro', "revenue": 295000},
            ]
        except: return []

    # ------------------ VENDOR ------------------
    @staticmethod
    def get_vendor_stats(time_range="month"):
        endpoint = "/vendor/analytics/stats"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}?time_range={time_range}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback
            return {
                "stats": [
                    {"title": "Total Orders", "value": "48", "change_pct": "+12%", "subtext": "vs last month", "icon_name": "Package", "color_code": "purple"},
                    {"title": "Total Revenue", "value": "₹540K", "change_pct": "+23%", "subtext": "vs last month", "icon_name": "DollarSign", "color_code": "green"},
                    {"title": "Active Bids", "value": "12", "change_pct": "+3", "subtext": "pending", "icon_name": "Target", "color_code": "blue"},
                    {"title": "Pending Payments", "value": "₹45K", "change_pct": "-8%", "subtext": "urgent", "icon_name": "Wallet", "color_code": "orange"},
                    {"title": "Success Rate", "value": "94%", "change_pct": "+2%", "subtext": "win rate", "icon_name": "TrendingUp", "color_code": "teal"},
                    {"title": "Rating", "value": "4.8", "change_pct": "+0.2", "subtext": "avg rating", "icon_name": "Award", "color_code": "yellow"},
                ]
            }
        except: return None

    @staticmethod
    def get_vendor_notifications():
        endpoint = "/vendor/analytics/notifications"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback
            return [
                {"id": 1, "category": "urgent", "type": "urgent", "title": "Payment Overdue", "message": "Payment for Order #ORD-2024-089 is overdue by 3 days", "time": "10m ago", "priority": "high", "order_id": "ORD-2024-089"},
                {"id": 2, "category": "payments", "type": "payment", "title": "Payment Released", "message": "Payment of ₹25,000 has been released", "time": "2h ago", "priority": "normal", "order_id": "ORD-2024-075"},
                {"id": 3, "category": "orders", "type": "order", "title": "New Order Confirmed", "message": "Order #ORD-2024-092 has been confirmed", "time": "3h ago", "priority": "normal", "order_id": "ORD-2024-092"},
            ]
        except: return []

    @staticmethod
    def get_vendor_charts(time_range="month"):
        endpoint = "/vendor/analytics/charts"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}?time_range={time_range}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback
            return {
                "revenue_trend": [
                    {"label": 'Jan', "value": 45000.0},
                    {"label": 'Feb', "value": 52000.0},
                    {"label": 'Mar', "value": 48000.0},
                    {"label": 'Apr', "value": 61000.0},
                    {"label": 'May', "value": 55000.0},
                    {"label": 'Jun', "value": 67000.0},
                ],
                "bids_by_category": [
                    {"label": 'Catering', "value": 8.0},
                    {"label": 'Decoration', "value": 5.0},
                    {"label": 'Venue', "value": 4.0},
                    {"label": 'Photography', "value": 6.0},
                ]
            }
        except: return {"revenue_trend": [], "bids_by_category": []}

    # ------------------ CONSUMER ------------------
    @staticmethod
    def get_consumer_favorites():
        endpoint = "/consumer/dashboard/favorites"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback
            return [
                {"title": 'Wedding Planning', "image_url": "https://images.unsplash.com/photo-1519741497674-611481863552?w=400", "description": 'Create your dream wedding', "rating": 4.9, "bookings_count": 1250},
                {"title": 'Engagement Party', "image_url": "https://images.unsplash.com/photo-1469371670807-013ccf25f16a?w=400", "description": 'Romantic celebrations', "rating": 4.8, "bookings_count": 856},
                {"title": 'Anniversary Celebration', "image_url": "https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400", "description": 'Elegant anniversary events', "rating": 4.7, "bookings_count": 642},
                {"title": 'Gala Dinner', "image_url": "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400", "description": 'Sophisticated dining', "rating": 4.9, "bookings_count": 923},
            ]
        except: return []

    @staticmethod
    def get_consumer_suggested():
        endpoint = "/consumer/dashboard/suggested"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback
            return [
                {"title": 'Corporate Events', "image_url": "https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=400", "description": 'Professional corporate event management', "badge_text": 'Trending'},
                {"title": 'Birthday Celebrations', "image_url": "https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=400", "description": 'Memorable birthday parties', "badge_text": 'Popular'},
                {"title": 'Conference & Seminars', "image_url": "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400", "description": 'Professional business events', "badge_text": 'New'},
            ]
        except: return []

    @staticmethod
    def get_consumer_history():
        endpoint = "/consumer/dashboard/history"
        try:
            res = requests.get(f"{BASE_URL}/api{endpoint}", headers=APIClient.get_headers())
            APIClient._debug(endpoint, res.status_code)
            if res.status_code == 200:
                return res.json()
            # Fallback
            return [
                {"title": 'Baby Shower', "image_url": "https://images.unsplash.com/photo-1513151233558-d860c5398176?w=400", "date": 'Oct 15, 2025', "status": 'Completed'},
                {"title": 'Graduation Party', "image_url": "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400", "date": 'Sep 28, 2025', "status": 'Completed'},
                {"title": 'Retirement Celebration', "image_url": "https://images.unsplash.com/photo-1496843916299-590492c751f4?w=400", "date": 'Aug 12, 2025', "status": 'Completed'},
            ]
        except: return []

    @staticmethod
    def login_vendor(username, password):
        """Simulate obtaining a token"""
        try:
            payload = {
                "username": username,
                "password": password
            }
            res = requests.post(f"{BASE_URL}/api/auth/vendor/token", data=payload)
            if res.status_code == 200:
                return res.json().get("access_token")
            return None
        except Exception as e:
            print(e)
            return None
