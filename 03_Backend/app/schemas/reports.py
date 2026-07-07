"""Report response schemas."""

from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel


class ReportFilterParams(BaseModel):
    date_from: date | None = None
    date_to: date | None = None
    granularity: Literal["daily", "weekly", "monthly"] = "daily"
    user_type: str | None = None
    type_identification: str | None = None
    categorie_uuid: str | None = None


class ReportOverview(BaseModel):
    total_meals: int
    total_employees: int
    total_interns: int
    total_visitors: int
    qr_registrations: int
    face_registrations: int
    failed_recognitions: int
    failed_qr_scans: int
    average_processing_time: float | None = None
    peak_hour: str | None = None
    most_selected_meal: str | None = None


class ReportTimeSeriesItem(BaseModel):
    period: str
    count: int


class ReportDistributionItem(BaseModel):
    label: str
    count: int


class ReportPeakHourItem(BaseModel):
    hour: int
    count: int


class ReportResponse(BaseModel):
    overview: ReportOverview
    meals_per_day: list[ReportTimeSeriesItem]
    meals_by_hour: list[ReportPeakHourItem]
    meals_by_category: list[ReportDistributionItem]
    registration_methods: list[ReportDistributionItem]
    people_by_type: list[ReportDistributionItem]
    period_label: str
    date_from: str
    date_to: str
    generated_at: str
