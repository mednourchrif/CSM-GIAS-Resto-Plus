"""CSM-GIAS Resto+ — Application Entry Point

This module creates the FastAPI application using a factory function
and provides the Uvicorn entry point for ``python -m app.main``.
"""

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from loguru import logger
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.api.v1 import router as api_v1_router
from app.core.config import get_settings
from app.core.constants import (
    API_DOCS_PREFIX,
    API_REDOC_PREFIX,
    API_V1_PREFIX,
    APP_DESCRIPTION,
    APP_NAME,
    APP_VERSION,
    CONTACT_EMAIL,
    CONTACT_NAME,
    LICENSE_NAME,
)
from app.core.exception_handlers import (
    application_exception_handler,
    http_exception_handler,
    unhandled_exception_handler,
    validation_exception_handler,
)
from app.core.exceptions import ApplicationException
from app.core.lifespan import lifespan
from app.middlewares import CoreMiddleware, SecurityHeadersMiddleware


def create_app() -> FastAPI:
    """Application factory.

    Creates and configures a FastAPI instance with:
    - OpenAPI metadata
    - Lifespan (startup/shutdown)
    - Middleware stack
    - Exception handlers
    - Routers
    """
    settings = get_settings()

    application = FastAPI(
        title=APP_NAME,
        description=APP_DESCRIPTION,
        version=APP_VERSION,
        docs_url=f"{API_DOCS_PREFIX}",
        redoc_url=f"{API_REDOC_PREFIX}",
        openapi_url="/openapi.json",
        lifespan=lifespan,
        contact={
            "name": CONTACT_NAME,
            "email": CONTACT_EMAIL,
        },
        license_info={
            "name": LICENSE_NAME,
        },
        swagger_ui_parameters={
            "displayRequestDuration": True,
            "persistAuthorization": True,
            "tryItOutEnabled": True,
        },
    )

    # ── Middleware ────────────────────────────────────────────────────────
    _register_middleware(application, settings)

    # ── Exception Handlers ────────────────────────────────────────────────
    _register_exception_handlers(application)

    # ── Routers ──────────────────────────────────────────────────────────
    application.include_router(api_v1_router, prefix=API_V1_PREFIX)

    logger.info("Application factory completed — {} v{}", APP_NAME, APP_VERSION)

    return application


def _register_middleware(application: FastAPI, settings) -> None:
    """Register middleware in order of execution (last added = first executed)."""
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    application.add_middleware(
        GZipMiddleware,
        minimum_size=1000,
    )

    application.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=(["*"] if settings.is_development else None),
    )

    application.add_middleware(SecurityHeadersMiddleware)
    application.add_middleware(CoreMiddleware)


def _register_exception_handlers(application: FastAPI) -> None:
    """Register global exception handlers.

    Order matters: more specific handlers must be registered first.
    """
    application.add_exception_handler(ApplicationException, application_exception_handler)
    application.add_exception_handler(RequestValidationError, validation_exception_handler)
    application.add_exception_handler(StarletteHTTPException, http_exception_handler)
    application.add_exception_handler(Exception, unhandled_exception_handler)


app = create_app()


if __name__ == "__main__":
    import uvicorn

    settings = get_settings()
    uvicorn.run(
        "app.main:app",
        host=settings.SERVER_HOST,
        port=settings.SERVER_PORT,
        reload=settings.is_development,
        log_level=settings.LOG_LEVEL.lower(),
        timeout_keep_alive=settings.SERVER_TIMEOUT_KEEPALIVE,
    )
