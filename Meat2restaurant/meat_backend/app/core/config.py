"""
Application Configuration
"""
from typing import List, Optional
try:
    from pydantic_settings import BaseSettings
    from pydantic import field_validator, validator
except ImportError:
    from pydantic import BaseSettings, validator, field_validator


class Settings(BaseSettings):
    # API Settings
    APP_ENV: str = "development"
    PROJECT_NAME: str = "B2B Meat Platform API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    BASE_URL: Optional[str] = None
    PUBLIC_BASE_URL: Optional[str] = None

    # Database (explicit)
    # Database (explicit - Optional if DATABASE_URL is set)
    DB_HOST: Optional[str] = None
    DB_PORT: Optional[int] = None
    DB_NAME: Optional[str] = None
    DB_USER: Optional[str] = None
    DB_PASSWORD: Optional[str] = None
    DATABASE_URL: Optional[str] = None

    @property
    def SQLALCHEMY_DATABASE_URI(self) -> str:
        return self.DATABASE_URL

    @classmethod
    def parse_db_port(cls, v):
        if v == "" or v is None:
            return None
        return int(v)

    # Use validator for Pydantic v1/v2 compatibility
    try:
        from pydantic import validator
        _validate_db_port = validator("DB_PORT", pre=True, allow_reuse=True)(parse_db_port)
        
        @validator("DATABASE_URL", pre=True, allow_reuse=True)
        def assemble_db_connection(cls, v: Optional[str], values: dict) -> str:
            if isinstance(v, str) and v.strip().startswith("postgres"):
                return v
            
            # Fallback: Build from components
            return str(
                f"postgresql://{values.get('DB_USER')}:{values.get('DB_PASSWORD')}"
                f"@{values.get('DB_HOST')}:{values.get('DB_PORT') or 5432}/{values.get('DB_NAME')}"
            )

    except ImportError:
        from pydantic import field_validator
        @field_validator("DB_PORT", mode="before")
        def validate_db_port(cls, v):
            return cls.parse_db_port(v)

        @field_validator("DATABASE_URL", mode="before")
        def assemble_db_connection(cls, v: Optional[str], info) -> str:
            if isinstance(v, str) and v.strip().startswith("postgres"):
                return v
                
            # Fallback: Build from components
            values = info.data
            return str(
                f"postgresql://{values.get('DB_USER')}:{values.get('DB_PASSWORD')}"
                f"@{values.get('DB_HOST')}:{values.get('DB_PORT') or 5432}/{values.get('DB_NAME')}"
            )

    # Security
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["*"]

    @validator("BACKEND_CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v: str | List[str]) -> List[str] | str:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    # AWS
    AWS_REGION: Optional[str] = None
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    S3_BUCKET: Optional[str] = None

    # Stripe
    STRIPE_SECRET_KEY: Optional[str] = None
    STRIPE_PUBLISHABLE_KEY: Optional[str] = None
    STRIPE_WEBHOOK_SECRET: Optional[str] = None

    # Twilio (WhatsApp)
    TWILIO_ACCOUNT_SID: Optional[str] = None
    TWILIO_AUTH_TOKEN: Optional[str] = None
    TWILIO_WHATSAPP_NUMBER: Optional[str] = None

    # AI (Groq)
    GROQ_API_KEY: Optional[str] = None

    # Meta/WhatsApp Cloud API (Alternative to Twilio)
    WHATSAPP_PHONE_NUMBER_ID: Optional[str] = None
    WHATSAPP_BUSINESS_ACCOUNT_ID: Optional[str] = None
    WHATSAPP_ACCESS_TOKEN: Optional[str] = None
    WHATSAPP_VERIFY_TOKEN: Optional[str] = "farm2cook_default_verify_token"

    class Config:
        import os
        env_file = (".env", f".env.{os.getenv('APP_ENV', 'development')}")
        case_sensitive = True
        extra = "allow"  # 🔑 allows future env vars safely


settings = Settings()
