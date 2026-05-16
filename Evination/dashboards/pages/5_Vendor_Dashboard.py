import streamlit as st
import pandas as pd
import altair as alt
from utils.api_client import APIClient
from datetime import datetime

st.set_page_config(page_title="Vendor Dashboard", page_icon="🏪", layout="wide")

if st.session_state.get('role') not in ['Vendor', 'Admin']:
    st.error("⛔ Access Denied. Restricted to Vendor Partners.")
    st.stop()

# Styling
st.markdown("""
<style>
    .main {
        background-color: #f8f9fa;
    }
    .stMetric {
        background-color: white;
        padding: 1.5rem;
        border-radius: 1rem;
        border: 1px solid #eee;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    .gradient-text {
        background: linear-gradient(90deg, #fdb913 0%, #e5a711 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight: 700;
    }
    .notification-card {
        padding: 1rem;
        margin-bottom: 0.5rem;
        border-radius: 0.75rem;
        border-left: 4px solid #fdb913;
        background: white;
        box-shadow: 0 1px 2px rgba(0,0,0,0.05);
    }
    .urgent-card {
        background-color: #fff5f5;
        border-left: 4px solid #f56565;
        border-bottom: 1px solid #feb2b2;
    }
    .quick-action-card {
        background: linear-gradient(135deg, #fef9e7 0%, #fef3d4 100%);
        padding: 1.25rem;
        border-radius: 0.75rem;
        border: 1px solid #fde68a;
        text-align: center;
        transition: all 0.2s;
        cursor: pointer;
    }
    .quick-action-card:hover {
        border-color: #fdb913;
        box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        transform: translateY(-2px);
    }
</style>
""", unsafe_allow_html=True)

if st.session_state.get('role') not in ['Vendor', 'Admin']:
    st.error("⛔ Access Denied. Restricted to Vendors.")
    st.stop()

# Header
st.markdown('<h1 class="gradient-text">Vendor Dashboard</h1>', unsafe_allow_html=True)
st.markdown('<p style="color: #666; margin-bottom: 2rem;">Welcome back! Here\'s what\'s happening with your business today.</p>', unsafe_allow_html=True)

# State for notification filter
if 'notif_filter' not in st.session_state:
    st.session_state.notif_filter = 'all'

# Fetch Data
with st.spinner("Fetching data..."):
    # Time Range Selection for stats/charts
    time_filter = st.selectbox(
        "Display Range",
        options=["This Week", "This Month", "This Year"],
        index=1,
        key="time_range_select",
        label_visibility="collapsed"
    )
    api_range_map = {"This Week": "week", "This Month": "month", "This Year": "year"}
    selected_range = api_range_map[time_filter]

    stats_data = APIClient.get_vendor_stats(selected_range)
    charts_data = APIClient.get_vendor_charts(selected_range)
    notifications = APIClient.get_vendor_notifications()

# 1. Notifications Panel
with st.container():
    st.markdown("""
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 10px;">
            <div style="background: linear-gradient(135deg, #fdb913, #e5a711); padding: 8px; border-radius: 10px; color: white;">🔔</div>
            <h3 style="margin: 0;">Notifications</h3>
        </div>
    """, unsafe_allow_html=True)

    # Filter Tabs (Buttons)
    cols_filt = st.columns([1,1,1,1,1,4])
    if cols_filt[0].button("All", type="primary" if st.session_state.notif_filter == 'all' else "secondary"):
        st.session_state.notif_filter = 'all'
    if cols_filt[1].button("Urgent", type="primary" if st.session_state.notif_filter == 'urgent' else "secondary"):
        st.session_state.notif_filter = 'urgent'
    if cols_filt[2].button("Payments", type="primary" if st.session_state.notif_filter == 'payments' else "secondary"):
        st.session_state.notif_filter = 'payments'
    if cols_filt[3].button("Orders", type="primary" if st.session_state.notif_filter == 'orders' else "secondary"):
        st.session_state.notif_filter = 'orders'
    if cols_filt[4].button("Bids", type="primary" if st.session_state.notif_filter == 'bids' else "secondary"):
        st.session_state.notif_filter = 'bids'

    # Display Notifications
    if notifications:
        filtered_notifs = [n for n in notifications if 
            st.session_state.notif_filter == 'all' or 
            (st.session_state.notif_filter == 'urgent' and n['priority'] == 'high') or
            (st.session_state.notif_filter == 'payments' and n['category'] == 'payments') or
            (st.session_state.notif_filter == 'orders' and n['category'] == 'orders') or
            (st.session_state.notif_filter == 'bids' and n['category'] == 'bids')
        ]

        # Urgent Section (Red)
        if st.session_state.notif_filter == 'all':
            urgent = [n for n in filtered_notifs if n['priority'] == 'high']
            if urgent:
                st.markdown('<p style="color: #c53030; font-weight: 600; font-size: 0.9rem; margin: 15px 0 5px 0;">URGENT - REQUIRES IMMEDIATE ATTENTION</p>', unsafe_allow_html=True)
                for n in urgent:
                    st.markdown(f"""
                        <div class="notification-card urgent-card">
                            <div style="display: flex; justify-content: space-between;">
                                <strong style="color: #9b2c2c;">{n['title']}</strong>
                                <span style="font-size: 0.75rem; color: #e53e3e;">{n['time']}</span>
                            </div>
                            <p style="margin: 5px 0; font-size: 0.85rem; color: #742a2a;">{n['message']}</p>
                            <span style="font-size: 0.7rem; background: #fed7d7; padding: 2px 6px; border-radius: 4px;">{n['order_id']}</span>
                        </div>
                    """, unsafe_allow_html=True)
                filtered_notifs = [n for n in filtered_notifs if n['priority'] != 'high']

        # Regular Section
        for n in filtered_notifs:
            cat_color = "#fdb913"
            if n['category'] == 'payments': cat_color = "#48bb78"
            elif n['category'] == 'orders': cat_color = "#4299e1"
            elif n['category'] == 'bids': cat_color = "#9f7aea"

            st.markdown(f"""
                <div class="notification-card" style="border-left-color: {cat_color};">
                    <div style="display: flex; justify-content: space-between;">
                        <strong style="color: #444;">{n['title']}</strong>
                        <span style="font-size: 0.75rem; color: #888;">{n['time']}</span>
                    </div>
                    <p style="margin: 5px 0; font-size: 0.85rem; color: #666;">{n['message']}</p>
                    <span style="font-size: 0.7rem; background: #f0f0f0; padding: 2px 6px; border-radius: 4px;">{n['order_id']}</span>
                </div>
            """, unsafe_allow_html=True)
    else:
        st.info("No notifications at this time.")

st.write("")

# 2. Stats Grid
if stats_data and 'stats' in stats_data:
    cols = st.columns(3)
    for i, stat in enumerate(stats_data['stats']):
        with cols[i % 3]:
            st.markdown(f"""
            <div style="background: white; padding: 1.5rem; border-radius: 1rem; border: 1px solid #eee; margin-bottom: 1rem;">
                <p style="color: #666; font-size: 0.85rem; margin-bottom: 0.5rem;">{stat['title']}</p>
                <p class="gradient-text" style="font-size: 2rem; margin-bottom: 0.25rem;">{stat['value']}</p>
                <p style="color: {'#48bb78' if stat['change_pct'].startswith('+') else '#f56565'}; font-size: 0.8rem;">{stat['change_pct']} this month</p>
            </div>
            """, unsafe_allow_html=True)

# 3. Charts
c1, c2 = st.columns(2)
with c1:
    st.markdown('<h3 class="gradient-text">Revenue Overview</h3>', unsafe_allow_html=True)
    if charts_data and charts_data['revenue_trend']:
        df_rev = pd.DataFrame(charts_data['revenue_trend'])
        area = alt.Chart(df_rev).mark_area(
            color='#fdb913', opacity=0.3, line={'color': '#fdb913', 'strokeWidth': 2}
        ).encode(
            x=alt.X('label:N', title='Period'),
            y=alt.Y('value:Q', title='Revenue (₹)'),
            tooltip=['label', 'value']
        ).properties(height=300)
        st.altair_chart(area, use_container_width=True)

with c2:
    st.markdown('<h3 class="gradient-text">Active Bids by Category</h3>', unsafe_allow_html=True)
    if charts_data and charts_data['bids_by_category']:
        df_bids = pd.DataFrame(charts_data['bids_by_category'])
        bar = alt.Chart(df_bids).mark_bar(
            color='#fdb913', cornerRadiusTopLeft=8, cornerRadiusTopRight=8
        ).encode(
            x=alt.X('label:N', title='Category'),
            y=alt.Y('value:Q', title='Count'),
            tooltip=['label', 'value']
        ).properties(height=300)
        st.altair_chart(bar, use_container_width=True)

# 4. Quick Actions
st.markdown('<h3 class="gradient-text">Quick Actions</h3>', unsafe_allow_html=True)
qa1, qa2, qa3, qa4 = st.columns(4)
with qa1:
    st.page_link("pages/5_Vendor_Dashboard.py", label="View Active Bids", icon="🎯", help="Manage your bids")
with qa2:
    st.page_link("pages/5_Vendor_Dashboard.py", label="Manage Orders", icon="📦")
with qa3:
    st.page_link("pages/5_Vendor_Dashboard.py", label="Update Profile", icon="🏪")
with qa4:
    st.page_link("pages/6_Vendor_Analytics.py", label="View Analytics", icon="📈")
