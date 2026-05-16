from app.schemas.ai import ProductRecommendation
from sqlalchemy.orm import Session
from app.models.medicine import Medicine

class MedicalDecisionTree:
    def __init__(self):
        # 1. Knowledge Base: Synonyms & Semantics
        self.synonyms = {
            "fever": ["fever", "hot", "burning", "temperature", "shivering", "warm", "febrile", "pyrexia", "jvaram", "bukhar"],
            "cough": ["cough", "cold", "sputum", "throat", "phlegm", "congestion", "runny nose", "sneezing", "mucus"],
            "headache": ["headache", "head hurts", "migraine", "pounding", "throbbing", "dizzy", "head pain"],
            "stomach_pain": ["stomach", "tummy", "belly", "abdomen", "gastric", "ulcer", "vomiting", "nausea"]
        }
        
        # Decision Tree Data
        self.flows = {
            "fever": {
                "steps": ["duration", "severity", "other_symptoms"],
                "questions": {
                    "duration": "How many days have you had the fever?",
                    "severity": "Is the fever mild (under 100°F) or high?",
                    "other_symptoms": "Do you have any body pain or headache?"
                },
                "recommendations": {
                    "default": ["Paracetamol 650"],
                    "high": ["Dolo 650", "Cold Sponge"],
                    "body pain": ["Aceclofenac + Paracetamol"]
                }
            },
            "cough": {
                "steps": ["type", "duration"],
                "questions": {
                    "type": "Is it a dry cough or wet cough (with mucus)?",
                    "duration": "How long have you been coughing?"
                },
                "recommendations": {
                    "dry": ["Ascoril D", "Benadryl"],
                    "wet": ["Grilinctus BM", "Mucolite"]
                }
            },
             "headache": {
                "steps": ["location", "severity"],
                "questions": {
                    "location": "Is the pain on one side or both sides?",
                    "severity": "Is it throbbing or dull pain?"
                },
                "recommendations": {
                    "default": ["Saridon", "Disprin"],
                    "severe": ["Migraine Relief"]
                }
            },
            "stomach_pain": {
                "steps": ["severity"],
                "questions": {
                    "severity": "Is the pain severe or mild?"
                },
                "recommendations": {
                    "default": ["Digene", "Omez"],
                    "severe": ["Buscopan"]
                }
            }
        }

    def detect_symptom(self, text: str):
        """
        Smart Extraction: Checks for semantic matches in the text.
        Returns the core symptom key (e.g. 'fever') or None.
        """
        text = text.lower()
        
        # 1. Direct Fuzzy Match
        for symptom, keywords in self.synonyms.items():
            if any(k in text for k in keywords):
                return symptom
        
        return None

    def process_interaction(self, intent: str, context: dict, user_text: str):
        """
        Determines the next state and response based on context.
        """
        # 1. Identify Topic (if not known)
        topic = context.get('current_topic')
        if not topic:
             # Use Smart Detection
             topic = self.detect_symptom(user_text)
             
             if topic:
                 context['current_topic'] = topic
                 context['step_index'] = 0
                 # Start Flow
                 question_key = self.flows[topic]['steps'][0]
                 return {
                     "response": f"I understand you have {topic}. {self.flows[topic]['questions'][question_key]}",
                     "context": context,
                     "action": "ASK_QUESTION"
                 }
             else:
                 # Smart Fallback explaining what it knows
                 return {
                     "response": "I didn't catch that. Could you tell me if you have a Fever, Cough, or Headache?",
                     "context": context,
                     "action": "GREETING"
                 }

        # 2. Process Answer & Move to Next Step
        step_index = context.get('step_index', 0)
        steps = self.flows[topic]['steps']
        
        # Save Answer
        current_step_key = steps[step_index]
        context[current_step_key] = user_text
        
        # Check if more steps
        if step_index < len(steps) - 1:
            next_step_index = step_index + 1
            context['step_index'] = next_step_index
            next_step_key = steps[next_step_index]
            return {
                "response": self.flows[topic]['questions'][next_step_key],
                "context": context,
                "action": "ASK_QUESTION"
            }
        
        # 3. Final Recommendation
        return self._generate_recommendation(topic, context)

    def _generate_recommendation(self, topic, context):
        # Logic to pick products based on answers
        recs = self.flows[topic]['recommendations']['default']
        
        # Simple refinement logic
        for key, val in context.items():
            if "high" in str(val).lower() and "high" in self.flows[topic]['recommendations']:
                recs = self.flows[topic]['recommendations']['high']
            if "dry" in str(val).lower() and "dry" in self.flows[topic]['recommendations']:
                recs = self.flows[topic]['recommendations']['dry']
            if "wet" in str(val).lower() and "wet" in self.flows[topic]['recommendations']:
                recs = self.flows[topic]['recommendations']['wet']

        formatted_recs = []
        for name in recs:
            formatted_recs.append(ProductRecommendation(
                product_id=1, # Mock ID
                product_name=name,
                reason=f"Recommended for {topic}",
                relevance_score=95
            ))
            
        return {
            "response": f"Based on your answers, I recommend: {', '.join(recs)}. Should I add these to your cart?",
            "context": {}, # Clear context after done
            "action": "RECOMMEND_CART",
            "recommendations": formatted_recs
        }

medical_decision_tree = MedicalDecisionTree()
