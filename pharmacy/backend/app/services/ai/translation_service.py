from deep_translator import GoogleTranslator
import logging

logger = logging.getLogger(__name__)

class TranslationService:
    def __init__(self):
        self.translator = GoogleTranslator

    def translate_to_english(self, text: str, source_lang: str) -> str:
        """Translates input text to English for processing."""
        if source_lang == 'en' or not text:
            return text
        
        try:
            # Deep Translator uses 'auto' or specific codes
            result = self.translator(source=source_lang, target='en').translate(text)
            logger.info(f"Translated '{text}' ({source_lang}) -> '{result}'")
            return result
        except Exception as e:
            logger.error(f"Translation Error (to English): {e}")
            return text 

    def translate_from_english(self, text: str, target_lang: str) -> str:
        """Translates logic response back to user language."""
        if target_lang == 'en' or not text:
            return text

        try:
            result = self.translator(source='en', target=target_lang).translate(text)
            logger.info(f"Translated Response '{text}' -> '{result}' ({target_lang})")
            return result
        except Exception as e:
            logger.error(f"Translation Error (from English): {e}")
            return text

translation_service = TranslationService()
