import streamlit as st
import time
from utils.api_client import APIClient

st.set_page_config(
    page_title="Evination Portal",
    page_icon="🚀",
    layout="wide",
    initial_sidebar_state="expanded",
)

st.title("Evination Enterprise Portal")

# Sidebar Login Simulation
st.sidebar.header("🔐 Workspace Access")

# Session State for Role
if 'role' not in st.session_state:
    st.session_state.role = None
if 'auth_token' not in st.session_state:
    st.session_state.auth_token = None

role_selection = st.sidebar.selectbox("Select Role", ["Customer", "Admin", "Vendor"])

if role_selection == "Vendor":
    # Simple Mock Login for Demo purpose (connecting to real backend auth would require a form)
    st.sidebar.info("Enter Credentials to Access Vendor Data")
    # For simplicity in this 'Intern->Production' conversion, we can allow inputting a token manually 
    # OR assume a default user for demo.
    # Let's add a Token Input for real security testing
    token_input = st.sidebar.text_input("Access Token", type="password")
    
    if st.sidebar.button("Login"):
        if token_input:
            st.session_state.auth_token = token_input
            st.session_state.role = "Vendor"
            st.sidebar.success("Logged in as Vendor")
            st.rerun()
        else:
            st.sidebar.error("Valid Token Required")
            
elif role_selection == "Admin":
    if st.sidebar.button("Enter Admin Mode"):
        st.session_state.role = "Admin"
        # Admin gets Superuser token to view Vendor/Customer data
        st.session_state.auth_token = "ADMIN_DEMO_TOKEN" 
        st.rerun()

st.markdown("---")

# Main Area Logic
if st.session_state.role == "Admin":
    st.info("You are viewing the **Admin Dashboard**. Use the sidebar to navigate to 'Admin Overview'.")
    st.markdown("### 👑 Quick Actions")
    col1, col2 = st.columns(2)
    col1.button("Manage Events")
    col2.button("Review Vendors")
    
elif st.session_state.role == "Vendor":
    st.success("Welcome, Vendor Partner!")
    st.markdown("### 🏪 Quick Actions")
    col1, col2 = st.columns(2)
    col1.button("View New Bids")
    col2.button("Update Profile")
    st.markdown("👉 Go to **Vendor Dashboard** in the sidebar to see your analytics.")

elif role_selection == "Customer":
    st.success("Welcome back, esteemed customer!")
    st.markdown("### 🎉 Plan Your Next Event")
    col1, col2 = st.columns(2)
    col1.button("Create New Event")
    col2.button("Browse Ideas")
    st.markdown("👉 Go to **Customer Dashboard** in the sidebar to for recommendations.")

st.markdown("---")
