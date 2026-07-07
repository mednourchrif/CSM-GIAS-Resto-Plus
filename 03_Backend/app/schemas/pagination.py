from datetime import date
from typing import Literal

from pydantic import BaseModel, Field


class PaginationParams(BaseModel):
    page: int = Field(1, ge=1, description="Page number (1-indexed)")
    page_size: int = Field(20, ge=1, le=100, description="Items per page")
    sort: str | None = Field(None, description="Field to sort by")
    order: Literal["asc", "desc"] = Field("asc", description="Sort direction")
    search: str | None = Field(None, description="Search term (name, UUID, or email)")


class MealFilterParams(PaginationParams):
    """Extended params for listing meals with additional filters."""

    date_from: date | None = Field(None, description="Filter: start date (inclusive)")
    date_to: date | None = Field(None, description="Filter: end date (inclusive)")
    categorie_uuid: str | None = Field(None, description="Filter by meal category UUID")
    type_identification: str | None = Field(
        None, description="Filter by id method (QR or FACE)",
    )
    user_type: str | None = Field(
        None, description="Filter by user type (EMPLOYE, STAGIAIRE, VISITEUR)",
    )


class PaginatedResult[T](BaseModel):
    items: list[T]
    total: int
    page: int
    page_size: int
    total_pages: int
