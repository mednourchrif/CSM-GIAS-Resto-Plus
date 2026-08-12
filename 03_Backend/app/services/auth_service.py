"""Authentication service — administrator login orchestration.

This service sits between the API layer and the data layer.  It
validates credentials, enforces account status rules, issues JWT
tokens, and updates session-tracking columns on the admin record.

Business rules enforced
-----------------------
1. Only ``Admin`` (type ``ADMINISTRATEUR``) can authenticate.
2. The account must have ``statut == ACTIF``.
3. The account must not be soft-deleted (``date_suppression IS NULL``).
4. The password must match the stored bcrypt hash.
5. On success: ``derniere_connexion`` is updated, ``tentatives_echouees``
   is reset to 0.
"""

from datetime import UTC, datetime

from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.exceptions import UnauthorizedException
from app.models.admin import Admin
from app.models.user import StatutUtilisateur
from app.repositories.user import UserRepository
from app.security.jwt import JWTService
from app.security.password import PasswordService


class AuthService:
    """Orchestrates administrator authentication and token issuance."""

    def __init__(
        self,
        user_repository: UserRepository | None = None,
        jwt_service: JWTService | None = None,
        password_service: PasswordService | None = None,
    ) -> None:
        self._user_repo = user_repository or UserRepository()
        self._jwt = jwt_service or JWTService()
        self._password = password_service or PasswordService()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def authenticate(self, db: Session, email: str, password: str) -> tuple[str, int, Admin]:
        """Authenticate an administrator and return a JWT token.

        :param db: Active database session.
        :param email: The admin's email address.
        :param password: The admin's plain-text password.
        :returns: A tuple of ``(token, expires_in_seconds, admin)``.
        :raises UnauthorizedException: If any validation fails.
        """
        # 1. Find user by email
        user = self._user_repo.get_by_email(db, email)
        if user is None:
            raise UnauthorizedException(
                message="Email ou mot de passe incorrect.",
            )

        # 2. Must be an Admin
        if not isinstance(user, Admin):
            raise UnauthorizedException(
                message="Email ou mot de passe incorrect.",
            )

        admin: Admin = user

        # 3. Account must be active
        if admin.statut != StatutUtilisateur.ACTIF:
            raise UnauthorizedException(
                message="Ce compte est désactivé. Contactez un administrateur.",
                details={"reason": "inactive"},
            )

        # 4. Account must not be soft-deleted
        if admin.date_suppression is not None:
            raise UnauthorizedException(
                message="Ce compte a été supprimé.",
                details={"reason": "deleted"},
            )

        # 5. Password must match
        if not admin.mot_de_passe:
            raise UnauthorizedException(
                message="Email ou mot de passe incorrect.",
            )

        if not self._password.verify(password, admin.mot_de_passe):
            admin.tentatives_echouees += 1
            if admin.tentatives_echouees >= settings.LOGIN_RATE_LIMIT_ATTEMPTS:
                admin.statut = StatutUtilisateur.INACTIF
            raise UnauthorizedException(
                message="Email ou mot de passe incorrect.",
                details={
                    "reason": "invalid_credentials",
                    "failed_attempts": admin.tentatives_echouees,
                    "locked": admin.statut == StatutUtilisateur.INACTIF,
                },
            )

        # 6. Generate JWT
        role_name = admin.role.nom if admin.role else None
        expire_minutes = settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES

        token = self._jwt.create_access_token(
            sub=str(admin.id),
            uuid=admin.uuid,
            role=role_name,
            user_type=str(admin.type),
        )

        # 7. Update session tracking
        admin.derniere_connexion = datetime.now(UTC)
        admin.tentatives_echouees = 0
        db.flush()

        expires_in = expire_minutes * 60
        return token, expires_in, admin
