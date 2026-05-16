import sys
from pathlib import Path
import json

# Add the parent directory to sys.path
sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.services.ai_extractor import ai_extractor

def test_groq_extraction():
    print("--- Testing Groq Order Extraction ---")
    
    test_message = "I need 10 cases of chicken and 5 master cartons of salmon"
    available_products = ["Whole Chicken Bulk Pack", "Frozen Salmon Fillets", "Ribeye Steak Primal Cut"]
    
    print(f"Customer Message: {test_message}")
    print(f"Products Context: {available_products}")
    
    items = ai_extractor.extract_order_items(test_message, available_products)
    
    print("\nExtracted Items:")
    print(json.dumps(items, indent=2))
    
    if items and len(items) > 0:
        print("\nSuccess! Groq extracted items correctly.")
    else:
        print("\nFailed or Empty Result. Check GROQ_API_KEY and logs.")

if __name__ == "__main__":
    if not ai_extractor.enabled:
        print("Error: AI Extractor is disabled. Check GROQ_API_KEY in .env")
        sys.exit(1)
    test_groq_extraction()
