from sqlalchemy.orm import Session
from app.models.customer_ai import MedicalCondition, SymptomProductMap
from app.schemas.ai import ProductRecommendation
from typing import List, Optional

class MedicalService:
    
    def analyze_symptoms(self, symptoms: List[str], current_context: dict) -> dict:
        """
        Determine next step based on symptoms.
        Returns: { "action": "ASK_QUESTION" | "RECOMMEND", "question": "...", "condition": "..." }
        """
        if not symptoms:
             return {"action": "ASK_QUESTION", "question": "Could you describe your symptoms?"}
             
        # Heuristic for demo
        if "fever" in symptoms:
            if not current_context.get("duration"):
                return {"action": "ASK_QUESTION", "question": "How long have you had the fever?"}
            return {"action": "RECOMMEND", "condition": "Viral Fever"}
            
        return {"action": "RECOMMEND", "condition": "General Pain"}

    def recommend_products(self, db: Session, condition_name: str) -> List[ProductRecommendation]:
        """
        Find products for the condition.
        """
        # 1. Find Condition
        condition = db.query(MedicalCondition).filter(MedicalCondition.name == condition_name).first()
        if not condition:
            # Fallback if DB is empty for this demo
            if condition_name == "Viral Fever":
                return [
                    ProductRecommendation(product_id=101, product_name="Dolo 650", reason="Effective for fever", relevance_score=95),
                    ProductRecommendation(product_id=102, product_name="Thermometer", reason="To monitor temperature", relevance_score=80)
                ]
            return []
            
        # 2. Get Mappings
        mappings = db.query(SymptomProductMap).filter(SymptomProductMap.condition_id == condition.id).all()
        
        results = []
        for m in mappings:
            # In a real app, we would fetch the Product name from the Product table using m.product_id
            # For now, we might need a way to get the name. 
            # Let's assume we just return ID or a placeholder if we can't join.
            # OR we can assume Product table exists.
            
            results.append(ProductRecommendation(
                product_id=m.product_id,
                product_name=f"Product #{m.product_id}", # Placeholder
                reason=f"Recommended for {condition.name}",
                relevance_score=m.relevance_score
            ))
            
        return results

medical_service = MedicalService()
