import stripe
from app.core.config import settings

stripe.api_key = settings.STRIPE_SECRET_KEY

def create_payment_intent(amount: int, currency: str = "usd", metadata: dict = None):
    """
    Create a Stripe Payment Intent.
    'amount' should be in cents (e.g., $10.00 = 1000)
    """
    try:
        intent = stripe.PaymentIntent.create(
            amount=amount,
            currency=currency,
            metadata=metadata or {},
            automatic_payment_methods={
                'enabled': True,
            },
        )
        return intent
    except Exception as e:
        # Log error here if needed
        raise e

def verify_webhook_signature(payload: str, sig_header: str):
    """
    Verify Stripe webhook signature.
    """
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
        return event
    except Exception as e:
        raise e

def create_checkout_session(amount: int, currency: str, metadata: dict, success_url: str, cancel_url: str, name: str = "Meat2Restaurant Order Payment"):
    """
    Create a Stripe Checkout Session.
    'amount' should be in cents.
    """
    try:
        session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=[{
                'price_data': {
                    'currency': currency,
                    'product_data': {
                        'name': name,
                    },
                    'unit_amount': amount,
                },
                'quantity': 1,
            }],
            mode='payment',
            metadata=metadata or {},
            success_url=success_url,
            cancel_url=cancel_url,
        )
        return session
    except Exception as e:
        raise e
