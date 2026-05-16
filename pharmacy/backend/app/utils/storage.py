"""
Storage utility module for file uploads.
Supports Cloudinary with easy migration path to S3.
"""
import cloudinary
import cloudinary.uploader
from fastapi import UploadFile, HTTPException
from typing import Optional
from app.config import settings


def configure_cloudinary():
    """Configure Cloudinary with credentials from settings"""
    cloudinary.config(
        cloud_name=settings.CLOUDINARY_CLOUD_NAME,
        api_key=settings.CLOUDINARY_API_KEY,
        api_secret=settings.CLOUDINARY_API_SECRET,
        secure=True
    )


async def upload_file(
    file: UploadFile,
    folder: str = "prescriptions",
    allowed_types: Optional[list] = None
) -> dict:
    """
    Upload a file to cloud storage (Cloudinary).
    
    Args:
        file: FastAPI UploadFile object
        folder: Folder/directory in cloud storage
        allowed_types: List of allowed MIME types (e.g., ['image/jpeg', 'image/png'])
    
    Returns:
        dict with 'url' and 'public_id'
    """
    # Default allowed types for prescriptions
    if allowed_types is None:
        allowed_types = [
            'image/jpeg', 'image/jpg', 'image/png', 
            'image/gif', 'application/pdf'
        ]
    
    # Validate file type
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail=f"File type '{file.content_type}' not allowed. Allowed: {allowed_types}"
        )
    
    # Validate file size
    contents = await file.read()
    if len(contents) > settings.MAX_UPLOAD_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"File size exceeds maximum allowed ({settings.MAX_UPLOAD_SIZE // 1024 // 1024}MB)"
        )
    
    # Reset file pointer
    await file.seek(0)
    
    try:
        # Configure Cloudinary
        configure_cloudinary()
        
        # Upload to Cloudinary
        result = cloudinary.uploader.upload(
            contents,
            folder=folder,
            resource_type="auto",
            public_id=f"{folder}_{file.filename.split('.')[0]}",
            overwrite=True
        )
        
        return {
            "url": result.get("secure_url"),
            "public_id": result.get("public_id"),
            "thumbnail_url": result.get("secure_url").replace("/upload/", "/upload/c_thumb,w_200,h_200/") if result.get("secure_url") else None
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to upload file: {str(e)}"
        )


async def delete_file(public_id: str) -> bool:
    """
    Delete a file from cloud storage.
    
    Args:
        public_id: Cloudinary public_id
    
    Returns:
        True if deleted successfully
    """
    try:
        configure_cloudinary()
        result = cloudinary.uploader.destroy(public_id)
        return result.get("result") == "ok"
    except Exception:
        return False
