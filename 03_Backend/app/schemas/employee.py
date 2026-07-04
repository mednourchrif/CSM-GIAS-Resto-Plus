"""Employee schemas."""

from datetime import datetime

from pydantic import Field

from app.models.employee import StatutEnrolement
from app.schemas.base import BaseResponse, BaseSchema


class EmployeeCreate(BaseSchema):
    """Payload for creating an employee."""

    matricule: str = Field(
        ...,
        min_length=1,
        max_length=20,
        description="Unique HR employee number.",
    )
    photo_path: str | None = Field(
        None,
        max_length=500,
        description="Filesystem path to the employee's portrait.",
    )


class EmployeeUpdate(BaseSchema):
    """Payload for updating an employee."""

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
