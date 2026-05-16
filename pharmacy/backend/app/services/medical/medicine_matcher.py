from rapidfuzz import process, fuzz
from sqlalchemy.orm import Session
from app.models.medicine import Medicine
import logging

logger = logging.getLogger(__name__)

class MedicineMatcher:
    def __init__(self, db: Session):
        self.db = db
        # Cache medicine names for faster matching
        self.medicines = self.db.query(Medicine.id, Medicine.name).filter(Medicine.inactive == False).all()
        self.medicine_names = [m.name for m in self.medicines]
        self.medicine_map = {m.name: m.id for m in self.medicines}

    def match(self, extracted_name: str, threshold: int = 70) -> dict:
        """Match extracted medicine name against database using fuzzy matching"""
        if not self.medicine_names:
            return {"name": extracted_name, "id": None, "score": 0}
            
        match = process.extractOne(extracted_name, self.medicine_names, scorer=fuzz.WRatio)
        
        if match and match[1] >= threshold:
            name, score, _ = match
            return {
                "name": name,
                "id": self.medicine_map[name],
                "score": score
            }
        
        return {"name": extracted_name, "id": None, "score": 0}
