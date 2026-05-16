import os
import json
import logging
from groq import Groq
from dotenv import load_dotenv

load_dotenv()
logger = logging.getLogger(__name__)

class LLMedicalParser:
    def __init__(self):
        self.api_key = os.getenv("GROQ_API_KEY") or os.getenv("OPENAI_API_KEY")
        if not self.api_key:
            logger.warning("No API Key found for LLM Parser (Groq/OpenAI).")
        
        try:
            self.client = Groq(api_key=self.api_key)
        except Exception as e:
            logger.error(f"Failed to initialize Groq client: {e}")
            self.client = None

    def extract_from_text(self, text: str) -> dict:
        """
        Extract structured medical data from noisy OCR text using LLM.
        """
        if not self.client:
            logger.error("LLM Client not initialized.")
            return {}

        prompt = f"""
You are an expert Indian pharmacist with 20+ years of experience reading handwritten prescriptions.
Your task is to extract structured data from NOISY OCR text of an Indian medical prescription.

The OCR text contains errors, typos, and garbled characters. You MUST use your knowledge of:
- Common Indian medicine brands (Augmentin, Enzoflam, Pan D, Pantop, Hexigel, Crocin, Dolo, etc.)
- Medical abbreviations: Tab.=Tablet, Cap.=Capsule, Syp.=Syrup, Inj.=Injection, Adv.=Advice
- Dosage patterns: 1-0-1 (morning-afternoon-night), 1-0-0, 0-0-1, 1-1-1
- Duration patterns: x5days, x 5 days, x1week, for 5 days, 5d, 7d
- Instructions: after meals, before meals, with food, at bedtime

INPUT OCR TEXT:
\"\"\"
{text}
\"\"\"

CRITICAL INSTRUCTIONS:
1. **Patient Info**: Look for name patterns like "Mr./Mrs./Ms. [Name]", age like "28/M", "30 yrs/F"
2. **Date**: Indian format DD/MM/YY or DD-MM-YYYY (e.g., "12/10/22" = 12 October 2022)
3. **Doctor**: Often at top/bottom, may have "Dr." prefix or signature area
4. **Clinic/Hospital**: Look for letterhead text, phone numbers, website

5. **MEDICINES - MOST IMPORTANT**:
   - Correct garbled names using your pharmaceutical knowledge:
     * "Aujnenturi" or "Augnentn" → "Augmentin"
     * "Enzzl" or "Enzflm" → "Enzoflam"
     * "PanD" or "Pan D" → "Pan D 40mg" (antacid)
     * "Hexiqel" → "Hexigel" (dental gel)
     * "Pantop" → "Pantoprazole" or "Pantop DSR"
   - Extract STRENGTH: 625mg, 40mg, 500mg, etc.
   - Extract FREQUENCY: 1-0-1, 1-0-0, etc. (may appear as "101" or "1 0 1")
   - Extract DURATION: "x5days" means 5 days, "x1week" means 7 days
   - Extract INSTRUCTIONS: "after meals", "before meals"

6. **Ignore**: Clinic address, phone numbers, watermarks, signatures

OUTPUT FORMAT - Return ONLY valid JSON (no markdown):
{{
    "date": "DD/MM/YYYY or null",
    "doctor_name": "string or null",
    "hospital_clinic": "string or null",
    "patient_name": "string or null",
    "patient_age": number or null,
    "patient_gender": "M or F or null",
    "medicines": [
        {{
            "name": "Corrected Medicine Name (Indian brand)",
            "strength": "e.g. 625mg",
            "frequency": "e.g. 1-0-1",
            "duration": "e.g. 5 days",
            "instructions": "e.g. after meals",
            "original_text": "raw OCR text for this medicine"
        }}
    ]
}}

IMPORTANT: Be aggressive in correcting medicine names. A typo like "Aujmenturi" is almost certainly "Augmentin".
"""

        try:
            logger.info(f"Sending text to Groq LLM (Key len: {len(self.api_key) if self.api_key else 0})...")
            chat_completion = self.client.chat.completions.create(
                messages=[
                    {
                        "role": "user",
                        "content": prompt,
                    }
                ],
                model="llama-3.3-70b-versatile", 
                temperature=0.1, 
            )
            
            response_content = chat_completion.choices[0].message.content.strip()
            logger.info(f"Raw LLM Response: {response_content}")
            
            # Basic cleanup if md blocks are present
            if response_content.startswith("```json"):
                response_content = response_content.replace("```json", "").replace("```", "")
            if response_content.startswith("```"):
                response_content = response_content.replace("```", "")
            
            data = json.loads(response_content)
            logging.info(f"LLM Extraction success: Found {len(data.get('medicines', []))} medicines.")
            return data

        except json.JSONDecodeError as e:
            logger.error(f"LLM returned invalid JSON: {e}")
            logger.error(f"Content was: {response_content}")
            return {}
        except Exception as e:
            logger.exception(f"Error calling Groq API: {e}")
            return {}
