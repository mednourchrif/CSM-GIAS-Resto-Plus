"""Runtime settings contract and kiosk access regression tests."""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.dependencies import get_settings_dependency
from app.core.exceptions import ValidationException
from app.services.setting_service import RUNTIME_SETTING_KEYS, SettingService


@pytest.mark.usefixtures("client")
def test_only_effective_settings_are_exposed(db_session: Session) -> None:
    result = SettingService().get_settings(db_session)

    assert set(result.raw) == RUNTIME_SETTING_KEYS
    assert {item.key for group in result.groups for item in group.settings} == (
        RUNTIME_SETTING_KEYS
    )
    assert "password_policy" not in result.raw
    assert "company_logo" not in result.raw


@pytest.mark.usefixtures("client")
def test_runtime_values_are_validated(db_session: Session) -> None:
    service = SettingService()

    with pytest.raises(ValidationException):
        service.update_settings(db_session, {"face_similarity_threshold": "1.2"})
    with pytest.raises(ValidationException):
        service.update_settings(db_session, {"session_timeout": "60"})
    with pytest.raises(ValidationException):
        service.update_settings(db_session, {"opening_hour": "25:00"})
    with pytest.raises(ValidationException):
        service.update_settings(db_session, {"closing_hour": "14:00:30"})

    updated = service.update_settings(
        db_session,
        {
            "face_similarity_threshold": "0.82",
            "qr_validation_enabled": "false",
            "opening_hour": "08:00",
            "closing_hour": "10:00",
        },
    )
    assert updated.raw["face_similarity_threshold"] == "0.82"
    assert updated.raw["qr_validation_enabled"] == "false"
    assert updated.raw["opening_hour"] == "08:00"
    assert updated.raw["closing_hour"] == "10:00"


def test_kiosk_settings_require_tablet_credentials(client: TestClient) -> None:
    assert client.get("/api/v1/settings/kiosk").status_code == 401

    test_settings = settings.model_copy(update={"TABLET_API_KEY": "test-tablet-key"})
    client.app.dependency_overrides[get_settings_dependency] = lambda: test_settings
    try:
        response = client.get(
            "/api/v1/settings/kiosk",
            headers={"X-Tablet-Key": "test-tablet-key"},
        )
    finally:
        client.app.dependency_overrides.pop(get_settings_dependency, None)

    assert response.status_code == 200
    payload = response.json()
    assert payload["success"] is True
    assert set(payload["data"]["raw"]) == RUNTIME_SETTING_KEYS
