"""
OCR Service - Lazy loading ML dependencies
If torch/easyocr not available, OCR features will be disabled.
"""
import logging
import io
from typing import Optional

logger = logging.getLogger(__name__)

# Conditional ML imports - won't crash if not installed
ML_AVAILABLE = False
try:
    import torch
    from transformers import TrOCRProcessor, VisionEncoderDecoderModel, DonutProcessor
    from PIL import Image
    import numpy as np
    ML_AVAILABLE = True
    logger.info("ML dependencies loaded successfully")
except ImportError as e:
    logger.warning(f"ML dependencies not available: {e}. OCR features disabled.")
    torch = None


class OCRService:
    def __init__(self):
        self.ml_available = ML_AVAILABLE
        
        if self.ml_available:
            self.device = "cuda" if torch.cuda.is_available() else "cpu"
            logger.info(f"Using device: {self.device}")
        else:
            self.device = "cpu"
            logger.warning("OCR Service running in DISABLED mode - ML not available")
        
        # Initialize TrOCR for handwriting
        self.trocr_processor = None
        self.trocr_model = None
        
        # Initialize Donut for document parsing
        self.donut_processor = None
        self.donut_model = None
        
        # Initialize EasyOCR
        self.easyocr_reader = None

    def _check_ml_available(self):
        """Check if ML is available and raise descriptive error if not"""
        if not self.ml_available:
            raise RuntimeError(
                "OCR is not available. ML dependencies (torch, easyocr) are not installed. "
                "Please install them or deploy with ML-enabled requirements."
            )

    def _load_easyocr(self):
        self._check_ml_available()
        if self.easyocr_reader is None:
            import easyocr
            logger.info("Loading EasyOCR model...")
            self.easyocr_reader = easyocr.Reader(
                ['en'], 
                gpu=torch.cuda.is_available(),
                download_enabled=True
            )

    def _load_trocr(self):
        self._check_ml_available()
        if self.trocr_model is None:
            logger.info("Loading TrOCR model...")
            self.trocr_processor = TrOCRProcessor.from_pretrained("microsoft/trocr-base-handwritten")
            self.trocr_model = VisionEncoderDecoderModel.from_pretrained("microsoft/trocr-base-handwritten").to(self.device)

    def _load_donut(self):
        self._check_ml_available()
        if self.donut_model is None:
            logger.info("Loading Donut model...")
            self.donut_processor = DonutProcessor.from_pretrained("naver-ai-vietnam/donut-base")
            self.donut_model = VisionEncoderDecoderModel.from_pretrained("naver-ai-vietnam/donut-base").to(self.device)

    def read_handwritten(self, image_bytes: bytes) -> str:
        """Read handwritten text using TrOCR"""
        self._load_trocr()
        from PIL import Image
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        pixel_values = self.trocr_processor(images=image, return_tensors="pt").pixel_values.to(self.device)
        
        generated_ids = self.trocr_model.generate(pixel_values)
        generated_text = self.trocr_processor.batch_decode(generated_ids, skip_special_tokens=True)[0]
        
        return generated_text

    def _preprocess_image(self, img):
        """
        Preprocess image for better OCR:
        1. Convert to grayscale
        2. Apply adaptive thresholding
        3. Denoise
        4. Enhance contrast
        """
        import cv2
        import numpy as np
        
        # Convert to grayscale if color
        if len(img.shape) == 3:
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        else:
            gray = img
        
        # Denoise
        denoised = cv2.fastNlMeansDenoising(gray, None, 10, 7, 21)
        
        # Enhance contrast using CLAHE
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        enhanced = clahe.apply(denoised)
        
        # Sharpen
        kernel = np.array([[-1, -1, -1], [-1, 9, -1], [-1, -1, -1]])
        sharpened = cv2.filter2D(enhanced, -1, kernel)
        
        # Convert back to BGR for EasyOCR (it handles both)
        result = cv2.cvtColor(sharpened, cv2.COLOR_GRAY2BGR)
        
        return result

    def read_with_easyocr(self, image_bytes: bytes) -> str:
        """Read text using EasyOCR with preprocessing and rotation handling"""
        self._load_easyocr()
        
        import cv2
        import numpy as np
        from PIL import Image
        import io

        # Convert bytes to numpy array for OpenCV
        nparr = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            logger.error("Failed to decode image")
            return ""
        
        # Apply preprocessing for better OCR
        logger.info("Applying image preprocessing...")
        preprocessed = self._preprocess_image(img)
        
        best_text = ""
        best_len = 0
        
        # Try original and preprocessed, pick best result
        for img_variant, name in [(img, "original"), (preprocessed, "preprocessed")]:
            # Try 4 rotations for each variant
            for angle in [0, 90, 180, 270]:
                if angle == 0:
                    rotated = img_variant
                elif angle == 90:
                    rotated = cv2.rotate(img_variant, cv2.ROTATE_90_CLOCKWISE)
                elif angle == 180:
                    rotated = cv2.rotate(img_variant, cv2.ROTATE_180)
                elif angle == 270:
                    rotated = cv2.rotate(img_variant, cv2.ROTATE_90_COUNTERCLOCKWISE)
                
                # Read text with EasyOCR
                result = self.easyocr_reader.readtext(rotated, detail=0, paragraph=True)
                text = " ".join(result)
                
                if len(text.strip()) > best_len:
                    best_len = len(text.strip())
                    best_text = text
                    logger.info(f"Found {len(text)} chars with {name} at {angle}°")
                
                # If we found substantial text, return early
                if len(text.strip()) > 100:
                    logger.info(f"Good text found: {text[:80]}...")
                    return text
        
        if best_len > 0:
            logger.info(f"Returning best text ({best_len} chars)")
            return best_text
            
        logger.warning("No significant text found in any rotation/variant.")
        return ""

    def parse_document(self, image_bytes: bytes) -> dict:
        """Parse structured document using Donut"""
        self._load_donut()
        from PIL import Image
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        
        # Prepare inputs for Donut
        task_prompt = "<s_prescription>"
        decoder_input_ids = self.donut_processor.tokenizer(task_prompt, add_special_tokens=False, return_tensors="pt").input_ids.to(self.device)
        
        pixel_values = self.donut_processor(image, return_tensors="pt").pixel_values.to(self.device)
        
        outputs = self.donut_model.generate(
            pixel_values,
            decoder_input_ids=decoder_input_ids,
            max_length=self.donut_model.config.decoder.max_position_embeddings,
            early_stopping=True,
            pad_token_id=self.donut_processor.tokenizer.pad_token_id,
            eos_token_id=self.donut_processor.tokenizer.eos_token_id,
            use_cache=True,
            num_beams=1,
            bad_words_ids=[[self.donut_processor.tokenizer.unk_token_id]],
            return_dict_in_generate=True,
        )
        
        prediction = self.donut_processor.batch_decode(outputs.sequences)[0]
        prediction = self.donut_processor.token2json(prediction)
        
        return prediction
    
    def is_available(self) -> bool:
        """Check if OCR functionality is available"""
        return self.ml_available
