from fastapi import APIRouter, Depends

from app.core.config import BaseAppSettings
from app.core.constants import APP_NAME, APP_VERSION, AppStatus
from app.core.dependencies import get_settings_dependency
from app.database.session import check_database_health
from app.schemas.response import MetadataResponse, SuccessResponse

router = APIRouter()


@router.get(
    "/health",
    summary="Health check",
    description="Returns the current health status of the application including "
    "database connectivity, version, and environment.",
    response_model=SuccessResponse[MetadataResponse],
)
async def health(
    settings: BaseAppSettings = Depends(get_settings_dependency),
) -> SuccessResponse[MetadataResponse]:
    db_healthy = check_database_health()

    status = AppStatus.HEALTHY if db_healthy else AppStatus.DEGRADED

    return SuccessResponse(
        data=MetadataResponse(
            name=APP_NAME,
            version=APP_VERSION,
            environment=settings.APP_ENVIRONMENT,
            status=status,
        )
    )


@router.get(
    "/ready",
    summary="Readiness check",
    description="Returns whether the application is ready to accept traffic. "
    "Fails if the database is unreachable.",
    response_model=SuccessResponse[dict],
)
async def ready(
    settings: BaseAppSettings = Depends(get_settings_dependency),
) -> SuccessResponse[dict]:
    db_healthy = check_database_health()

    return SuccessResponse(
        data={
            "ready": db_healthy,
            "database": db_healthy,
            "environment": settings.APP_ENVIRONMENT,
        }
    )
