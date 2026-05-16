
from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlmodel import Session, select
from app.api import deps
from app.models.session import UserSession
from app.models.user import User
from app.core.config import settings
from pydantic import BaseModel
from datetime import datetime
from app.api.deps import invalidate_user_token_cache
from app.utils.runtime_cache import cached_call, invalidate_cache
from app.schemas.auth import SessionRevokeResponse

router = APIRouter()

class SessionResponse(BaseModel):
    id: int
    device_type: str
    device_name: str | None = None
    ip_address: str | None = None
    last_active_at: datetime
    is_current: bool
    is_active: bool
    created_at: datetime

@router.get("", response_model=List[SessionResponse])
async def list_sessions(
    request: Request,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user),
) -> Any:
    """
    List all active sessions for the current user.
    """
    current_sid = getattr(request.state, "session_sid", None)

    def _load_sessions() -> list[dict[str, Any]]:
        sessions = db.exec(
            select(UserSession)
            .where(UserSession.user_id == current_user.id)
            .where(UserSession.is_active == True)
        ).all()

        return [
            {
                "id": s.id,
                "device_type": s.device_type,
                "device_name": s.device_name,
                "ip_address": s.ip_address,
                "last_active_at": s.last_active_at,
                "is_current": bool(
                    current_sid
                    and (
                        (
                            str(s.id) == str(current_sid)
                            if s.id is not None and str(current_sid).isdigit()
                            else s.token_id == current_sid
                        )
                    )
                ),
                "is_active": s.is_active,
                "created_at": s.created_at,
            }
            for s in sessions
        ]

    session_rows = cached_call(
        "session-list",
        current_user.id,
        current_sid or "none",
        ttl_seconds=settings.SESSION_CACHE_TTL_SECONDS,
        call=_load_sessions,
    )
    return [SessionResponse.model_validate(row) for row in session_rows]

@router.delete("/{session_id}", response_model=SessionRevokeResponse)
async def revoke_session(
    session_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
) -> Any:
    """
    Revoke a specific session.
    """
    session = db.get(UserSession, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if session.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to revoke this session")
    
    if not session.is_active:
         return {"message": "Session already revoked"}
         
    # 1. Mark inactive
    session.is_active = False
    db.add(session)
    
    # Note: Access Token revocation is now enforced by `deps.get_current_user` 
    # checking `UserSession.is_active` against the token's `sid`.
    # Therefore, marking session inactive immediately invalidates the access token.

    db.commit()
    invalidate_cache("session-list", current_user.id)
    invalidate_user_token_cache(current_user.id)
    
    return SessionRevokeResponse(message="Session revoked")
