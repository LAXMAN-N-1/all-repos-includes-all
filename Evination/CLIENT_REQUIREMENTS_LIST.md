# 📋 Client Requirements Checklist - Evination

This document list all the information and policies we need from you to configure the platform correctly. Please provide the details for each section below.

---

## 🖼️ 1. Screen Content & Branding
We need to populate the apps with your specific brand voice and information.

- [ ] **App Logo**: High-resolution logo (PNG/SVG) with transparent background.
- [ ] **Brand Colors**: Primary and Secondary hex codes (e.g., #FF5733).
- [ ] **"About Us" Content**: A brief history and mission statement for the platform.
- [ ] **Contact Information**: 
    - Support Email (e.g., support@evination.com)
    - Support Phone Number
    - Physical Office Address (if applicable)
- [ ] **Onboarding Text**: Short captions (3-4 words) for the 3 intro screens users see when they first open the app.
- [ ] **Privacy Policy & Terms**: Final legal documents to be linked in the app.

---

## 💰 2. Refund Policy
How should the system handle money when a user or vendor requests a refund?

- [ ] **Refund Eligibility**: Under what conditions is a refund "Automatic" vs "Manual Review"?
- [ ] **Processing Time**: How many days does the refund take to reflect in the user's bank (e.g., 5-7 working days)?
- [ ] **Transaction Fees**: Should the payment gateway fee (approx 2%) be deducted from the refund amount or borne by the platform?

---

## 🏦 3. Vendor-Admin Profit & Share Policy
This defines how the platform makes money and how vendors are paid.

- [ ] **Platform Commission**: What percentage does the Admin take from every booking? (e.g., 10%, 15%, or a flat fee?)
- [ ] **Settlement Cycle**: When are vendors paid? (e.g., T+2 days after event completion, Weekly on Fridays, etc.)
- [ ] **Tax (GST)**: Is the commission inclusive of GST or is GST added on top?

---

## 🚫 4. Cancellation Policy
Specific rules for when a booking is cancelled.

- [ ] **User Cancellation (Early)**: If cancelled **5+ days before** the event:
    - [ ] Charge %: ______ (e.g., 0% or 5% processing fee)
- [ ] **User Cancellation (Late)**: If cancelled **within 1 day** of the event:
    - [ ] Charge %: ______ (e.g., 50% or 100% of booking amount)
- [ ] **Vendor Cancellation**: What happens if a Vendor cancels?
    - [ ] Penalty for Vendor: ______ (e.g., Fine of ₹500 or temporary suspension)
    - [ ] Compensation for User: ______ (e.g., Full refund + discount voucher)

---

## 🆔 5. KYC & Compliance Flow
How do we verify the identity of Vendors and Users?

- [ ] **KYC Method**:
    - [ ] **DigiLocker Integration**: Do you want automated real-time verification via DigiLocker? (Requires additional API setup)
    - [ ] **Manual Review**: Admin manually checks uploaded PDF/Image of Aadhar/PAN.
- [ ] **Required Documents**: List the documents for:
    - **Vendors**: (e.g., PAN, Aadhar, GST, Bank Cancelled Cheque)
    - **Users**: (e.g., Mobile OTP only, or Aadhar verification for large bookings?)

---

---

## ⚖️ 6. Legal & Compliance (Deep Dive)
To ensure the platform is legal in India and other regions.

- [ ] **Privacy Policy**: Must include how user data (location, photos) is stored.
- [ ] **Terms of Service**: Specific clauses for "Disclaimer of Service Quality" (you aren't responsible if a vendor under-delivers).
- [ ] **Data Protection (DPDP Act India)**: Who is your appointed Data Protection Officer (DPO)?
- [ ] **Platform Liability**: Does the platform take liability for event mishaps, or is it purely a marketplace?

---

## 🛠️ 7. Technical Credentials (Production)
We need these "Keys" to make the apps functional for thousands of users.

- [ ] **Razorpay Live Keys**: `Key_ID` and `Key_Secret`.
- [ ] **SMS Gateway (OTP)**: Provider details (e.g., Twilio, Msg91, or Fast2SMS) + API Keys.
- [ ] **Firebase Admin SDK**: JSON file for sending Push Notifications.
- [ ] **Google Maps API**: Billing-enabled API keys with restrictions set.

---

## ⚙️ 8. Operational & Admin Workflow
How will your internal team manage the app?

- [ ] **Vendor Approval Workflow**:
    - [ ] Auto-approve after KYC?
    - [ ] Manual review by Admin required?
- [ ] **Admin Roles**:
    - **Super Admin**: Full access.
    - **Operations Manager**: Can only approve/reject vendors.
    - **Accountant**: Can only see financial reports and settlements.
- [ ] **Dispute Resolution**: If a user complains about a vendor, what is the internal deadline to resolve it (e.g., 24 hours)?

---

## � 9. Financial & Tax Details
Critical for accounting and audits.

- [ ] **GST Logic**:
    - Platform Commission (e.g., 18% GST on the commission amount).
    - Is the vendor GST-registered? (If not, does RCM apply?)
- [ ] **TDS (Tax Deducted at Source)**: Percentage to be deducted before paying the vendor (usually 1% or 2% for e-commerce operators in India).
- [ ] **Invoicing**: Should the system generate a GST-compliant invoice for the user on behalf of the vendor?

---

## 📈 10. Marketing & Growth Logic
To help the app grow.

- [ ] **Referral Program**:
    - Amount for Referrer: ₹______
    - Amount for New User: ₹______
- [ ] **Promo Codes**:
    - First-time user discount?
    - Percentage vs. Flat discounts?
- [ ] **Loyalty Points**: Should users earn points for every ₹100 spent?

---

## 🎧 11. Support Infrastructure
Where do users go when they have a problem?

- [ ] **Support Channels**:
    - [ ] In-app Chat (requires integration like Zendesk or Intercom).
    - [ ] WhatsApp Support Number.
- [ ] **FAQ Content**: 10-15 most common questions and answers.
- [ ] **Escalation Matrix**: Level 1 (Chatbot) -> Level 2 (Human Support) -> Level 3 (Management).

---

### 📝 Final Action Step
Please review this **Deep Dive** list. Each "Checked" box means we have the data to build that feature. The more details you provide, the more "automated" the platform will become.
