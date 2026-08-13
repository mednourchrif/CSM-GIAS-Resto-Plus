"""Receipt API contracts."""

from datetime import date, datetime

from pydantic import BaseModel, Field

from app.schemas.base import BaseResponse
from app.schemas.pagination import PaginationParams


class ReceiptResponse(BaseResponse):
    numero: str
    repas_uuid: str
    utilisateur_uuid: str
    nom: str
    prenom: str
    matricule: str | None = None
    type_utilisateur: str
    categorie_uuid: str
    categorie_nom: str
    type_identification: str
    date_repas: date
    heure_repas: datetime
    nombre_impressions: int = 0
    derniere_impression: datetime | None = None
    qr_token: str | None = None


class ReceiptQrRequest(BaseModel):
    token: str = Field(min_length=20, max_length=300)


class ReceiptFilterParams(PaginationParams):
    date_from: date | None = None
    date_to: date | None = None
    category: str | None = Field(None, max_length=100)
    user_type: str | None = Field(None, max_length=20)
    identification_type: str | None = Field(None, max_length=20)
