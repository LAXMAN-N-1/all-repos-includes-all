import streamlit as st
import pandas as pd
import altair as alt
from utils.api_client import APIClient

st.set_page_config(page_title="Admin Dashboard", page_icon="👑", layout="wide")

if st.session_state.get('role') != 'Admin':
    st.error("⛔ Access Denied. Restricted to Administrators.")
    st.stop()

# Header with Filter
col1, col2 = st.columns([3, 1])
with col1:
    st.markdown("# Welcome back, Admin! 👋")
    st.caption("Here's what's happening with your platform today.")

with col2:
    time_filter = st.selectbox(
        "📅 Time Period",
        options=["This Week", "This Month", "This Year"],
        index=1
    )

api_range_map = {"This Week": "week", "This Month": "month", "This Year": "year"}
selected_range = api_range_map[time_filter]

# Fetch Data
with st.spinner("Loading analytics..."):
    stats_resp = APIClient.get_admin_stats(selected_range)
    event_analytics = APIClient.get_admin_event_analytics(selected_range)
    revenue_trends = APIClient.get_admin_revenue_trends(selected_range)
    category_revenue = APIClient.get_admin_revenue_by_category()
    top_vendors = APIClient.get_admin_top_vendors()

# 1. STATS GRID (8 Cards - 4x2)
if stats_resp and 'stats' in stats_resp:
    items = stats_resp['stats']
    
    # Row 1
    c1, c2, c3, c4 = st.columns(4)
    with c1:
        st.metric(items[0]['title'], items[0]['value'], items[0]['change_pct'])
        st.caption(items[0]['subtext'])
    with c2:
        st.metric(items[1]['title'], items[1]['value'], items[1]['change_pct'])
        st.caption(items[1]['subtext'])
    with c3:
        st.metric(items[2]['title'], items[2]['value'], items[2]['change_pct'])
        st.caption(items[2]['subtext'])
    with c4:
        st.metric(items[3]['title'], items[3]['value'], items[3]['change_pct'])
        st.caption(items[3]['subtext'])
    
    st.write("")
    
    # Row 2
    c5, c6, c7, c8 = st.columns(4)
    with c5:
        st.metric(items[4]['title'], items[4]['value'], items[4]['change_pct'])
        st.caption(items[4]['subtext'])
    with c6:
        st.metric(items[5]['title'], items[5]['value'], items[5]['change_pct'])
        st.caption(items[5]['subtext'])
    with c7:
        st.metric(items[6]['title'], items[6]['value'], items[6]['change_pct'])
        st.caption(items[6]['subtext'])
    with c8:
        st.metric(items[7]['title'], items[7]['value'], items[7]['change_pct'])
        st.caption(items[7]['subtext'])

st.divider()

# 2. CHARTS ROW 1: Revenue Trend & Event Status
col_rev, col_status = st.columns([2, 1])

with col_rev:
    st.subheader("💰 Revenue Trend")
    st.caption("Monthly revenue vs target (in ₹)")
    
    if revenue_trends:
        df_rev = pd.DataFrame(revenue_trends)
        
        if not df_rev.empty and 'month' in df_rev.columns and 'revenue' in df_rev.columns:
            # Area Chart
            area = alt.Chart(df_rev).mark_area(
                color='#fdb913',
                opacity=0.3,
                line={'color': '#fdb913', 'strokeWidth': 2}
            ).encode(
                x=alt.X('month:N', title='Month'),
                y=alt.Y('revenue:Q', title='Revenue (₹)'),
                tooltip=['month', alt.Tooltip('revenue:Q', format=',.0f'), alt.Tooltip('target:Q', format=',.0f')]
            )
            
            # Target Line
            line = alt.Chart(df_rev).mark_line(
                color='#94a3b8',
                strokeDash=[5, 5],
                strokeWidth=2
            ).encode(
                x='month:N',
                y='target:Q'
            )
            
            st.altair_chart((area + line).properties(height=300), use_container_width=True)
        else:
            st.warning("No revenue data available for the selected period")
    else:
        st.info("Loading revenue data...")
        # Show mock data as fallback
        mock_data = [
            {'month': 'Jan', 'revenue': 185000, 'target': 180000},
            {'month': 'Feb', 'revenue': 220000, 'target': 200000},
            {'month': 'Mar', 'revenue': 198000, 'target': 210000},
        ]
        df_mock = pd.DataFrame(mock_data)
        area = alt.Chart(df_mock).mark_area(
            color='#fdb913',
            opacity=0.3,
            line={'color': '#fdb913', 'strokeWidth': 2}
        ).encode(
            x=alt.X('month:N', title='Month'),
            y=alt.Y('revenue:Q', title='Revenue (₹)'),
        )
        st.altair_chart(area.properties(height=300), use_container_width=True)
        st.caption("⚠️ Showing sample data - API returned no results")

with col_status:
    st.subheader("📅 Event Status")
    st.caption("Current status of all events")
    if event_analytics:
        df_status = pd.DataFrame(event_analytics)
        bar = alt.Chart(df_status).mark_bar(
            cornerRadiusTopLeft=8,
            cornerRadiusTopRight=8
        ).encode(
            x=alt.X('status:N', title='Status'),
            y=alt.Y('count:Q', title='Count'),
            color=alt.Color('status:N', 
                scale=alt.Scale(
                    domain=['Upcoming', 'Ongoing', 'Completed', 'Cancelled'],
                    range=['#fdb913', '#e5a711', '#10b981', '#ef4444']
                ), 
                legend=None
            ),
            tooltip=['status', 'count']
        ).properties(height=300)
        st.altair_chart(bar, use_container_width=True)

st.divider()

# 3. CHARTS ROW 2: Booking Trend, Category Revenue, Upcoming Events
c1, c2, c3 = st.columns(3)

with c1:
    st.subheader("📈 Booking Trend")
    st.caption("New bookings per month")
    # Mock booking data
    booking_data = [
        {'month': 'Jan', 'bookings': 18},
        {'month': 'Feb', 'bookings': 22},
        {'month': 'Mar', 'bookings': 19},
        {'month': 'Apr', 'bookings': 28},
        {'month': 'May', 'bookings': 24},
        {'month': 'Jun', 'bookings': 31},
    ]
    df_book = pd.DataFrame(booking_data)
    
    line_chart = alt.Chart(df_book).mark_line(
        color='#fdb913',
        strokeWidth=3,
        point=alt.OverlayMarkDef(filled=True, fill='#fdb913', size=80)
    ).encode(
        x=alt.X('month:N', title='Month'),
        y=alt.Y('bookings:Q', title='Bookings'),
        tooltip=['month', 'bookings']
    ).properties(height=250)
    
    st.altair_chart(line_chart, use_container_width=True)

with c2:
    st.subheader("📂 Revenue by Category")
    st.caption("Total: ₹28.2L")
    if category_revenue:
        df_cat = pd.DataFrame(category_revenue)
        
        pie = alt.Chart(df_cat).mark_arc(
            innerRadius=60,
            outerRadius=90,
            padAngle=0.05
        ).encode(
            theta=alt.Theta("revenue:Q", stack=True),
            color=alt.Color("category:N", 
                scale=alt.Scale(
                    range=['#e67e22', '#f39c12', '#f1c40f', '#fdb913']
                ),
                legend=None
            ),
            tooltip=["category", alt.Tooltip("revenue:Q", format=',.0f'), "percentage"]
        ).properties(height=250)
        
        st.altair_chart(pie, use_container_width=True)
        
        # Legend
        for i, item in enumerate(df_cat.to_dict('records')):
            colors = ['#e67e22', '#f39c12', '#f1c40f', '#fdb913']
            st.markdown(f"<span style='color:{colors[i]}'>●</span> {item['category']} ({item['percentage']}%)", unsafe_allow_html=True)

with c3:
    st.subheader("📅 Upcoming Events")
    st.caption("Next 7 days")
    
    # Mock upcoming events
    upcoming = [
        {'name': 'Tech Summit 2025', 'date': 'Dec 15, 2025', 'type': 'Conference', 'status': 'confirmed'},
        {'name': 'Smith-Johnson Wedding', 'date': 'Dec 18, 2025', 'type': 'Wedding', 'status': 'pending'},
        {'name': 'Corporate Gala Night', 'date': 'Dec 20, 2025', 'type': 'Corporate', 'status': 'confirmed'},
        {'name': 'Birthday Celebration', 'date': 'Dec 22, 2025', 'type': 'Birthday', 'status': 'confirmed'},
    ]
    
    for event in upcoming:
        with st.container():
            col_a, col_b = st.columns([3, 1])
            with col_a:
                st.markdown(f"**{event['name']}**")
                st.caption(f"📅 {event['type']} • {event['date']}")
            with col_b:
                if event['status'] == 'confirmed':
                    st.markdown("✅ Confirmed")
                else:
                    st.markdown("⏳ Pending")

st.divider()

# 4. TOP VENDORS
st.subheader("🏆 Top Performing Vendors")
st.caption("By revenue generated (Last 6 months)")

if top_vendors:
    cols = st.columns(5)
    for i, vendor in enumerate(top_vendors):
        with cols[i]:
            # Rank badge
            if i == 0:
                st.markdown("🥇")
            elif i == 1:
                st.markdown("🥈")
            elif i == 2:
                st.markdown("🥉")
            else:
                st.markdown(f"**#{i+1}**")
            
            st.markdown(f"**{vendor['name']}**")
            st.metric("Revenue", f"₹{vendor['revenue']/100000:.1f}L")
