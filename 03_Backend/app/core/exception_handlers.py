from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from loguru import logger
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.core.exceptions import ApplicationException
from app.schemas.response import ErrorResponse


async def application_exception_handler(
    request: Request, exc: ApplicationException
) -> JSONResponse:
    """Handle custom ApplicationException subclasses."""
    logger.warning(
        "Application exception — code={} status={} path={} details={}",
        exc.error_code,
        exc.status_code,
        request.url.path,
        exc.details,
    )
    return JSONResponse(
        status_code=exc.status_code,
        content=ErrorResponse(
            error_code=exc.error_code,
            message=exc.message,
            details=exc.details,
        ).model_dump(),
    )


async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    """Handle Pydantic/FastAPI validation errors and return a structured response."""
    errors = exc.errors()
    logger.warning(
        "Validation error — path={} errors={}",
        request.url.path,
        errors,
    )
    return JSONResponse(
        status_code=422,
        content=ErrorResponse(
            error_code="VALIDATION_ERROR",
            message="Erreur de validation des données envoyées",
            details=errors,
        ).model_dump(),
    )


async def http_exception_handler(request: Request, exc: StarletteHTTPException) -> JSONResponse:
    """Handle standard HTTP exceptions (404, 405, 429, etc.)."""
    logger.warning(
        "HTTP exception — status={} path={} detail={}",
        exc.status_code,
        request.url.path,
        exc.detail,
    )
    return JSONResponse(
        status_code=exc.status_code,
        content=ErrorResponse(
            error_code=f"HTTP_{exc.status_code}",
            message=str(exc.detail),
        ).model_dump(),
    )


async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Catch-all for unexpected errors — logs full traceback, returns 500."""
    logger.opt(exception=exc).error(
        "Unhandled exception — path={} method={}",
        request.url.path,
        request.method,
    )
    return JSONResponse(
        status_code=500,
        content=ErrorResponse(
            error_code="INTERNAL_ERROR",
            message="Une erreur interne est survenue. Veuillez réessayer plus tard.",
        ).model_dump(),
    )
