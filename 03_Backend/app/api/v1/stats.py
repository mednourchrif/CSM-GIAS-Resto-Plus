"""Statistics dashboard endpoint."""

from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.repositories.statistics import DashboardStats
from app.schemas.response import SuccessResponse
from app.security.dependencies import require_admin

router = APIRouter(prefix="/stats", tags=["statistics"])


@router.get(
    "/dashboard",
    summary="Statistiques du tableau de bord",
    description="Retourne toutes les statistiques pour le tableau de bord d'administration.",
    response_model=SuccessResponse,
)
async def get_dashboard_stats(
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse:
    """Aggregate and return all dashboard statistics."""
    stats = DashboardStats(db, date.today()).compute()
    return SuccessResponse(data=stats.model_dump())
