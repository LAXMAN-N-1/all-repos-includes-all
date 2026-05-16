from __future__ import annotations

from datetime import UTC, datetime
from typing import Optional
import uuid

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlmodel import Session

from app.api import deps
from app.core.config import settings
from app.core.app_scope_access import filter_roles_for_app_scope, resolve_app_scope
from app.core.proxy import extract_forwarded_client_ip
from app.core.rbac import canonical_role_name, role_sort_key
from app.core.security import create_access_token, create_refresh_token
from app.db.session import get_session
from app.models.user import User
from app.schemas.auth import (
    LoginResponse,
    PasskeyCredentialInfo,
    PasskeyListResponse,
    PasskeyOperationResponse,
    PasskeyOptionsRequest,
    PasskeyOptionsResponse,
    PasskeyRegistrationOptionsRequest,
    PasskeyRegistrationVerifyRequest,
    PasskeyRegistrationVerifyResponse,
    PasskeyVerifyRequest,
)
from app.services.auth_service import AuthService
from app.services.passkey_service import PasskeyService

router = APIRouter(prefix="/passkeys")


def _extract_client_ip(request: Optional[Request]) -> Optional[str]:
    if request is None:
        return None
    source_ip = request.client.host if request.client else None
    return extract_forwarded_client_ip(
        source_ip,
        request.headers.get("x-forwarded-for"),
        request.headers.get("forwarded"),
        request.headers.get("x-real-ip"),
    )


def _to_credential_info(item) -> PasskeyCredentialInfo:
    return PasskeyCredentialInfo(
        credential_id=item.credential_id,
        passkey_name=item.passkey_name,
        created_at=item.created_at,
        last_used_at=item.last_used_at,
        device_type=item.credential_device_type,
        backed_up=bool(item.credential_backed_up),
    )


def _resolve_selected_role(
    db: Session,
    user: User,
    requested_role: Optional[str],
    app_scope: Optional[str] = None,
    require_explicit_scope_selection: bool = True,
) -> tuple[Optional[str], list[str], bool]:
    role_objects = deps.get_active_roles_for_user_id(db, user.id)
    if not role_objects and user.role:
        role_objects = [user.role]
    unique_role_names = {
        canonical_role_name(role.name)
        for role in role_objects
        if getattr(role, "name", None)
    }
    user_roles = sorted(
        [role_name for role_name in unique_role_names if role_name],
        key=lambda value: role_sort_key(value),
    )
    if not user_roles:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No roles assigned to user")

    effective_roles = user_roles
    if app_scope:
        scoped_roles = filter_roles_for_app_scope(user_roles, app_scope)
        if not scoped_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Account is not authorized for {app_scope} app",
            )
        effective_roles = scoped_roles

    if requested_role:
        canonical_requested_role = canonical_role_name(requested_role)
        if canonical_requested_role not in effective_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Role '{canonical_requested_role}' is not allowed for {app_scope or 'this'} app",
            )
        return canonical_requested_role, effective_roles, False

    if len(effective_roles) == 1:
        return effective_roles[0], effective_roles, False

    if require_explicit_scope_selection:
        return None, effective_roles, True

    return effective_roles[0], effective_roles, False


@router.post("/register/options", response_model=PasskeyOptionsResponse)
def create_registration_options(
    payload: PasskeyRegistrationOptionsRequest,
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(get_session),
):
    if not settings.PASSKEY_ENABLED:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Passkey login is disabled")

    data = PasskeyService.generate_registration_options(db, user=current_user)
    return PasskeyOptionsResponse(**data)


@router.post("/register/verify", response_model=PasskeyRegistrationVerifyResponse)
def verify_registration(
    payload: PasskeyRegistrationVerifyRequest,
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(get_session),
):
    if not settings.PASSKEY_ENABLED:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Passkey login is disabled")

    credential = PasskeyService.verify_registration(
        db,
        user=current_user,
        challenge_id=payload.challenge_id,
        credential=payload.credential,
        passkey_name=payload.passkey_name,
    )

    return PasskeyRegistrationVerifyResponse(
        success=True,
        message="Passkey registered successfully",
        credential=_to_credential_info(credential),
    )


@router.post("/auth/options", response_model=PasskeyOptionsResponse)
def create_authentication_options(
    payload: PasskeyOptionsRequest,
    db: Session = Depends(get_session),
):
    if not settings.PASSKEY_ENABLED:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Passkey login is disabled")

    data = PasskeyService.generate_authentication_options(db, username=payload.username)
    return PasskeyOptionsResponse(**data)


@router.post("/auth/verify", response_model=LoginResponse)
def verify_authentication(
    payload: PasskeyVerifyRequest,
    request: Request,
    db: Session = Depends(get_session),
):
    if not settings.PASSKEY_ENABLED:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Passkey login is disabled")

    user, _ = PasskeyService.verify_authentication(
        db,
        challenge_id=payload.challenge_id,
        credential=payload.credential,
    )

    try:
        app_scope = resolve_app_scope(
            request_scope=payload.app_scope,
            header_scope=request.headers.get("X-App-Scope"),
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        )

    selected_role, user_roles, needs_selection = _resolve_selected_role(
        db,
        user,
        payload.role,
        app_scope=app_scope,
        require_explicit_scope_selection=True,
    )
    if needs_selection:
        return LoginResponse(
            success=False,
            message="Please select a role to continue",
            requires_role_selection=True,
            available_roles=user_roles,
            user=user.model_dump(exclude={"hashed_password"}),
        )

    assert selected_role is not None

    user.last_login = datetime.now(UTC)
    db.add(user)
    db.commit()
    db.refresh(user)

    token_jti = str(uuid.uuid4())
    refresh_token = create_refresh_token(subject=user.id, jti=token_jti)
    session = AuthService.create_user_session(
        db=db,
        user_id=user.id,
        refresh_token=refresh_token,
        request=request,
        token_jti=token_jti,
        ip_address=_extract_client_ip(request),
        user_agent="Passkey",
    )
    sid = str(session.id) if session and session.id is not None else token_jti
    access_token = create_access_token(subject=user.id, extra_claims={"sid": sid})

    selected_role_obj = next((role for role in deps.get_active_roles_for_user_id(db, user.id) if canonical_role_name(role.name) == selected_role), None)
    role_identifier = selected_role_obj.id if selected_role_obj else selected_role
    if selected_role_obj and user.role_id != selected_role_obj.id:
        user.role_id = selected_role_obj.id
        db.add(user)
        db.commit()
        db.refresh(user)

    permissions = AuthService.get_permissions_for_role(db, role_identifier)
    menu_data = AuthService.get_menu_for_role(db, role_identifier)

    return LoginResponse(
        success=True,
        access_token=access_token,
        refresh_token=refresh_token,
        user=user.model_dump(exclude={"hashed_password"}),
        role=selected_role,
        available_roles=user_roles,
        permissions=permissions,
        menu=menu_data,
    )


@router.get("", response_model=PasskeyListResponse)
def list_passkeys(
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(get_session),
):
    items = PasskeyService.list_passkeys(db, user_id=current_user.id)
    return PasskeyListResponse(items=[_to_credential_info(item) for item in items])


@router.delete("/{credential_id}", response_model=PasskeyOperationResponse)
def delete_passkey(
    credential_id: str,
    current_user: User = Depends(deps.get_current_user),
    db: Session = Depends(get_session),
):
    PasskeyService.deactivate_passkey(db, user_id=current_user.id, credential_id=credential_id)
    return PasskeyOperationResponse(success=True, message="Passkey removed")
