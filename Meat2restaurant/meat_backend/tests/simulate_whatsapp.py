"""
WhatsApp Flow Simulation Test
Tests the complete ordering flow end-to-end by simulating Meta webhook payloads.
"""
import requests
import json
import time

BASE_URL = "http://localhost:8000/api/v1/whatsapp/webhook"
PHONE = "15551234567"

def send_text(text: str):
    """Simulate a user text message."""
    payload = {
        "entry": [{
            "changes": [{
                "value": {
                    "messages": [{
                        "from": PHONE,
                        "type": "text",
                        "text": {"body": text}
                    }]
                }
            }]
        }]
    }
    resp = requests.post(BASE_URL, json=payload)
    print(f"  → Text: '{text}' | Status: {resp.status_code}")
    time.sleep(0.5)
    return resp


def send_button(button_id: str, title: str = ""):
    """Simulate a user button/list reply."""
    payload = {
        "entry": [{
            "changes": [{
                "value": {
                    "messages": [{
                        "from": PHONE,
                        "type": "interactive",
                        "interactive": {
                            "type": "button_reply",
                            "button_reply": {"id": button_id, "title": title}
                        }
                    }]
                }
            }]
        }]
    }
    resp = requests.post(BASE_URL, json=payload)
    print(f"  → Button: '{button_id}' | Status: {resp.status_code}")
    time.sleep(0.5)
    return resp


def send_list_reply(item_id: str, title: str = ""):
    """Simulate a user list selection."""
    payload = {
        "entry": [{
            "changes": [{
                "value": {
                    "messages": [{
                        "from": PHONE,
                        "type": "interactive",
                        "interactive": {
                            "type": "list_reply",
                            "list_reply": {"id": item_id, "title": title}
                        }
                    }]
                }
            }]
        }]
    }
    resp = requests.post(BASE_URL, json=payload)
    print(f"  → List: '{item_id}' | Status: {resp.status_code}")
    time.sleep(0.5)
    return resp


if __name__ == "__main__":
    print("=" * 60)
    print("WhatsApp Flow Simulation Test")
    print("=" * 60)

    # Step 1: Welcome
    print("\n📍 Step 1: Send 'Hi' — Welcome Message")
    send_text("Hi")

    # Step 2: Store Selection
    print("\n📍 Step 2: Select Store — Dallas")
    send_button("store_0", "📍 Dallas")

    # Step 3: Browse Catalogs
    print("\n📍 Step 3: Select Catalog — Chicken")
    send_list_reply("catalog_chicken", "🐔 Chicken")

    # Step 4: After catalog, select sub-category or product
    print("\n📍 Step 4: Select product (add_1 = first product)")
    send_list_reply("add_1", "🐔 Product")

    # Step 5: Add More — Same Category
    print("\n📍 Step 5: Add More — Same Category")
    send_button("addmore_same_cat", "📋 Same Category")

    # Step 6: Add another product
    print("\n📍 Step 6: Add second product (add_2)")
    send_list_reply("add_2", "🐔 Product 2")

    # Step 7: View Cart
    print("\n📍 Step 7: View Cart")
    send_button("menu_cart", "🛒 View Cart")

    # Step 8: Checkout
    print("\n📍 Step 8: Checkout")
    send_button("cart_checkout", "🚢 Checkout")

    # Step 9: Enter Name
    print("\n📍 Step 9: Enter Name")
    send_text("Ahmed Khan")

    # Step 10: Select Pickup Date
    print("\n📍 Step 10: Select Pickup Date — Tomorrow")
    send_list_reply("date_1", "📅 Tomorrow")

    # Step 11: Select Payment Method
    print("\n📍 Step 11: Select Payment — Cash on Delivery")
    send_list_reply("pay_cod", "💵 Cash on Delivery")

    print("\n" + "=" * 60)
    print("✅ Flow simulation complete!")
    print("=" * 60)
