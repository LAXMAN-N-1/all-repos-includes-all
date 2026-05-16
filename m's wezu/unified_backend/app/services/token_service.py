from datetime import datetime, UTC, timedelta
import hashlib
from jose import JWTError, jwt
from sqlmodel import select, Session
from app.models.oauth import BlacklistedToken
from app.core.config import settings
from app.utils.datetime_utils import utcnow

import logging

logger = logging.getLogger(__name__)


def _token_fingerprint(token: str) -> str:
    return f"sha256:{hashlib.sha256(token.encode('utf-8')).hexdigest()}"


def _blacklist_lookup_keys(token: str) -> list[str]:
    """
    Backward-compatible lookup:
    - new rows store token fingerprints
    - legacy rows may still contain raw token values
    """
    normalized = (token or "").strip()
    if not normalized:
        return []
    keys = [_token_fingerprint(normalized), normalized]
    seen: set[str] = set()
    unique: list[str] = []
    for key in keys:
        if key and key not in seen:
            seen.add(key)
            unique.append(key)
    return unique


class TokenService:
    @staticmethod
    def blacklist_token(db: Session, token: str):
        """Add token to blacklist"""
        normalized = (token or "").strip()
        if not normalized:
            return

        token_key = _token_fingerprint(normalized)
        existing = db.exec(
            select(BlacklistedToken).where(
                BlacklistedToken.token.in_(_blacklist_lookup_keys(normalized))
            )
        ).first()
        if existing:
            return

        expires_at = utcnow() + timedelta(
            minutes=max(int(settings.ACCESS_TOKEN_EXPIRE_MINUTES), 1)
        )
        try:
            payload = jwt.get_unverified_claims(normalized)
            exp = payload.get("exp")
            if exp:
                expires_at = datetime.fromtimestamp(int(exp), UTC)
        except (JWTError, ValueError, TypeError):
            logger.warning("token.blacklist_claims_unavailable", exc_info=True)

        blacklisted = BlacklistedToken(token=token_key, expires_at=expires_at)
        db.add(blacklisted)
        db.commit()

    @staticmethod
    def cleanup_expired_tokens(db: Session):
        """Remove tokens from blacklist that have already expired in time"""
        db.query(BlacklistedToken).filter(BlacklistedToken.expires_at < utcnow()).delete()
        db.commit()
