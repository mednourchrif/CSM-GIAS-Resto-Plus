"""Production configuration and QR-only face-isolation acceptance tests."""

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pydantic import ValidationError
from sqlalchemy.orm import Session

from app.core.config import DevelopmentSettings, ProductionSettings
from app.core.config import TestingSettings as AppTestingSettings
from app.core.exceptions import BusinessException
from app.main import _register_middleware
from app.services.face_service import FaceService


def _production_settings(**overrides: object) -> ProductionSettings:
    values: dict[str, object] = {
        "APP_ENVIRONMENT": "production",
        "APP_SECRET_KEY": "a" * 48,
        "JWT_SECRET_KEY": "b" * 48,
        "CORS_ORIGINS": ["https://resto.example.com"],
        "TRUSTED_HOSTS": ["api.example.com"],
        "TABLET_API_KEY": "device-key-" + ("c" * 32),
        "FACE_ENGINE": "disabled",
        "TZ": "Africa/Tunis",
    }
    values.update(overrides)
    return ProductionSettings(_env_file=None, **values)


def test_qr_only_production_configuration_is_valid() -> None:
    configured = _production_settings()

    assert configured.is_production
    assert configured.FACE_ENGINE == "disabled"
    assert configured.TZ == "Africa/Tunis"
    assert configured.API_DOCS_ENABLED is False


def test_development_keeps_api_docs_enabled() -> None:
    configured = DevelopmentSettings(
        _env_file=None,
        APP_ENVIRONMENT="development",
        APP_SECRET_KEY="development-app-secret",
        JWT_SECRET_KEY="development-jwt-secret",
    )

    assert configured.API_DOCS_ENABLED is True


def test_production_requires_an_explicit_valid_timezone() -> None:
    with pytest.raises(ValidationError, match="TZ must be explicitly configured"):
        _production_settings(TZ="")
    with pytest.raises(ValidationError, match="valid IANA timezone"):
        _production_settings(TZ="Africa/Unknown")


def test_production_rejects_development_face_stub() -> None:
    with pytest.raises(ValidationError, match="development-only"):
        _production_settings(
            FACE_ENGINE="stub",
            BIOMETRIC_ENCRYPTION_KEY="",
        )


def test_development_accepts_physical_device_lan_host() -> None:
    config = DevelopmentSettings(
        _env_file=None,
        APP_ENVIRONMENT="development",
        APP_SECRET_KEY="development-app-secret",
        JWT_SECRET_KEY="development-jwt-secret",
        TRUSTED_HOSTS=["api.example.com"],
    )
    application = FastAPI()

    @application.get("/probe")
    def probe() -> dict[str, bool]:
        return {"ok": True}

    _register_middleware(application, config)

    with TestClient(application, base_url="http://192.168.1.25:8000") as client:
        response = client.get("/probe")

    assert response.status_code == 200
    assert response.json() == {"ok": True}


def test_disabled_face_service_fails_closed_without_affecting_qr(
    db_session: Session,
) -> None:
    config = AppTestingSettings(
        _env_file=None,
        APP_SECRET_KEY="test-app-secret",
        JWT_SECRET_KEY="test-jwt-secret",
        FACE_ENGINE="disabled",
    )
    service = FaceService(config=config)

    with pytest.raises(BusinessException, match="indisponible"):
        service.identify(db_session, "not-decoded-because-engine-is-disabled")
