import boto3
from botocore.exceptions import ClientError
from app.config import settings
from typing import Optional

class S3Manager:
    def __init__(self):
        self.s3_client = boto3.client(
            's3',
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            region_name=settings.AWS_REGION
        )
        self.bucket_name = settings.S3_BUCKET_NAME
    
    def upload_file(self, file_content: bytes, file_key: str, content_type: str) -> Optional[str]:
        try:
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=file_key,
                Body=file_content,
                ContentType=content_type
            )
            
            file_url = f"https://{self.bucket_name}.s3.{settings.AWS_REGION}.amazonaws.com/{file_key}"
            return file_url
        except ClientError as e:
            print(f"Error uploading file: {e}")
            return None
    
    def delete_file(self, file_key: str) -> bool:
        try:
            self.s3_client.delete_object(Bucket=self.bucket_name, Key=file_key)
            return True
        except ClientError as e:
            print(f"Error deleting file: {e}")
            return False

s3_manager = S3Manager()