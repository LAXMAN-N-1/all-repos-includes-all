from sqlalchemy import Column, String, Integer, BigInteger
from app.models.base_model import BaseModel

class Attachment(BaseModel):
    __tablename__ = "attachments"
    
    entity_type = Column(String(100), nullable=False)  # user, product, event, etc.
    entity_id = Column(Integer, nullable=False)
    file_name = Column(String(255), nullable=False)
    file_path = Column(String(500), nullable=False)  # S3 path
    file_url = Column(String(500), nullable=False)  # Public URL
    file_size = Column(BigInteger, nullable=True)  # in bytes
    file_type = Column(String(50), nullable=True)  # mime type
    category = Column(String(50), nullable=True)  # profile, document, image, etc.
    category1 = Column(String(50), nullable=True)