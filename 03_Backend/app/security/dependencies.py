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

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
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

# ---------------------------------------------------------------------------
# Repository & JWT service singletons (stateless, safe to share)
# ---------------------------------------------------------------------------

_user_repo = UserRepository()
_jwt_service = JWTService()


# ---------------------------------------------------------------------------
# Current admin dependency
# ---------------------------------------------------------------------------


def get_current_admin(
    db: Session = Depends(get_db),
    credentials: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
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


def require_role(required_nom: str):
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
