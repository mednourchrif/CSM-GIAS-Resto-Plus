"""Visitor schemas."""

from datetime import date, datetime

from pydantic import Field

from app.models.user import Langue, StatutUtilisateur
from app.schemas.base import BaseResponse, BaseSchema


class VisitorCreate(BaseSchema):
    """Payload for creating a visitor."""

    nom: str = Field(..., min_length=1, max_length=100)
    prenom: str = Field(..., min_length=1, max_length=100)
    email: str | None = Field(None, max_length=255)
    mot_de_passe: str | None = Field(None, min_length=8, max_length=128)
    statut: StatutUtilisateur = StatutUtilisateur.ACTIF
    langue: Langue | None = None
    societe: str | None = Field(None, max_length=255)
    date_visite: date


class VisitorUpdate(BaseSchema):
    """Payload for updating a visitor (all fields optional)."""

    nom: str | None = Field(None, min_length=1, max_length=100)
    prenom: str | None = Field(None, min_length=1, max_length=100)
    email: str | None = Field(None, max_length=255)
    mot_de_passe: str | None = Field(None, min_length=8, max_length=128)
    statut: StatutUtilisateur | None = None
    langue: Langue | None = None
    societe: str | None = Field(None, max_length=255)
    date_visite: date | None = None


class VisitorResponse(BaseResponse):
    """Schema returned by visitor CRUD endpoints."""

    nom: str
    prenom: str
    email: str | None = None
    societe: str | None = None
    date_visite: date
    statut: StatutUtilisateur = StatutUtilisateur.ACTIF
    langue: Langue | None = None
    date_suppression: datetime | None = None
