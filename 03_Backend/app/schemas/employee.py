"""Employee schemas."""

from datetime import date, datetime

from pydantic import Field

from app.models.employee import StatutEnrolement
from app.models.user import Langue, StatutUtilisateur
from app.schemas.base import BaseResponse, BaseSchema


class EmployeeCreate(BaseSchema):
    """Payload for creating an employee."""

    nom: str = Field(..., min_length=1, max_length=100, examples=["Dupont"])
    prenom: str = Field(..., min_length=1, max_length=100, examples=["Jean"])
    email: str | None = Field(None, max_length=255, examples=["jean.dupont@entreprise.com"])
    mot_de_passe: str | None = Field(None, min_length=8, max_length=128, examples=["s3cur3P@ss"])
    statut: StatutUtilisateur = StatutUtilisateur.ACTIF
    langue: Langue | None = None
    matricule: str = Field(..., min_length=1, max_length=20, examples=["EMP-2024-001"])
    photo_path: str | None = Field(None, max_length=500)


class EmployeeUpdate(BaseSchema):
    """Payload for updating an employee (all fields optional)."""

    nom: str | None = Field(None, min_length=1, max_length=100)
    prenom: str | None = Field(None, min_length=1, max_length=100)
    email: str | None = Field(None, max_length=255)
    mot_de_passe: str | None = Field(None, min_length=8, max_length=128)
    statut: StatutUtilisateur | None = None
    langue: Langue | None = None
    matricule: str | None = Field(None, min_length=1, max_length=20)
    photo_path: str | None = Field(None, max_length=500)


class EmployeeResponse(BaseResponse):
    """Schema returned by employee CRUD endpoints."""

    nom: str
    prenom: str
    email: str | None = None
    matricule: str
    photo_path: str | None = None
    date_enrolement: datetime | None = None
    statut_enrolement: StatutEnrolement = StatutEnrolement.NON_ENROLE
    statut: StatutUtilisateur = StatutUtilisateur.ACTIF
    langue: Langue | None = None
    date_suppression: datetime | None = None


class MealSummaryResponse(BaseResponse):
    """Lightweight meal response for employee detail."""

    categorie_nom: str
    type_identification: str
    date_repas: date
    heure_repas: datetime


class EmployeeDetailResponse(EmployeeResponse):
    """Enriched employee response with today's meal, history, and ID status."""

    today_meal: MealSummaryResponse | None = None
    last_meals: list[MealSummaryResponse] = []
    face_enrolled: bool = False
    qr_generated: bool = False
