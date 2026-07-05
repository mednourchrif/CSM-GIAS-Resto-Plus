"""Authentication endpoints — login and current-user retrieval.

Only administrators can authenticate.  Employees, interns, and visitors
never use these endpoints.

Endpoints
---------
* ``POST /api/v1/auth/login`` — Authenticate with email + password.
* ``GET  /api/v1/auth/me``    — Return the currently authenticated admin.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.auth import AdminSummary, LoginRequest, LoginResponse, TokenResponse
from app.schemas.response import SuccessResponse
from app.security.dependencies import get_current_admin
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["authentication"])

_service = AuthService()


@router.post(
    "/login",
    summary="Authentification administrateur",
    description=(
        "Authentifie un administrateur avec son email et mot de passe. "
        "Retourne un token JWT à utiliser dans l'en-tête ``Authorization`` "
        "pour les requêtes ultérieures."
    ),
    response_model=SuccessResponse[LoginResponse],
)
async def login(
    body: LoginRequest,
    db: Session = Depends(get_db),
) -> SuccessResponse[LoginResponse]:
    """Authenticate an administrator and return a JWT token.

    The token must be sent as ``Authorization: Bearer <token>`` in
    subsequent requests.
    """
    token, expires_in, admin = _service.authenticate(
        db=db,
        email=body.email,
        password=body.mot_de_passe,
    )

    role_name = admin.role.nom if admin.role else None

    return SuccessResponse(
        data=LoginResponse(
            token=TokenResponse(
                access_token=token,
                token_type="bearer",
                expires_in=expires_in,
            ),
            admin=AdminSummary(
                id=admin.id,
                uuid=admin.uuid,
                nom=admin.nom,
                prenom=admin.prenom,
                email=admin.email,
                role=role_name,
                derniere_connexion=admin.derniere_connexion,
            ),
        )
    )


@router.get(
    "/me",
    summary="Administrateur connecté",
    description=(
        "Retourne les informations de l'administrateur actuellement "
        "authentifié.  Nécessite un token JWT valide."
    ),
    response_model=SuccessResponse[AdminSummary],
)
async def me(
    admin: Admin = Depends(get_current_admin),
) -> SuccessResponse[AdminSummary]:
    """Return the currently authenticated administrator's profile."""
    role_name = admin.role.nom if admin.role else None

    return SuccessResponse(
        data=AdminSummary(
            id=admin.id,
            uuid=admin.uuid,
            nom=admin.nom,
            prenom=admin.prenom,
            email=admin.email,
            role=role_name,
            derniere_connexion=admin.derniere_connexion,
        )
    )
