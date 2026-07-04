"""JWT token generation and verification using PyJWT.

Design decisions
----------------
* **HS256** — symmetric HMAC-SHA256.  The fastest option for a single-
  service deployment.  RS256 would be preferred if other services needed
  to verify tokens without knowing the signing key.
* **Claims** — ``sub`` (admin ``id`` as string), ``uuid``, ``role``,
  ``type``, ``exp``, ``iat``.  No PII (name, email) is embedded so that
  token contents remain opaque.
* **Leeway** — 10 seconds is allowed for clock skew between microservices
  that may verify tokens.
* **No refresh tokens** — the current strategy issues short-lived access
  tokens only.  The client re-authenticates when the token expires.
"""

from datetime import UTC, datetime, timedelta

import jwt

from app.core.config import settings
from app.core.exceptions import UnauthorizedException


class JWTService:
    """Stateless JWT token operations.

    Usage::

        jwt_service = JWTService()
        token = jwt_service.create_access_token(
            sub="42", uuid="abc-def", role="super-admin"
        )
        claims = jwt_service.decode_access_token(token)
    """

    # Standard leeway for clock skew (seconds)
    _LEEWAY: int = 10

    def __init__(self) -> None:
        self._secret: str = settings.JWT_SECRET_KEY
        self._algorithm: str = settings.JWT_ALGORITHM
        self._expire_minutes: int = settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def create_access_token(
        self,
        sub: str,
        uuid: str,
        role: str | None = None,
        user_type: str | None = None,
        expires_delta: timedelta | None = None,
    ) -> str:
        """Generate a signed JWT access token.

        :param sub: Subject — the admin's ``id`` as a string.
        :param uuid: The admin's UUID for cross-reference.
        :param role: The admin's role name (``None`` if unassigned).
        :param user_type: The ``utilisateur.type`` discriminator.
        :param expires_delta: Custom expiry (defaults to settings).
        :returns: The encoded JWT string.
        """
        now = datetime.now(UTC)
        expire = now + (expires_delta or timedelta(minutes=self._expire_minutes))

        payload = {
            "sub": sub,
            "uuid": uuid,
            "role": role,
            "type": user_type,
            "iat": now,
            "exp": expire,
        }

        return jwt.encode(payload, self._secret, algorithm=self._algorithm)

    def decode_access_token(self, token: str) -> dict:
        """Verify and decode a JWT access token.

        :param token: The raw JWT string (without ``Bearer `` prefix).
        :returns: The decoded claims dictionary.
        :raises UnauthorizedException: If the token is invalid, expired,
            or tampered with.
        """
        try:
            payload: dict = jwt.decode(
                token,
                self._secret,
                algorithms=[self._algorithm],
                leeway=self._LEEWAY,
                options={"require": ["sub", "exp", "iat"]},
            )
            return payload
        except jwt.ExpiredSignatureError:
            raise UnauthorizedException(
                message="Token expiré. Veuillez vous reconnecter.",
                details={"reason": "expired"},
            ) from None
        except jwt.InvalidTokenError as exc:
            raise UnauthorizedException(
                message="Token invalide ou corrompu.",
                details={"reason": str(exc)},
            ) from None
