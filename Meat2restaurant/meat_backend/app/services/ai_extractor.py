import json
import logging
from typing import List, Dict, Any, Optional
from groq import Groq

from app.core.config import settings

logger = logging.getLogger(__name__)

class AIExtractorService:
    def __init__(self):
        self.enabled = bool(settings.GROQ_API_KEY)
        if self.enabled:
            self.client = Groq(api_key=settings.GROQ_API_KEY, timeout=10.0)
            self.model = "llama-3.3-70b-versatile"
        else:
            logger.warning("GROQ_API_KEY missing. AI Extractor is disabled.")

    def extract_order_items(self, text: str, available_products: List[str] = []) -> List[Dict[str, Any]]:
        """
        Extracts product names and quantities from natural language text using Groq.
        Returns a list of dicts: [{"product": "chicken", "quantity": 10}]
        """
        if not self.enabled:
            return []

        # Construct the prompt
        products_context = f"Available products: {', '.join(available_products)}" if available_products else ""
        
        prompt = f"""
        You are a B2B meat ordering assistant. Extract the items and their quantities from the following customer message.
        
        {products_context}
        
        Rules:
        1. Return ONLY a JSON list of objects.
        2. Each object must have "product" (string) and "quantity" (number).
        3. If no items are found, return an empty list [].
        4. Match the product name to the 'Available products' list if provided.
        5. If the quantity is not specified, assume 1.
        
        Customer Message: "{text}"
        
        JSON Result:
        """

        try:
            chat_completion = self.client.chat.completions.create(
                messages=[
                    {
                        "role": "system",
                        "content": "You are a helpful assistant that outputs only JSON."
                    },
                    {
                        "role": "user",
                        "content": prompt,
                    }
                ],
                model=self.model,
                response_format={"type": "json_object"} if "llama-3" in self.model else None,
            )
            
            raw_json = chat_completion.choices[0].message.content.strip()
            
            # Groq usually returns the JSON directly, but let's be safe
            if raw_json.startswith('```json'):
                raw_json = raw_json.replace('```json', '').replace('```', '').strip()
            
            data = json.loads(raw_json)
            
            # If the response is wrapped in a key like "items", extract it
            if isinstance(data, dict):
                items = data.get("items", list(data.values())[0] if data else [])
                if not isinstance(items, list):
                    items = [data] if "product" in data else []
            else:
                items = data

            logger.info(f"Groq Extracted Items: {items}")
            return items
        except Exception as e:
            logger.error(f"Groq Extraction failed: {e}")
            return []

ai_extractor = AIExtractorService()
