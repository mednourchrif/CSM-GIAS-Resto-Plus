"""Authentication and authorisation dependencies for FastAPI routes.

Every protected endpoint uses one of these dependencies to enforce
access control.  They are designed to be composable::

    @router.get("/admin-only")
    def admin_endpoint(admin: Admin = Depends(require_admin)):
        ...

    @router.get("/reception-only")
    def reception_endpoint(admin: Admin = Depends(require_reception)):
        ...

    @router.get("/specific-role")
    def role_endpoint(admin: Admin = Depends(require_role("manager"))):
        ...
"""

import secrets
from collections.abc import Callable
from ipaddress import ip_address

from fastapi import Depends, Request
from fastapi.security import APIKeyHeader, HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.config import BaseAppSettings
from app.core.dependencies import get_db, get_settings_dependency
from app.core.exceptions import ForbiddenException, UnauthorizedException
from app.models.admin import Admin
from app.models.user import StatutUtilisateur, TypeUtilisateur
from app.repositories.user import UserRepository
from app.security.jwt import JWTService

# ---------------------------------------------------------------------------
# HTTP Bearer scheme — drives the OpenAPI "Authorize" button
# ---------------------------------------------------------------------------

_bearer_scheme = HTTPBearer(
    bearerFormat="JWT",
    description="Entrez votre token JWT d'authentification",
    auto_error=True,
)
_optional_bearer_scheme = HTTPBearer(
    bearerFormat="JWT",
    auto_error=False,
)
_tablet_key_scheme = APIKeyHeader(
    name="X-Tablet-Key",
    description="Clé d'accès de la tablette restaurant",
    auto_error=False,
)

# ---------------------------------------------------------------------------
# Repository & JWT service singletons (stateless, safe to share)
# ---------------------------------------------------------------------------

_user_repo = UserRepository()
_jwt_service = JWTService()


# ---------------------------------------------------------------------------
# Current admin dependency
# ---------------------------------------------------------------------------


def _resolve_admin(
    db: Session,
    credentials: HTTPAuthorizationCredentials,
) -> Admin:
    """Extract and validate the current administrator from the JWT token.

    This dependency:
    1. Decodes the Bearer token.
    2. Loads the admin from the database by the ``sub`` (id) claim.
    3. Verifies the account is not disabled or soft-deleted.

    :raises UnauthorizedException: If the token is invalid, expired, or
        the account is disabled/deleted.
    :returns: The authenticated ``Admin`` ORM instance.
    """
    token = credentials.credentials
    payload = _jwt_service.decode_access_token(token)

    admin_id: str | None = payload.get("sub")
    if admin_id is None:
        raise UnauthorizedException(
            message="Token invalide : sujet manquant.",
        )

    try:
        admin = _user_repo.get(db, int(admin_id))
    except (ValueError, TypeError):
        raise UnauthorizedException(
            message="Token invalide : identifiant incorrect.",
        ) from None

    if admin is None:
        raise UnauthorizedException(
            message="Compte administrateur introuvable.",
        )

    if not isinstance(admin, Admin):
        raise UnauthorizedException(
            message="Ce compte n'est pas un administrateur.",
        )

    # ---- Account status checks -----------------------------------------

    if admin.date_suppression is not None:
        raise UnauthorizedException(
            message="Ce compte a été supprimé.",
            details={"reason": "deleted"},
        )

    if admin.statut == StatutUtilisateur.INACTIF:
        raise UnauthorizedException(
            message="Ce compte est désactivé. Contactez un administrateur.",
            details={"reason": "inactive"},
        )

    if admin.statut == StatutUtilisateur.SUPPRIME:
        raise UnauthorizedException(
            message="Ce compte a été supprimé.",
            details={"reason": "supprime"},
        )

    return admin


def get_current_admin(
    db: Session = Depends(get_db),
    credentials: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
) -> Admin:
    """Return the active administrator represented by a Bearer token."""
    return _resolve_admin(db, credentials)


def require_kiosk_access(
    request: Request,
    db: Session = Depends(get_db),
    tablet_key: str | None = Depends(_tablet_key_scheme),
    credentials: HTTPAuthorizationCredentials | None = Depends(_optional_bearer_scheme),
    settings: BaseAppSettings = Depends(get_settings_dependency),
) -> Admin | None:
    """Authorize a kiosk request with a tablet key or an admin token.

    The API key is mandatory for unauthenticated kiosk operation. An admin
    Bearer token remains accepted for diagnostics and API tests. In development
    only, a request may come directly from a private/loopback client so a
    physical device can be tested even when an older debug APK still carries a
    stale key. Production always requires the configured key or an admin token.
    """
    configured_key = settings.TABLET_API_KEY.strip()
    unsafe_values = {"", "change-me", "change-me-to-tablet-api-key"}
    if (
        configured_key not in unsafe_values
        and tablet_key is not None
        and secrets.compare_digest(tablet_key, configured_key)
    ):
        return None

    if settings.is_development and _is_private_client(request):
        return None

    if credentials is not None:
        return _resolve_admin(db, credentials)

    raise UnauthorizedException(
        message="Authentification de la tablette requise.",
    )


def _is_private_client(request: Request) -> bool:
    """Return whether a direct client address is safe for development bypass."""
    if request.client is None:
        return False
    try:
        address = ip_address(request.client.host.split("%", maxsplit=1)[0])
    except ValueError:
        return False
    return address.is_private or address.is_loopback or address.is_link_local


# ---------------------------------------------------------------------------
# Role-based authorisation dependencies
# ---------------------------------------------------------------------------


def require_admin(admin: Admin = Depends(get_current_admin)) -> Admin:
    """Require that the authenticated user is an ``Administrateur``.

    This is the baseline authorisation for all admin-area endpoints.
    Since ``get_current_admin`` already guarantees the user is an ``Admin``,
    this dependency exists primarily for documentation & future flexibility.
    """
    if admin.type != TypeUtilisateur.ADMINISTRATEUR:
        raise ForbiddenException(
            message="Accès réservé aux administrateurs.",
        )
    return admin


def require_reception(admin: Admin = Depends(get_current_admin)) -> Admin:
    """Require that the authenticated user is a ``Reception``.

    Allows both ``Receptionist`` and ``Admin`` types through
    (receptionists can access their screens, admins have full access).
    """
    if admin.type not in (TypeUtilisateur.RECEPTION, TypeUtilisateur.ADMINISTRATEUR):
        raise ForbiddenException(
            message="Accès réservé aux utilisateurs de la réception.",
        )
    return admin


def require_role(required_nom: str) -> Callable[[Admin], Admin]:
    """Factory: return a dependency that requires a specific role name.

    Usage::

        @router.get("/manager-report")
        def manager_report(admin: Admin = Depends(require_role("manager"))):
            ...

    :param required_nom: The ``Role.nom`` that the admin must have.
    :returns: A FastAPI dependency callable.
    """
    if not required_nom or not required_nom.strip():
        raise ValueError("Le nom du rôle requis ne peut pas être vide.")

    def _role_checker(admin: Admin = Depends(get_current_admin)) -> Admin:
        if admin.role is None or admin.role.nom != required_nom:
            raise ForbiddenException(
                message=f"Accès réservé aux utilisateurs avec le rôle « {required_nom} ».",
            )
        if not admin.role.actif:
            raise ForbiddenException(
                message=f"Le rôle « {required_nom} » est désactivé.",
            )
        return admin

    return _role_checker
