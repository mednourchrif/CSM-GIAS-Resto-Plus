"""Reports endpoint — aggregated restaurant activity reports."""

from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.reports import ReportFilterParams
from app.schemas.response import SuccessResponse
from app.security.dependencies import require_admin
from app.services.report_service import ReportService

router = APIRouter(prefix="/reports", tags=["reports"])


@router.get(
    "/generate",
    summary="Generate restaurant activity report",
    description="Returns aggregated meal data with filters and configurable granularity.",
    response_model=SuccessResponse,
)
async def generate_report(
    date_from: date | None = Query(None, description="Start date (YYYY-MM-DD)"),
    date_to: date | None = Query(None, description="End date (YYYY-MM-DD)"),
    granularity: str = Query("daily", description="Grouping: daily, weekly, monthly"),
    user_type: str | None = Query(None, description="User type filter (EMPLOYE, STAGIAIRE, VISITEUR)"),
    type_identification: str | None = Query(None, description="Identification method filter (QR, FACE)"),
    categorie_uuid: str | None = Query(None, description="Meal category UUID filter"),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse:
    """Generate a restaurant activity report."""
    params = ReportFilterParams(
        date_from=date_from,
        date_to=date_to,
        granularity=granularity,
        user_type=user_type,
        type_identification=type_identification,
        categorie_uuid=categorie_uuid,
    )
    report = ReportService(db, params).generate()
    return SuccessResponse(data=report.model_dump())
