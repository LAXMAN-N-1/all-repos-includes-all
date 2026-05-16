from __future__ import annotations

from typing import Any, Optional

import httpx

from app.core.config import settings


class SupabaseAdminService:
    @staticmethod
    def _admin_base_url() -> str:
        base_url = (settings.SUPABASE_URL or "").strip().rstrip("/")
        if not base_url:
            raise ValueError("SUPABASE_URL is not configured")
        return f"{base_url}/auth/v1/admin/users"

    @staticmethod
    def _admin_headers() -> dict[str, str]:
        key = (settings.SUPABASE_SERVICE_ROLE_KEY or "").strip()
        if not key:
            raise ValueError("SUPABASE_SERVICE_ROLE_KEY is not configured")
        return {
            "apikey": key,
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
        }

    @classmethod
    def create_user(
        cls,
        *,
        email: str,
        password: str,
        email_confirm: bool = True,
        user_metadata: Optional[dict[str, Any]] = None,
    ) -> dict[str, Any]:
        base_url = (settings.SUPABASE_URL or "").strip().rstrip("/")
        if not base_url:
            raise ValueError("SUPABASE_URL is not configured")
        payload = {
            "email": email,
            "password": password,
            "email_confirm": email_confirm,
            "user_metadata": user_metadata or {},
        }
        base_url = cls._admin_base_url()
        with httpx.Client(timeout=settings.SUPABASE_ADMIN_TIMEOUT_SECONDS) as client:
            response = client.post(
                base_url,
                headers=cls._admin_headers(),
                json=payload,
            )
        if response.status_code >= 400:
            raise ValueError(f"Supabase user creation failed: {response.text}")
        return response.json()

    @classmethod
    def update_user(
        cls,
        external_subject: str,
        attributes: dict[str, Any],
    ) -> dict[str, Any]:
        if not external_subject:
            raise ValueError("Supabase external subject is required")
        if not attributes:
            return {}

        with httpx.Client(timeout=settings.SUPABASE_ADMIN_TIMEOUT_SECONDS) as client:
            response = client.put(
                f"{cls._admin_base_url()}/{external_subject}",
                headers=cls._admin_headers(),
                json=attributes,
            )
        if response.status_code >= 400:
            raise ValueError(f"Supabase user update failed: {response.text}")
        return response.json()

    @classmethod
    def delete_user(cls, external_subject: str) -> None:
        if not external_subject:
            return
        with httpx.Client(timeout=settings.SUPABASE_ADMIN_TIMEOUT_SECONDS) as client:
            response = client.delete(
                f"{cls._admin_base_url()}/{external_subject}",
                headers=cls._admin_headers(),
            )
        if response.status_code >= 400:
            raise ValueError(f"Supabase user deletion failed: {response.text}")
