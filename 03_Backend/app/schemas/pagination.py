from typing import Literal

from pydantic import BaseModel, Field


class PaginationParams(BaseModel):
    page: int = Field(1, ge=1, description="Page number (1-indexed)")
    page_size: int = Field(20, ge=1, le=100, description="Items per page")
    sort: str | None = Field(None, description="Field to sort by")
    order: Literal["asc", "desc"] = Field("asc", description="Sort direction")
    search: str | None = Field(None, description="Search term")


class PaginatedResult[T](BaseModel):
    items: list[T]
    total: int
    page: int
    page_size: int
    total_pages: int
