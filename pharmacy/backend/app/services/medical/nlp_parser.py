"""
Medical NLP Parser - Lazy loading ML dependencies
If transformers not available, NLP features will be disabled.
"""
import logging
import re
from typing import Optional

logger = logging.getLogger(__name__)

# Conditional ML imports
ML_AVAILABLE = False
try:
    from transformers import pipeline
    ML_AVAILABLE = True
    logger.info("Transformers loaded successfully")
except ImportError as e:
    logger.warning(f"Transformers not available: {e}. NLP parsing disabled.")
    pipeline = None


class MedicalNLPParser:
    def __init__(self):
        self.ml_available = ML_AVAILABLE
        self.ner_pipeline = None
        
        if not self.ml_available:
            logger.warning("MedicalNLPParser running in DISABLED mode - transformers not available")
    
    def _load_pipeline(self):
        """Lazy load the NER pipeline"""
        if not self.ml_available:
            raise RuntimeError(
                "NLP parsing is not available. Transformers library is not installed. "
                "Please install it or deploy with ML-enabled requirements."
            )
        
        if self.ner_pipeline is None:
            logger.info("Loading biomedical NER model...")
            self.ner_pipeline = pipeline("ner", model="d4data/biomedical-ner-all", aggregation_strategy="simple")

    def extract_entities(self, text: str) -> dict:
        """Extract medical entities from text using NER and heuristics"""
        logger.info("Extracting entities from prescription text...")
        
        data = {
            "patient_name": None,
            "patient_age": None,
            "patient_gender": None,
            "doctor_name": None,
            "medicines": [],
            "date": None,
            "raw_text": text
        }
        
        # Basic heuristic for Age and Gender (Common in India: 28M, 35/F, Age: 40)
        age_gender_match = re.search(r'(\d{1,2})\s*/?\s*([MFmf])', text)
        if age_gender_match:
            data["patient_age"] = int(age_gender_match.group(1))
            data["patient_gender"] = age_gender_match.group(2).upper()
            
        # Date detection
        date_match = re.search(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}', text)
        if date_match:
            data["date"] = date_match.group(0)

        # If ML is available, use NER for entity extraction
        if self.ml_available:
            try:
                self._load_pipeline()
                entities = self.ner_pipeline(text)
                
                current_medicine = {}
                
                for ent in entities:
                    label = ent['entity_group']
                    word = ent['word'].strip()
                    
                    if label == 'Medication':
                        if current_medicine and 'name' in current_medicine:
                            data['medicines'].append(current_medicine)
                        current_medicine = {'name': word}
                    elif label == 'Dosage' and current_medicine:
                        current_medicine['strength'] = word
                    elif label == 'Frequency' and current_medicine:
                        current_medicine['frequency'] = word
                    elif label == 'Duration' and current_medicine:
                        current_medicine['duration'] = word
                
                if current_medicine and 'name' in current_medicine:
                    data['medicines'].append(current_medicine)
                    
            except Exception as e:
                logger.error(f"NER extraction failed: {e}")
        else:
            logger.warning("Skipping NER extraction - ML not available")
            
        return data
    
    def is_available(self) -> bool:
        """Check if NLP functionality is available"""
        return self.ml_available
