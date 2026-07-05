"""Admin & Receptionist schemas."""

from datetime import datetime

from pydantic import Field

from app.models.user import Langue, StatutUtilisateur
from app.schemas.base import BaseResponse, BaseSchema


class AdminCreate(BaseSchema):
    """Payload for creating an admin user."""

    role_id: int | None = Field(None, description="FK to the role table.")


class AdminUpdate(BaseSchema):
    """Payload for updating an admin."""

    role_id: int | None = None


class AdminResponse(BaseResponse):
    """Schema returned by admin CRUD endpoints."""

    nom: str
    prenom: str
    email: str | None = None
    role_id: int | None = None
    derniere_connexion: datetime | None = None
    tentatives_echouees: int = 0


class ReceptionistCreate(BaseSchema):
    """Payload for creating a receptionist."""

    nom: str = Field(..., min_length=1, max_length=100, examples=["Bernard"])
    prenom: str = Field(..., min_length=1, max_length=100, examples=["Marie"])
    email: str | None = Field(None, max_length=255, examples=["marie.bernard@csm-gias.resto"])
    mot_de_passe: str | None = Field(None, min_length=8, max_length=128, examples=["accuei1R3sto"])
    statut: StatutUtilisateur = StatutUtilisateur.ACTIF
    langue: Langue | None = None


class ReceptionistUpdate(BaseSchema):
    """Payload for updating a receptionist (all fields optional)."""

    nom: str | None = Field(None, min_length=1, max_length=100)
    prenom: str | None = Field(None, min_length=1, max_length=100)
    email: str | None = Field(None, max_length=255)
    mot_de_passe: str | None = Field(None, min_length=8, max_length=128)
    statut: StatutUtilisateur | None = None
    langue: Langue | None = None


class ReceptionistResponse(BaseResponse):
    """Schema returned by receptionist CRUD endpoints."""

    nom: str
    prenom: str
    email: str | None = None
    statut: StatutUtilisateur = StatutUtilisateur.ACTIF
    langue: Langue | None = None
    date_suppression: datetime | None = None
