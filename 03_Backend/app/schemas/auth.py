"""Authentication schemas — login request, token response, admin summary."""

from datetime import datetime

from pydantic import Field

from app.schemas.base import BaseSchema


class LoginRequest(BaseSchema):
    """Payload for ``POST /api/v1/auth/login``."""

    email: str = Field(
        ...,
        max_length=255,
        description="Adresse email de l'administrateur.",
        examples=["admin@csm-gias.resto"],
    )
    mot_de_passe: str = Field(
        ...,
        min_length=1,
        max_length=128,
        description="Mot de passe de l'administrateur.",
        examples=["********"],
    )


class TokenResponse(BaseSchema):
    """Response returned on successful authentication."""

    access_token: str = Field(
        ...,
        description="JWT token à utiliser dans l'en-tête Authorization.",
    )
    token_type: str = Field(
        default="bearer",
        description="Type de token (toujours ``bearer``).",
    )
    expires_in: int = Field(
        ...,
        description="Durée de validité du token en secondes.",
    )


class AdminSummary(BaseSchema):
    """Lightweight administrator summary included in the login response."""

    id: int
    uuid: str
    nom: str
    prenom: str
    email: str | None = None
    role: str | None = Field(
        default=None,
        description="Nom du rôle de l'administrateur (si assigné).",
    )
    derniere_connexion: datetime | None = Field(
        default=None,
        description="Date de la dernière connexion réussie.",
    )


class LoginResponse(BaseSchema):
    """Full response returned on successful authentication."""

    token: TokenResponse
    admin: AdminSummary
