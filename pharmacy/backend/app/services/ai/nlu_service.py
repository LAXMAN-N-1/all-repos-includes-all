import re
from typing import Dict, Any, List
# Import ML Engine
try:
    from ml_engine.inference import nlu_engine
except ImportError:
    # Fallback if ml_engine module not found or path issue
    print("Warning: ml_engine not found, using keyword fallbacks only.")
    nlu_engine = None

class NLUService:
    """
    Natural Language Understanding Service.
    Extracts Intent and Entities from text.
    """

    def detect_intent(self, text: str) -> str:
        # 1. Try ML Prediction
        if nlu_engine:
            prediction = nlu_engine.predict_intent(text)
            if prediction and prediction['confidence'] > 0.5:
                return prediction['intent']
        
        # 2. Fallback to Rules
        text = text.lower()
        
        # Product Search Keywords
        if any(w in text for w in ['buy', 'order', 'price', 'cost', 'search', 'find medicine']):
            return "PRODUCT_SEARCH"
            
        # Symptom Check Keywords
        if any(w in text for w in ['fever', 'pain', 'headache', 'cold', 'cough', 'sick', 'symptom', 'feeling']):
            return "SYMPTOM_CHECK"
            
        # Greeting
        if any(w in text for w in ['hi', 'hello', 'hey', 'start']):
            return "GREETING"

        # Duration/Time (Contextual Answer)
        if re.search(r'\d+\s+(days?|hours?|weeks?|months?)', text):
            return "SYMPTOM_CHECK"
            
        return "GENERAL_QUERY"

    def extract_entities(self, text: str) -> Dict[str, Any]:
        """
        Extract structured data like symptoms, duration, age.
        """
        text = text.lower()
        entities = {
            "symptoms": [],
            "duration": None,
            "age": None
        }
        
        # Simple symptom list
        common_symptoms = ['fever', 'headache', 'stomach pain', 'cold', 'cough', 'diarrhea']
        for s in common_symptoms:
            if s in text:
                entities['symptoms'].append(s)
                
        # Duration extraction (e.g. "2 days", "3 hours")
        duration_match = re.search(r'(\d+)\s+(days?|hours?|weeks?)', text)
        if duration_match:
            entities['duration'] = f"{duration_match.group(1)} {duration_match.group(2)}"
            
        return entities

nlu_service = NLUService()
