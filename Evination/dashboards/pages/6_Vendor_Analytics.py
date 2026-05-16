import streamlit as st
import pandas as pd
import altair as alt
from utils.api_client import APIClient

st.set_page_config(page_title="Vendor Analytics", page_icon="📈", layout="wide")

# Styling
st.markdown("""
<style>
    .gradient-text {
        background: linear-gradient(90deg, #fdb913 0%, #e5a711 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight: 700;
    }
</style>
""", unsafe_allow_html=True)

if st.session_state.get('role') not in ['Vendor', 'Admin']:
    st.error("⛔ Access Denied.")
    st.stop()

st.markdown('<h1 class="gradient-text">Detailed Analytics</h1>', unsafe_allow_html=True)
st.caption("Deep dive into your sales and bidding performance")

# Time Filter
time_filter = st.selectbox(
    "Analysis Period",
    options=["This Week", "This Month", "This Year"],
    index=1
)
api_range_map = {"This Week": "week", "This Month": "month", "This Year": "year"}
selected_range = api_range_map[time_filter]

with st.spinner("Analyzing data..."):
    charts_data = APIClient.get_vendor_charts(selected_range)
    stats_data = APIClient.get_vendor_stats(selected_range)

if charts_data:
    c1, c2 = st.columns(2)
    
    with c1:
        st.subheader("💰 Revenue Growth")
        if charts_data['revenue_trend']:
            df = pd.DataFrame(charts_data['revenue_trend'])
            line = alt.Chart(df).mark_line(color='#fdb913', strokeWidth=3).encode(
                x='label:N',
                y='value:Q',
                tooltip=['label', 'value']
            )
            points = line.mark_circle(color='#fdb913', size=60)
            st.altair_chart(line + points, use_container_width=True)
        else:
            st.info("No revenue data for this period.")

    with c2:
        st.subheader("🎯 Bid Performance")
        if charts_data['bids_by_category']:
            df = pd.DataFrame(charts_data['bids_by_category'])
            pie = alt.Chart(df).mark_arc(innerRadius=50).encode(
                theta=alt.Theta(field="value", type="quantitative"),
                color=alt.Color(field="label", type="nominal", scale=alt.Scale(scheme='goldorange')),
                tooltip=['label', 'value']
            ).properties(height=300)
            st.altair_chart(pie, use_container_width=True)
        else:
            st.info("No bidding data for this period.")

    st.divider()
    
    # Detailed Table
    st.subheader("📋 Performance Breakdown")
    if stats_data and 'stats' in stats_data:
        df_stats = pd.DataFrame(stats_data['stats'])
        st.table(df_stats[['title', 'value', 'change_pct', 'subtext']])

st.button("Back to Dashboard", on_click=lambda: st.switch_page("pages/5_Vendor_Dashboard.py"))
