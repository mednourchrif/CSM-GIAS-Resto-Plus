"""Intern schemas."""

from datetime import date, datetime

from pydantic import Field

from app.models.user import Langue, StatutUtilisateur
from app.schemas.base import BaseResponse, BaseSchema


class InternCreate(BaseSchema):
    """Payload for creating an intern."""

    nom: str = Field(..., min_length=1, max_length=100, examples=["Martin"])
    prenom: str = Field(..., min_length=1, max_length=100, examples=["Sophie"])
    email: str | None = Field(None, max_length=255, examples=["sophie.martin@etudiant.com"])
    mot_de_passe: str | None = Field(None, min_length=8, max_length=128, examples=["st@ge2024!"])
    statut: StatutUtilisateur = StatutUtilisateur.ACTIF
    langue: Langue | None = None
    matricule: str = Field(..., min_length=1, max_length=20, examples=["STG-2024-045"])
    date_debut_stage: date
    date_fin_stage: date


class InternUpdate(BaseSchema):
    """Payload for updating an intern (all fields optional)."""

    nom: str | None = Field(None, min_length=1, max_length=100)
    prenom: str | None = Field(None, min_length=1, max_length=100)
    email: str | None = Field(None, max_length=255)
    mot_de_passe: str | None = Field(None, min_length=8, max_length=128)
    statut: StatutUtilisateur | None = None
    langue: Langue | None = None
    matricule: str | None = Field(None, min_length=1, max_length=20)
    date_debut_stage: date | None = None
    date_fin_stage: date | None = None


class InternResponse(BaseResponse):
    """Schema returned by intern CRUD endpoints."""

    nom: str
    prenom: str
    email: str | None = None
    matricule: str
    date_debut_stage: date
    date_fin_stage: date
    statut: StatutUtilisateur = StatutUtilisateur.ACTIF
    langue: Langue | None = None
    date_suppression: datetime | None = None
