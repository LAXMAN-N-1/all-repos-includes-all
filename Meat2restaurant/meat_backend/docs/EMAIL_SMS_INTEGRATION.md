# Email and SMS Service Integration Guide

## Overview
The B2B Meat Platform now includes complete email and SMS services that are ready to use once you provide credentials.

---

## Email Service

### Features
- **Multiple Backends**: Supports both SMTP and SendGrid
- **Invoice Delivery**: Automatically send invoices as PDF attachments
- **Order Confirmations**: Send order confirmation emails
- **Password Reset**: OTP delivery via email
- **HTML Templates**: Professional, responsive email templates

### Configuration

Add these variables to your `.env` file:

```bash
# Choose backend: 'smtp' or 'sendgrid'
EMAIL_BACKEND=smtp
EMAIL_FROM=noreply@b2bmeat.com
EMAIL_FROM_NAME=B2B Meat Platform

# For SMTP (Gmail, Outlook, etc.)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# OR for SendGrid
SENDGRID_API_KEY=SG.your-api-key-here
```

### Usage Examples

#### Send Invoice via API
```bash
POST /api/v1/invoices/{invoice_id}/send-email
Authorization: Bearer {staff_token}
```

#### Send Combined Statement via API
```bash
POST /api/v1/invoices/combined/{combined_id}/send-email
Authorization: Bearer {staff_token}
```

#### Programmatic Usage
```python
from app.services.email import email_service

# Send invoice
email_service.send_invoice_email(
    customer_email="customer@example.com",
    customer_name="John Doe",
    invoice_id=123,
    pdf_path="/path/to/invoice.pdf"
)

# Send order confirmation
email_service.send_order_confirmation_email(
    customer_email="customer@example.com",
    customer_name="John Doe",
    order_id=456,
    total_amount=1250.00
)
```

---

## SMS Service

### Features
- **Twilio Integration**: Industry-standard SMS delivery
- **Order Status Updates**: Automatic notifications for order progress
- **Payment Reminders**: Alert customers about due invoices
- **OTP Delivery**: Alternative to email for password reset
- **Credit Alerts**: Warn customers approaching credit limits

### Configuration

Add these variables to your `.env` file:

```bash
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890
```

### Usage Examples

#### Programmatic Usage
```python
from app.services.sms import sms_service

# Send order status update
sms_service.send_order_status_sms(
    phone_number="+1234567890",
    customer_name="John Doe",
    order_id=456,
    status="out_for_delivery"
)

# Send payment reminder
sms_service.send_payment_reminder_sms(
    phone_number="+1234567890",
    customer_name="John Doe",
    invoice_id=123,
    amount_due=1250.00,
    due_date="Feb 15, 2026"
)

# Send credit limit alert
sms_service.send_credit_limit_alert_sms(
    phone_number="+1234567890",
    customer_name="John Doe",
    usage_percent=85.0
)
```

---

## Getting Credentials

### For Email (SMTP - Gmail)
1. Go to Google Account settings
2. Enable 2-Factor Authentication
3. Generate an "App Password" for mail
4. Use that app password in `SMTP_PASSWORD`

### For Email (SendGrid)
1. Sign up at https://sendgrid.com
2. Create an API key with "Mail Send" permissions
3. Use the API key in `SENDGRID_API_KEY`

### For SMS (Twilio)
1. Sign up at https://twilio.com
2. Get your Account SID and Auth Token from the dashboard
3. Purchase a phone number or use the trial number
4. Add credentials to `.env`

---

## Fallback Behavior

**Without Credentials**: Services will print to console instead of sending
- Email: `MOCK EMAIL to customer@example.com: Subject`
- SMS: `MOCK SMS to +1234567890: Message`

**With Credentials**: Services send actual emails/SMS and log success
- Email: `✅ Email sent to customer@example.com via SMTP`
- SMS: `✅ SMS sent to +1234567890 (SID: SM...)`

---

## Testing

### Test Email Service
```python
from app.services.email import email_service

result = email_service.send_email(
    to_email="test@example.com",
    subject="Test Email",
    html_content="<h1>Hello World</h1>",
    text_content="Hello World"
)
print(f"Email sent: {result}")
```

### Test SMS Service
```python
from app.services.sms import sms_service

result = sms_service.send_sms(
    to_number="+1234567890",
    message="Test SMS from B2B Meat Platform"
)
print(f"SMS sent: {result}")
```

---

## Integration Points

### Already Integrated
- ✅ Password reset OTP (email)
- ✅ Invoice email delivery endpoints

### Ready to Integrate (just uncomment/add calls)
- Order confirmation emails (in `orders.py` create endpoint)
- Order status SMS (in `orders.py` update endpoint)
- Payment reminders (in invoice scheduler)
- Credit limit alerts (in order creation)

---

## Dependencies

Install required packages:
```bash
# For SendGrid
pip install sendgrid

# For Twilio (already installed for WhatsApp)
pip install twilio
```

---

## Security Notes

1. **Never commit `.env` file** - It contains sensitive credentials
2. **Use environment variables** - Never hardcode credentials
3. **Rotate keys regularly** - Change API keys every 90 days
4. **Monitor usage** - Check SendGrid/Twilio dashboards for unusual activity
5. **Rate limiting** - Services have built-in rate limits, monitor them

---

## Cost Estimates

### SendGrid
- Free tier: 100 emails/day
- Essentials: $19.95/month for 50,000 emails

### Twilio SMS
- $0.0075 per SMS (US)
- ~133 SMS per $1

### SMTP (Gmail)
- Free for low volume
- Google Workspace: $6/user/month for higher limits

---

## Support

For issues with:
- Email service: Check `app/services/email.py`
- SMS service: Check `app/services/sms.py`
- Configuration: Check `.env.example` for required variables
