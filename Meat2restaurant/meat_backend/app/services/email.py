"""
Email Service for B2B Meat Platform
Supports SendGrid and SMTP backends
"""
import os
from typing import List, Optional
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
import smtplib

from app.core.config import settings


class EmailService:
    """
    Email service supporting multiple backends (SendGrid, SMTP)
    """
    
    def __init__(self):
        self.backend = getattr(settings, 'EMAIL_BACKEND', 'smtp')  # 'sendgrid' or 'smtp'
        self.from_email = getattr(settings, 'EMAIL_FROM', 'noreply@b2bmeat.com')
        self.from_name = getattr(settings, 'EMAIL_FROM_NAME', 'B2B Meat Platform')
        
        # SMTP Configuration
        self.smtp_host = getattr(settings, 'SMTP_HOST', 'smtp.gmail.com')
        self.smtp_port = getattr(settings, 'SMTP_PORT', 587)
        self.smtp_user = getattr(settings, 'SMTP_USER', None)
        self.smtp_password = getattr(settings, 'SMTP_PASSWORD', None)
        
        # SendGrid Configuration
        self.sendgrid_api_key = getattr(settings, 'SENDGRID_API_KEY', None)
    
    def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
        attachments: Optional[List[dict]] = None
    ) -> bool:
        """
        Send email using configured backend
        
        Args:
            to_email: Recipient email address
            subject: Email subject
            html_content: HTML body content
            text_content: Plain text fallback (optional)
            attachments: List of dicts with 'filename' and 'content' keys
        
        Returns:
            bool: True if sent successfully, False otherwise
        """
        try:
            if self.backend == 'sendgrid':
                return self._send_via_sendgrid(to_email, subject, html_content, text_content, attachments)
            else:
                return self._send_via_smtp(to_email, subject, html_content, text_content, attachments)
        except Exception as e:
            print(f"ERROR: Failed to send email to {to_email}: {str(e)}")
            return False
    
    def _send_via_smtp(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
        attachments: Optional[List[dict]] = None
    ) -> bool:
        """Send email via SMTP"""
        if not self.smtp_user or not self.smtp_password:
            print("WARNING: SMTP credentials not configured. Email not sent.")
            print(f"MOCK EMAIL to {to_email}: {subject}")
            return False
        
        try:
            # Create message
            msg = MIMEMultipart('alternative')
            msg['Subject'] = subject
            msg['From'] = f"{self.from_name} <{self.from_email}>"
            msg['To'] = to_email
            
            # Add text and HTML parts
            if text_content:
                msg.attach(MIMEText(text_content, 'plain'))
            msg.attach(MIMEText(html_content, 'html'))
            
            # Add attachments
            if attachments:
                for attachment in attachments:
                    part = MIMEApplication(attachment['content'])
                    part.add_header('Content-Disposition', 'attachment', filename=attachment['filename'])
                    msg.attach(part)
            
            # Send via SMTP
            with smtplib.SMTP(self.smtp_host, self.smtp_port) as server:
                server.starttls()
                server.login(self.smtp_user, self.smtp_password)
                server.send_message(msg)
            
            print(f"✅ Email sent to {to_email} via SMTP")
            return True
            
        except Exception as e:
            print(f"ERROR: SMTP send failed: {str(e)}")
            return False
    
    def _send_via_sendgrid(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        text_content: Optional[str] = None,
        attachments: Optional[List[dict]] = None
    ) -> bool:
        """Send email via SendGrid API"""
        if not self.sendgrid_api_key:
            print("WARNING: SendGrid API key not configured. Email not sent.")
            print(f"MOCK EMAIL to {to_email}: {subject}")
            return False
        
        try:
            from sendgrid import SendGridAPIClient
            from sendgrid.helpers.mail import Mail, Attachment, FileContent, FileName, FileType, Disposition
            import base64
            
            # Create message
            message = Mail(
                from_email=(self.from_email, self.from_name),
                to_emails=to_email,
                subject=subject,
                html_content=html_content
            )
            
            if text_content:
                message.plain_text_content = text_content
            
            # Add attachments
            if attachments:
                for attachment in attachments:
                    encoded = base64.b64encode(attachment['content']).decode()
                    attached_file = Attachment(
                        FileContent(encoded),
                        FileName(attachment['filename']),
                        FileType('application/pdf'),
                        Disposition('attachment')
                    )
                    message.add_attachment(attached_file)
            
            # Send
            sg = SendGridAPIClient(self.sendgrid_api_key)
            response = sg.send(message)
            
            print(f"✅ Email sent to {to_email} via SendGrid (Status: {response.status_code})")
            return True
            
        except ImportError:
            print("ERROR: SendGrid library not installed. Run: pip install sendgrid")
            return False
        except Exception as e:
            print(f"ERROR: SendGrid send failed: {str(e)}")
            return False
    
    def send_invoice_email(self, customer_email: str, customer_name: str, invoice_id: int, pdf_path: str) -> bool:
        """
        Send invoice PDF via email
        
        Args:
            customer_email: Customer's email address
            customer_name: Customer's name
            invoice_id: Invoice ID
            pdf_path: Absolute path to PDF file
        
        Returns:
            bool: True if sent successfully
        """
        subject = f"Invoice #{invoice_id:05d} - B2B Meat Platform"
        
        html_content = f"""
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h2 style="color: #FF4B4B;">Invoice #{invoice_id:05d}</h2>
                <p>Dear {customer_name},</p>
                <p>Please find attached your invoice for recent orders.</p>
                <p>You can also download it from your account dashboard at any time.</p>
                <p>If you have any questions, please don't hesitate to contact us.</p>
                <br>
                <p>Best regards,<br>
                <strong>B2B Meat Platform Team</strong></p>
                <hr style="border: 1px solid #eee; margin: 20px 0;">
                <p style="font-size: 12px; color: #666;">
                    This is an automated email. Please do not reply directly to this message.
                </p>
            </div>
        </body>
        </html>
        """
        
        text_content = f"""
        Invoice #{invoice_id:05d}
        
        Dear {customer_name},
        
        Please find attached your invoice for recent orders.
        
        You can also download it from your account dashboard at any time.
        
        If you have any questions, please don't hesitate to contact us.
        
        Best regards,
        B2B Meat Platform Team
        """
        
        # Read PDF file
        try:
            with open(pdf_path, 'rb') as f:
                pdf_content = f.read()
            
            attachments = [{
                'filename': f'invoice_{invoice_id:05d}.pdf',
                'content': pdf_content
            }]
            
            return self.send_email(customer_email, subject, html_content, text_content, attachments)
        except FileNotFoundError:
            print(f"ERROR: PDF file not found: {pdf_path}")
            return False
    
    def send_order_confirmation_email(self, customer_email: str, customer_name: str, order_id: int, total_amount: float) -> bool:
        """Send order confirmation email"""
        subject = f"Order Confirmation #{order_id} - B2B Meat Platform"
        
        html_content = f"""
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h2 style="color: #4CAF50;">Order Confirmed!</h2>
                <p>Dear {customer_name},</p>
                <p>Your order has been successfully placed and is being processed.</p>
                <div style="background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
                    <p style="margin: 5px 0;"><strong>Order ID:</strong> #{order_id}</p>
                    <p style="margin: 5px 0;"><strong>Total Amount:</strong> ${total_amount:,.2f}</p>
                </div>
                <p>You will receive updates as your order progresses.</p>
                <p>Thank you for your business!</p>
                <br>
                <p>Best regards,<br>
                <strong>B2B Meat Platform Team</strong></p>
            </div>
        </body>
        </html>
        """
        
        return self.send_email(customer_email, subject, html_content)
    
    def send_password_reset_email(self, customer_email: str, customer_name: str, otp: str) -> bool:
        """Send password reset OTP email"""
        subject = "Password Reset Request - B2B Meat Platform"
        
        html_content = f"""
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h2 style="color: #FF4B4B;">Password Reset Request</h2>
                <p>Dear {customer_name},</p>
                <p>You requested to reset your password. Use the OTP below to complete the process:</p>
                <div style="background: #f5f5f5; padding: 20px; border-radius: 5px; margin: 20px 0; text-align: center;">
                    <h1 style="color: #FF4B4B; letter-spacing: 5px; margin: 0;">{otp}</h1>
                </div>
                <p><strong>This OTP will expire in 10 minutes.</strong></p>
                <p>If you didn't request this, please ignore this email.</p>
                <br>
                <p>Best regards,<br>
                <strong>B2B Meat Platform Team</strong></p>
            </div>
        </body>
        </html>
        """
        
        return self.send_email(customer_email, subject, html_content)


# Singleton instance
email_service = EmailService()
