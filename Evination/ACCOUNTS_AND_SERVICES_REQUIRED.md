# 🌐 Complete Accounts & Services Infrastructure Guide - Evination

This document outlines **every account, service, and configuration** needed to launch the Evination platform (3 mobile apps + backend + database) in production.

---

## 📱 1. Google Play Store

### Account Requirements
- [ ] **Google Play Developer Account**
  - **Cost**: $25 USD (one-time registration fee)
  - **Required**: Valid Google Account
  - **Link**: [Google Play Console](https://play.google.com/console)
  - **Use**: Publishing all 3 Android apps (Customer, Vendor, Admin)
  - **Timeline**: Account approval takes 24-48 hours

### What You Need
- [ ] Government-issued ID (for identity verification)
- [ ] Credit/Debit card for registration fee
- [ ] Business email address
- [ ] Developer name (individual or company)

> [!IMPORTANT]
> Only **ONE** Play Store account is needed for all 3 apps. You can publish unlimited apps under a single developer account.

---

## ☁️ 2. AWS (Amazon Web Services)

### Account Requirements
- [ ] **AWS Account**
  - **Cost**: Pay-as-you-go (varies by usage)
  - **Required**: Credit card, phone number, email
  - **Link**: [AWS Sign Up](https://aws.amazon.com)
  - **Free Tier**: 12 months free tier available for new accounts

### Services You'll Use

#### 2.1 EC2 (Backend Hosting)
- [ ] **EC2 Instance** for FastAPI backend
  - **Recommended**: t3.micro or t3.small (starts at ~$8-15/month)
  - **Use**: Running your Python/FastAPI backend
  - **OS**: Ubuntu 22.04 LTS recommended

#### 2.2 RDS (Database Hosting)
- [ ] **RDS Database** (PostgreSQL or MySQL)
  - **Recommended**: db.t3.micro (starts at ~$15-20/month)
  - **Use**: Production database for all apps
  - **Storage**: Start with 20GB, scale as needed
  - **Alternative**: Self-hosted on EC2 (cheaper but more maintenance)

#### 2.3 S3 (File Storage)
- [ ] **S3 Bucket** for media files
  - **Cost**: ~$0.023 per GB/month + data transfer
  - **Use**: Storing user uploads, vendor images, event photos
  - **Required Credentials**:
    - `AWS_ACCESS_KEY_ID`
    - `AWS_SECRET_ACCESS_KEY`
    - `S3_BUCKET_NAME`

#### 2.4 Route 53 (DNS - Optional but Recommended)
- [ ] **Domain Management**
  - **Cost**: ~$0.50/month per hosted zone + domain registration
  - **Use**: Managing your custom domain (e.g., api.evination.com)

#### 2.5 AWS Certificate Manager (SSL/TLS)
- [ ] **Free SSL Certificates**
  - **Cost**: FREE
  - **Use**: HTTPS for your API endpoint

#### 2.6 Elastic IP (Optional)
- [ ] **Static IP Address**
  - **Cost**: Free when associated with running instance
  - **Use**: Fixed IP for your backend server

### AWS Cost Estimation (Monthly)
| Service | Estimated Cost |
| :--- | :--- |
| EC2 (t3.small) | $15-20 |
| RDS (db.t3.micro) | $15-20 |
| S3 Storage (10GB) | $0.23 |
| Data Transfer | $5-10 |
| **Total** | **~$35-50/month** |

> [!TIP]
> Use AWS Free Tier for 12 months if this is your first AWS account. You can run EC2 + RDS for free during this period!

---

## 💳 3. Payment Gateway - Razorpay

### Account Requirements
- [ ] **Razorpay Account**
  - **Cost**: Transaction fees only (No setup fee)
  - **Fees**: 2% + ₹0 per transaction
  - **Required**: Business documents, PAN, GST (for India)
  - **Link**: [Razorpay Sign Up](https://razorpay.com)

### What You Need
- [ ] Business PAN card
- [ ] GST registration (optional but recommended)
- [ ] Bank account for settlements
- [ ] Business proof (Certificate of Incorporation/Partnership deed)
- [ ] Identity proof of authorized signatory

### Integration Requirements
- [ ] API Keys (Test + Live mode)
  - `RAZORPAY_KEY_ID`
  - `RAZORPAY_KEY_SECRET`
- [ ] Webhook setup for payment confirmations
- [ ] Configure payment methods (UPI, Cards, Wallets, NetBanking)

> [!WARNING]
> Razorpay Test Mode is FREE. Only use Live Mode keys in production after business verification is complete.

---

## 🌍 4. Domain Name & SSL

### Domain Registration
- [ ] **Domain Name**
  - **Cost**: ₹500-1500/year (depending on TLD)
  - **Providers**: GoDaddy, Namecheap, AWS Route 53, Google Domains
  - **Recommended Domains**:
    - `evination.com` or `evination.in`
    - Subdomains: `api.evination.com`, `admin.evination.com`

### SSL Certificate
- [ ] **Option A**: AWS Certificate Manager (FREE)
- [ ] **Option B**: Let's Encrypt (FREE with Certbot)
- [ ] **Option C**: Paid SSL (₹2000-5000/year)

---

## 📧 5. Email Services (Optional but Recommended)

### For Transactional Emails
- [ ] **AWS SES (Simple Email Service)**
  - **Cost**: $0.10 per 1,000 emails
  - **Use**: Booking confirmations, password resets, notifications
  - **Alternative**: SendGrid (Free tier: 100 emails/day)

### For Business Communications
- [ ] **Google Workspace** (Optional)
  - **Cost**: ₹125-680 per user/month
  - **Use**: Professional emails (support@evination.com)
  - **Alternative**: Zoho Mail (Free for 5 users)

---

## 📊 6. Analytics & Monitoring (Optional but Valuable)

### Application Performance Monitoring
- [ ] **Sentry**
  - **Cost**: Free tier available (5K events/month)
  - **Use**: Error tracking for backend and mobile apps
  - **Link**: [sentry.io](https://sentry.io)

### Server Monitoring
- [ ] **AWS CloudWatch** (Included with AWS)
  - **Use**: Monitor EC2, RDS performance
  - **Alerts**: CPU, memory, disk usage

### Mobile Analytics
- [ ] **Google Analytics for Firebase**
  - **Cost**: FREE
  - **Use**: Track user behavior in all 3 apps
  - **Link**: [Firebase Console](https://console.firebase.google.com)

### Alternative: Mixpanel
- [ ] **Mixpanel**
  - **Cost**: Free tier: 100K monthly tracked users
  - **Use**: Advanced user analytics

---

## 🔔 7. Push Notifications (Highly Recommended)

### Firebase Cloud Messaging (FCM)
- [ ] **Firebase Account**
  - **Cost**: FREE
  - **Use**: Push notifications for all 3 apps
  - **Required**: Google Account
  - **Link**: [Firebase Console](https://console.firebase.google.com)

### Setup Requirements
- [ ] Create 3 Firebase projects (or 1 with 3 apps):
  - Evination Customer
  - Evination Vendor
  - Evination Admin
- [ ] Download `google-services.json` for each app
- [ ] Configure FCM in backend for sending notifications

---

## 🗺️ 8. Maps & Location Services

### Google Maps Platform
- [ ] **Google Cloud Account**
  - **Cost**: $200 free credit/month
  - **Required**: Credit card (won't be charged unless you exceed free tier)
  - **Use**: Maps, geocoding, location services in apps
  - **Link**: [Google Cloud Console](https://console.cloud.google.com)

### APIs to Enable
- [ ] Maps SDK for Android
- [ ] Geocoding API
- [ ] Places API (if using restaurant/venue search)

### Cost
- Map loads: First 100K free/month, then $2 per 1K loads
- Geocoding: First 40K free/month, then $5 per 1K requests

> [!TIP]
> The free tier is usually sufficient for early-stage apps. Monitor usage to avoid unexpected charges.

---

## 🛡️ 9. Security & Compliance

### SSL/TLS Certificate
- [ ] Already covered in Section 4

### Security Groups (AWS)
- [ ] Configure EC2 security groups:
  - Port 80 (HTTP) - redirect to HTTPS
  - Port 443 (HTTPS) - for API
  - Port 22 (SSH) - restricted to your IP only
  - Port 5432/3306 (Database) - restricted to EC2 only

### Environment Variables
- [ ] Securely store secrets:
  - `DATABASE_URL`
  - `SECRET_KEY` (for JWT)
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `RAZORPAY_KEY_ID`
  - `RAZORPAY_KEY_SECRET`

---

## 📦 10. CI/CD & Version Control (Highly Recommended)

### GitHub
- [ ] **GitHub Repository** (If not already using)
  - **Cost**: FREE for public/private repos
  - **Use**: Version control, collaboration
  - **Link**: [github.com](https://github.com)

### GitHub Actions (Optional)
- [ ] **CI/CD Pipeline**
  - **Cost**: 2,000 minutes/month free for private repos
  - **Use**: Automated testing, building, deployment

---

## 💼 11. Business & Legal

### Business Registration (For India)
- [ ] **GST Registration**
  - **Required**: If turnover > ₹20 lakhs/year
  - **Use**: Legal compliance, invoicing

### Privacy Policy & Terms
- [ ] **Privacy Policy Generator**
  - **Cost**: FREE (use templates)
  - **Required**: Mandatory for Play Store
  - **Host**: On your website or GitHub Pages

### Payment Gateway Compliance
- [ ] **PCI-DSS Compliance**
  - Handled by Razorpay (you don't store card data)

---

## 📝 Summary Checklist: What to Create First

### Phase 1: Immediate (Free/Low Cost)
1. [ ] Google Play Developer Account ($25)
2. [ ] AWS Account (Free Tier for 12 months)
3. [ ] GitHub Repository (FREE)
4. [ ] Firebase Account (FREE - for FCM)
5. [ ] Domain Name (~₹1000/year)

### Phase 2: Before Production Launch
6. [ ] Razorpay Account (No upfront cost)
7. [ ] Google Cloud Account (FREE tier - for Maps)
8. [ ] Email Service (AWS SES or SendGrid)
9. [ ] SSL Certificate (FREE with Let's Encrypt/AWS)

### Phase 3: Post-Launch (Optional)
10. [ ] Analytics (Firebase/Mixpanel)
11. [ ] Error Monitoring (Sentry)
12. [ ] Professional Email (Google Workspace)

---

## 💰 Total Estimated Costs (First Year)

| Item | Cost |
| :--- | :--- |
| **One-Time** | |
| Google Play Developer | $25 (₹2,100) |
| Domain Registration | ₹500-1500 |
| **Monthly (Recurring)** | |
| AWS Infrastructure | ₹3,000-4,000 |
| Razorpay Fees | 2% per transaction |
| Google Maps API | ₹0 (free tier) |
| Firebase | ₹0 (free tier) |
| **Total First Year** | **~₹40,000-50,000** |

> [!NOTE]
> Costs can be significantly lower if you:
> - Use AWS Free Tier (first 12 months)
> - Self-host database on EC2 instead of RDS
> - Use free tiers of all third-party services

---

## 🚀 Quick Start Action Plan

### Week 1: Account Creation
1. Create Google Play Developer Account
2. Sign up for AWS (start with Free Tier)
3. Create Firebase project
4. Register domain name

### Week 2: Backend Setup
5. Launch EC2 instance
6. Set up database (RDS or self-hosted)
7. Configure S3 bucket
8. Deploy backend code

### Week 3: Third-Party Integrations
9. Set up Razorpay (Test Mode first)
10. Configure Google Maps API
11. Set up Firebase Cloud Messaging
12. Get SSL certificate

### Week 4: App Deployment
13. Build signed APKs/AABs
14. Upload to Play Store (Internal Testing)
15. Test all integrations
16. Move to Closed/Open Testing

---

*Document Created: 2026-01-28*  
*Last Updated: 2026-01-28*
