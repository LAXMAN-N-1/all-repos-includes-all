"""
SMS Service for B2B Meat Platform
Supports Twilio backend
"""
from typing import Optional
from app.core.config import settings


class SMSService:
    """
    SMS service using Twilio
    """
    
    def __init__(self):
        self.account_sid = getattr(settings, 'TWILIO_ACCOUNT_SID', None)
        self.auth_token = getattr(settings, 'TWILIO_AUTH_TOKEN', None)
        self.from_number = getattr(settings, 'TWILIO_PHONE_NUMBER', None)
        self.client = None
        
        # Initialize Twilio client if credentials are available
        if self.account_sid and self.auth_token:
            try:
                from twilio.rest import Client
                self.client = Client(self.account_sid, self.auth_token)
            except ImportError:
                print("WARNING: Twilio library not installed. Run: pip install twilio")
    
    def send_sms(self, to_number: str, message: str) -> bool:
        """
        Send SMS message
        
        Args:
            to_number: Recipient phone number (E.164 format: +1234567890)
            message: SMS message content (max 160 characters recommended)
        
        Returns:
            bool: True if sent successfully, False otherwise
        """
        if not self.client:
            print("WARNING: Twilio credentials not configured. SMS not sent.")
            print(f"MOCK SMS to {to_number}: {message}")
            return False
        
        if not self.from_number:
            print("ERROR: Twilio phone number not configured")
            return False
        
        try:
            message_obj = self.client.messages.create(
                body=message,
                from_=self.from_number,
                to=to_number
            )
            
            print(f"✅ SMS sent to {to_number} (SID: {message_obj.sid})")
            return True
            
        except Exception as e:
            print(f"ERROR: Failed to send SMS to {to_number}: {str(e)}")
            return False
    
    def send_order_status_sms(self, phone_number: str, customer_name: str, order_id: int, status: str) -> bool:
        """
        Send order status update SMS
        
        Args:
            phone_number: Customer's phone number
            customer_name: Customer's name
            order_id: Order ID
            status: Order status (confirmed, packed, out_for_delivery, delivered)
        
        Returns:
            bool: True if sent successfully
        """
        status_messages = {
            'confirmed': f"Hi {customer_name}, your order #{order_id} has been confirmed and is being prepared.",
            'packed': f"Hi {customer_name}, your order #{order_id} has been packed and is ready for dispatch.",
            'out_for_delivery': f"Hi {customer_name}, your order #{order_id} is out for delivery. Expect it soon!",
            'delivered': f"Hi {customer_name}, your order #{order_id} has been delivered. Thank you for your business!"
        }
        
        message = status_messages.get(status, f"Order #{order_id} status: {status}")
        return self.send_sms(phone_number, message)
    
    def send_payment_reminder_sms(self, phone_number: str, customer_name: str, invoice_id: int, amount_due: float, due_date: str) -> bool:
        """
        Send payment reminder SMS
        
        Args:
            phone_number: Customer's phone number
            customer_name: Customer's name
            invoice_id: Invoice ID
            amount_due: Amount due
            due_date: Payment due date (formatted string)
        
        Returns:
            bool: True if sent successfully
        """
        message = f"Hi {customer_name}, reminder: Invoice #{invoice_id:05d} for ${amount_due:,.2f} is due on {due_date}. Please settle to avoid service interruption."
        return self.send_sms(phone_number, message)
    
    def send_otp_sms(self, phone_number: str, otp: str) -> bool:
        """
        Send OTP via SMS for password reset
        
        Args:
            phone_number: Customer's phone number
            otp: 6-digit OTP code
        
        Returns:
            bool: True if sent successfully
        """
        message = f"Your B2B Meat Platform password reset OTP is: {otp}. Valid for 10 minutes. Do not share this code."
        return self.send_sms(phone_number, message)
    
    def send_credit_limit_alert_sms(self, phone_number: str, customer_name: str, usage_percent: float) -> bool:
        """
        Send credit limit alert SMS
        
        Args:
            phone_number: Customer's phone number
            customer_name: Customer's name
            usage_percent: Credit usage percentage
        
        Returns:
            bool: True if sent successfully
        """
        message = f"Hi {customer_name}, you've used {usage_percent:.0f}% of your credit limit. Please make a payment to continue ordering."
        return self.send_sms(phone_number, message)


# Singleton instance
sms_service = SMSService()
