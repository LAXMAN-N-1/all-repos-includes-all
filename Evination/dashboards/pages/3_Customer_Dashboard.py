import streamlit as st
from utils.api_client import APIClient

st.set_page_config(page_title="Customer Dashboard", page_icon="👤", layout="wide")

if st.session_state.get('role') not in ['Customer', 'Admin']:
    st.error("⛔ Access Denied. Restricted to Customers.")
    st.stop()

st.title("📊 Customer Dashboard")
st.caption("Your event preferences and history")

# Fetch Data
with st.spinner("Loading your data..."):
    favorites = APIClient.get_consumer_favorites()
    suggested = APIClient.get_consumer_suggested()
    history = APIClient.get_consumer_history()

# 1. Favorites Grid
st.subheader("❤️ Favorite Events")
if favorites:
    cols = st.columns(4)
    for i, item in enumerate(favorites):
        col = cols[i % 4]
        with col:
            st.image(item['image_url'], use_container_width=True)
            st.markdown(f"**{item['title']}**")
            st.caption(item['description'])
            c_rate, c_book = st.columns(2)
            c_rate.markdown(f"⭐ {item['rating']}")
            c_book.markdown(f"📅 {item['bookings_count']}")
else:
    st.info("No favorites yet.")

st.divider()

# 2. Suggested Grid
st.subheader("✨ Suggested For You")
if suggested:
    cols_sug = st.columns(3)
    for i, item in enumerate(suggested):
        col = cols_sug[i % 3]
        with col:
            st.image(item['image_url'], use_container_width=True)
            if item.get('badge_text'):
                st.markdown(f"🔥 *{item['badge_text']}*")
            st.markdown(f"**{item['title']}**")
            st.caption(item['description'])

st.divider()

# 3. Previous Events
st.subheader("🕒 Previous Events")
if history:
    c_hist_1, c_hist_2 = st.columns(2)
    for i, item in enumerate(history):
        col = c_hist_1 if i % 2 == 0 else c_hist_2
        with col:
            h1, h2 = st.columns([1, 3])
            with h1:
                st.image(item['image_url'], width=80)
            with h2:
                st.markdown(f"**{item['title']}**")
                st.caption(f"{item['date']} • {item['status']}")
