import requests
from twilio.rest import Client
from app.core.config import settings
import logging
import os

logger = logging.getLogger(__name__)

class WhatsAppService:
    def __init__(self):
        # Twilio Config
        self.twilio_enabled = all([
            settings.TWILIO_ACCOUNT_SID,
            settings.TWILIO_AUTH_TOKEN,
            settings.TWILIO_WHATSAPP_NUMBER
        ]) and "mock" not in (settings.TWILIO_ACCOUNT_SID or "").lower()
        
        # Meta Cloud API Config
        self.meta_enabled = all([
            settings.WHATSAPP_PHONE_NUMBER_ID,
            settings.WHATSAPP_ACCESS_TOKEN
        ])
        
        self.enabled = self.twilio_enabled or self.meta_enabled
        
        if self.twilio_enabled:
            self.twilio_client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN, timeout=10)
            self.twilio_from = f"whatsapp:{settings.TWILIO_WHATSAPP_NUMBER}"
        
        if not self.enabled:
            logger.warning("WhatsApp credentials missing (Twilio or Meta). WhatsApp Service is in mock mode.")

    def send_message(self, to: str, body: str) -> bool:
        """
        Send a WhatsApp message using Meta Cloud API (preferred) or Twilio.
        """
        if not self.enabled:
            logger.info(f"[MOCK WHATSAPP] To: {to} | Body: {body}")
            return True

        # Clean phone number (remove whatsapp: prefix if present, ensure E.164)
        clean_to = to.replace("whatsapp:", "").replace("+", "")

        if self.meta_enabled:
            return self._send_meta_message(clean_to, body)
        elif self.twilio_enabled:
            return self._send_twilio_message(to, body)
        
        return False

    def _send_meta_message(self, to: str, body: str) -> bool:
        url = f"https://graph.facebook.com/v18.0/{settings.WHATSAPP_PHONE_NUMBER_ID}/messages"
        headers = {
            "Authorization": f"Bearer {settings.WHATSAPP_ACCESS_TOKEN}",
            "Content-Type": "application/json"
        }
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": to,
            "type": "text",
            "text": {"preview_url": False, "body": body}
        }
        try:
            response = requests.post(url, headers=headers, json=payload, timeout=10)
            response.raise_for_status()
            logger.info(f"Meta WhatsApp message sent: {response.json().get('messages', [{}])[0].get('id')}")
            return True
        except Exception as e:
            logger.error(f"Failed to send Meta WhatsApp message: {e}")
            return False

    def _send_twilio_message(self, to: str, body: str) -> bool:
        try:
            # Ensure 'to' has whatsapp: prefix for Twilio
            twilio_to = to if to.startswith("whatsapp:") else f"whatsapp:{to}"
            message = self.twilio_client.messages.create(
                body=body,
                from_=self.twilio_from,
                to=twilio_to
            )
            logger.info(f"Twilio WhatsApp message sent: {message.sid}")
            return True
        except Exception as e:
            logger.error(f"Failed to send Twilio WhatsApp message: {e}")
            return False

    def send_template_message(self, to: str, template_name: str, language_code: str = "en_US", components: list = None) -> bool:
        """
        Send a WhatsApp template message (Meta Cloud API only).
        """
        if not self.meta_enabled:
            logger.warning("Template messages require Meta Cloud API credentials.")
            return self.send_message(to, f"[TEMPLATE: {template_name}]")

        clean_to = to.replace("whatsapp:", "").replace("+", "")
        url = f"https://graph.facebook.com/v18.0/{settings.WHATSAPP_PHONE_NUMBER_ID}/messages"
        headers = {
            "Authorization": f"Bearer {settings.WHATSAPP_ACCESS_TOKEN}",
            "Content-Type": "application/json"
        }
        payload = {
            "messaging_product": "whatsapp",
            "to": clean_to,
            "type": "template",
            "template": {
                "name": template_name,
                "language": {"code": language_code},
                "components": components or []
            }
        }
        try:
            response = requests.post(url, headers=headers, json=payload, timeout=10)
            response.raise_for_status()
            return True
        except Exception as e:
            logger.error(f"Failed to send Meta Template message: {e}")
            return False

    def send_order_confirmation(self, to: str, order_id: int, total: float):
        body = f"✅ Farm2Cook B2B: Purchase Order #{order_id} has been confirmed. Total: ${total}. Our team will update you on dispatch soon."
        return self.send_message(to, body)

    def send_delivery_alert(self, to: str, order_id: int):
        body = f"🚚 Farm2Cook B2B Notification: Order #{order_id} has been dispatched and is out for delivery."
        return self.send_message(to, body)

    def send_invoice_notification(self, to: str, invoice_id: int, amount: float, due_date: str):
        body = f"📄 Farm2Cook B2B: Invoice #{invoice_id} is generated. Amount Due: ${amount}. Payment Terms: Due by {due_date}."
        return self.send_message(to, body)

    def send_interactive_buttons(self, to: str, body: str, buttons: list, footer: str = "") -> bool:
        """
        Send Meta Quick Reply buttons. 
        buttons: list of {"id": "btn1", "title": "Click me"}
        """
        if not self.meta_enabled:
            btn_text = "\n".join([f"- {b['title']}" for b in buttons])
            return self.send_message(to, f"{body}\n\n{btn_text}")

        clean_to = to.replace("whatsapp:", "").replace("+", "")
        url = f"https://graph.facebook.com/v18.0/{settings.WHATSAPP_PHONE_NUMBER_ID}/messages"
        headers = {
            "Authorization": f"Bearer {settings.WHATSAPP_ACCESS_TOKEN}",
            "Content-Type": "application/json"
        }
        
        btns = [{"type": "reply", "reply": {"id": b["id"], "title": b["title"][:20]}} for b in buttons[:3]]
        
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": clean_to,
            "type": "interactive",
            "interactive": {
                "type": "button",
                "body": {"text": body},
                "action": {"buttons": btns}
            }
        }
        if footer:
            payload["interactive"]["footer"] = {"text": footer[:60]}

        try:
            response = requests.post(url, headers=headers, json=payload, timeout=10)
            response.raise_for_status()
            return True
        except Exception as e:
            logger.error(f"Failed to send Meta Interactive Buttons: {e}")
            return False

    def send_list_message(self, to: str, header: str, body: str, button_label: str, sections: list, footer: str = "") -> bool:
        """
        Send Meta List message.
        sections: list of {"title": "S1", "rows": [{"id": "r1", "title": "Row 1", "description": "Desc"}]}
        """
        if not self.meta_enabled:
            list_text = f"--- {header} ---\n{body}\n\n"
            for s in sections:
                list_text += f"[{s['title']}]\n"
                for r in s['rows']:
                    list_text += f"- {r['title']}: {r.get('description', '')}\n"
            return self.send_message(to, list_text)

        clean_to = to.replace("whatsapp:", "").replace("+", "")
        url = f"https://graph.facebook.com/v18.0/{settings.WHATSAPP_PHONE_NUMBER_ID}/messages"
        headers = {
            "Authorization": f"Bearer {settings.WHATSAPP_ACCESS_TOKEN}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": clean_to,
            "type": "interactive",
            "interactive": {
                "type": "list",
                "header": {"type": "text", "text": header[:60]},
                "body": {"text": body},
                "action": {
                    "button": button_label[:20],
                    "sections": sections
                }
            }
        }
        if footer:
            payload["interactive"]["footer"] = {"text": footer[:60]}

        try:
            response = requests.post(url, headers=headers, json=payload, timeout=10)
            response.raise_for_status()
            return True
        except Exception as e:
            logger.error(f"Failed to send Meta List Message: {e}")
            return False

    def upload_media(self, file_path: str, file_type: str = "application/pdf") -> str:
        """
        Upload media to Meta and return media_id.
        """
        if not self.meta_enabled:
            return "mock_media_id"

        url = f"https://graph.facebook.com/v18.0/{settings.WHATSAPP_PHONE_NUMBER_ID}/media"
        headers = {
            "Authorization": f"Bearer {settings.WHATSAPP_ACCESS_TOKEN}"
        }
        files = {
            "file": (os.path.basename(file_path), open(file_path, "rb"), file_type),
            "messaging_product": (None, "whatsapp")
        }
        try:
            response = requests.post(url, headers=headers, files=files, timeout=30)
            response.raise_for_status()
            return response.json().get("id")
        except Exception as e:
            logger.error(f"Failed to upload Meta Media: {e}")
            return None

    def send_document(self, to: str, media_id: str, filename: str) -> bool:
        """
        Send a document using media_id.
        """
        if not self.meta_enabled:
            return self.send_message(to, f"📄 Document: {filename} (ID: {media_id})")

        clean_to = to.replace("whatsapp:", "").replace("+", "")
        url = f"https://graph.facebook.com/v18.0/{settings.WHATSAPP_PHONE_NUMBER_ID}/messages"
        headers = {
            "Authorization": f"Bearer {settings.WHATSAPP_ACCESS_TOKEN}",
            "Content-Type": "application/json"
        }
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": clean_to,
            "type": "document",
            "document": {
                "id": media_id,
                "filename": filename
            }
        }
        try:
            response = requests.post(url, headers=headers, json=payload, timeout=10)
            response.raise_for_status()
            return True
        except Exception as e:
            logger.error(f"Failed to send Meta Document: {e}")
            return False

whatsapp_service = WhatsAppService()
