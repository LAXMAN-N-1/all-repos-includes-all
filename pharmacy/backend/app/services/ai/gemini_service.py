import os
import google.generativeai as genai
import json
from dotenv import load_dotenv

load_dotenv()

class GeminiService:
    def __init__(self):
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            print("Error: GEMINI_API_KEY not found.")
            return

        genai.configure(api_key=api_key)
        
        # System Prompt for the Pharmacist Persona
        self.system_instruction = """
        You are 'Aura', an expert, empathetic, and responsible AI Pharmacist for the AuraMed Pharmacy App.
        
        Your Goal:
        1. Listen to the user's symptoms or health queries.
        2. Analyze the medical situation.
        3. Recommend standard Over-The-Counter (OTC) medicines available in India/Global markets (e.g., Paracetamol, Dolo, Benadryl, Digene).
        4. If symptoms sound severe (e.g., chest pain, high fever > 3 days), strictly advise consulting a doctor.
        5. Be concise (spoken response should be < 2 sentences).
        6. Output structured JSON.

        Response Format (JSON Only):
        {
            "response_text": "Your spoken reply to the user (warm, professional, concise).",
            "recommendations": [
                {
                    "product_name": "Medicine Name",
                    "reason": "Why this matches",
                    "relevance_score": 90
                }
            ],
            "action": "RECOMMEND_CART" (if recommending medicines) or "advice" (if just advice) or "question" (if need more info).
        }
        
        Example Interaction 1:
        User: "I have a bad headache"
        Output:
        {
            "response_text": "I'm sorry to hear that. For a headache, you can take a mild pain reliever like Saridon or Disprin. capture proper rest.",
            "recommendations": [{"product_name": "Saridon", "reason": "Headache relief", "relevance_score": 95}],
            "action": "RECOMMEND_CART"
        }
        """
        
        self.model = genai.GenerativeModel('models/gemini-flash-latest')

    def generate_response(self, user_input: str | bytes, context: dict, language: str = 'en') -> dict:
        try:
            # Construct Prompt
            prompt_parts = [
                self.system_instruction,
                f"Current Context: {json.dumps(context)}",
                f"Target Language for Response: {language} (Ensure 'response_text' is in this language)",
                "Provide the JSON response."
            ]
            
            # Check if input is text or audio
            if isinstance(user_input, bytes):
                # Audio Input
                prompt_parts.append({
                    "mime_type": "audio/mp3",
                    "data": user_input
                })
                prompt_parts.append("User Audio Input (Listen and Respond):")
            else:
                # Text Input
                prompt_parts.append(f'User Input: "{user_input}"')
            
            response = self.model.generate_content(prompt_parts)
            
            # Clean and Parse JSON
            text_response = response.text.strip()
            # Remove markdown code blocks if any
            if text_response.startswith("```json"):
                text_response = text_response.replace("```json", "").replace("```", "")
            elif text_response.startswith("```"):
                text_response = text_response.replace("```", "")
                
            return json.loads(text_response)

        except Exception as e:
            print(f"Gemini Error: {e}")
            # Fallback to Mock Response for Demo/Testing
            return {
                "response_text": "I am in Demo Mode because the AI connection failed. I recommend taking Paracetamol for fever or consulting a doctor.",
                "recommendations": [
                    {"product_name": "Paracetamol 500mg", "reason": "Standard fever reducer", "relevance_score": 95},
                    {"product_name": "Vitamin C", "reason": "Immunity booster", "relevance_score": 80}
                ],
                "action": "RECOMMEND_CART"
            }

gemini_service = GeminiService()
