"""Statistics response schemas."""

from pydantic import BaseModel


class MealCountByDate(BaseModel):
    date: str
    count: int


class MealDistributionItem(BaseModel):
    name: str
    count: int


class UserTypeDistributionItem(BaseModel):
    type: str
    count: int


class RegistrationMethodItem(BaseModel):
    method: str
    count: int


class PeakHourItem(BaseModel):
    hour: int
    count: int


class RecentRegistrationItem(BaseModel):
    uuid: str
    utilisateur_uuid: str
    nom: str | None = None
    prenom: str | None = None
    type_identification: str
    date_repas: str
    heure_repas: str
    categorie_nom: str | None = None


class DashboardStatsResponse(BaseModel):
    overview: dict
    meals_per_day: list[MealCountByDate]
    meal_distribution: list[MealDistributionItem]
    user_type_distribution: list[UserTypeDistributionItem]
    registration_methods: list[RegistrationMethodItem]
    peak_hours: list[PeakHourItem]
    recent_registrations: list[RecentRegistrationItem]
