import os
import joblib
import json
import logging
from sentence_transformers import SentenceTransformer
import numpy as np

# Adjust path to be relative to this file
MODEL_DIR = os.path.join(os.path.dirname(__file__), "models")
logger = logging.getLogger(__name__)

class MultilingualNLU:
    def __init__(self):
        self.embedder = None
        self.clf = None
        self.le = None
        self.is_ready = False
        try:
            self._load_model()
        except Exception as e:
            logger.warning(f"ML Model not loaded: {e}. NLU will fall back to basic mode.")

    def _load_model(self):
        config_path = os.path.join(MODEL_DIR, "config.json")
        clf_path = os.path.join(MODEL_DIR, "nlu_classifier.pkl")
        le_path = os.path.join(MODEL_DIR, "label_encoder.pkl")
        
        if not os.path.exists(config_path) or not os.path.exists(clf_path):
            raise FileNotFoundError("Model artifacts not found.")
            
        with open(config_path, 'r') as f:
            config = json.load(f)
            
        logger.info(f"Loading NLU Engine with {config['embedding_model']}...")
        # Load embedding model (downloads if not cached, but should be cached by train.py)
        self.embedder = SentenceTransformer(config['embedding_model'])
        self.clf = joblib.load(clf_path)
        self.le = joblib.load(le_path)
        self.is_ready = True
        logger.info("NLU Engine Loaded successfully.")

    def predict_intent(self, text: str) -> dict:
        if not self.is_ready:
            return None # Indicate to caller to use fallback
            
        try:
            embedding = self.embedder.encode([text])
            prob = self.clf.predict_proba(embedding)[0]
            idx = np.argmax(prob)
            confidence = prob[idx]
            intent = self.le.inverse_transform([idx])[0]
            
            return {
                "intent": intent,
                "confidence": float(confidence),
                "scores": {label: float(score) for label, score in zip(self.le.classes_, prob)}
            }
        except Exception as e:
            logger.error(f"Prediction error: {e}")
            return None

# Singleton instance
nlu_engine = MultilingualNLU()
