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
    assert result.raw["language"] == "fr"


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
    with pytest.raises(ValidationException):
        service.update_settings(db_session, {"language": "de"})

    updated = service.update_settings(
        db_session,
        {
            "face_similarity_threshold": "0.82",
            "qr_validation_enabled": "false",
            "opening_hour": "08:00",
            "closing_hour": "10:00",
            "language": "ar",
        },
    )
    assert updated.raw["face_similarity_threshold"] == "0.82"
    assert updated.raw["qr_validation_enabled"] == "false"
    assert updated.raw["opening_hour"] == "08:00"
    assert updated.raw["closing_hour"] == "10:00"
    assert updated.raw["language"] == "ar"


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
    assert payload["data"]["raw"]["language"] == "fr"


def _create_admin_and_login(client: TestClient, db: Session) -> tuple[dict[str, str], str]:
    from app.models.admin import Admin
    from app.models.role import Role
    from app.models.user import StatutUtilisateur
    from app.utils.password import hash_password

    role = db.query(Role).filter_by(nom="ADMIN").first()
    if not role:
        role = Role(nom="ADMIN", description="Admin test")
        db.add(role)
        db.flush()

    pwd = "AdminTest@123"
    admin = db.query(Admin).filter_by(email="admintest@csm.tn").first()
    if not admin:
        admin = Admin(
            nom="Admin",
            prenom="Test",
            email="admintest@csm.tn",
            mot_de_passe=hash_password(pwd),
            type="ADMINISTRATEUR",
            statut=StatutUtilisateur.ACTIF,
            role_id=role.id,
            langue="FR",
        )
        db.add(admin)
        db.commit()

    res = client.post(
        "/api/v1/auth/login",
        json={"email": "admintest@csm.tn", "mot_de_passe": pwd},
    )
    token = res.json()["data"]["token"]["access_token"]
    return {"Authorization": f"Bearer {token}"}, pwd


def test_purge_requires_admin_auth(client: TestClient) -> None:
    res = client.post(
        "/api/v1/settings/purge",
        json={"mot_de_passe": "Admin@123", "confirmation": "PURGER"},
    )
    assert res.status_code == 401


def test_purge_validates_confirmation_and_password(
    client: TestClient, db_session: Session
) -> None:
    headers, pwd = _create_admin_and_login(client, db_session)

    # Wrong confirmation text
    res = client.post(
        "/api/v1/settings/purge",
        headers=headers,
        json={"mot_de_passe": pwd, "confirmation": "WRONG"},
    )
    assert res.status_code in (400, 422)

    # Wrong password
    res = client.post(
        "/api/v1/settings/purge",
        headers=headers,
        json={"mot_de_passe": "WrongPassword!", "confirmation": "PURGER"},
    )
    assert res.status_code in (400, 422)


def test_purge_database_success(
    client: TestClient,
    db_session: Session,
) -> None:
    from app.models.employee import Employee
    from app.models.identification_grant import IdentificationGrant
    from app.models.meal import Meal
    from app.models.receipt import Receipt
    from app.models.user import User

    headers, pwd = _create_admin_and_login(client, db_session)

    users_before = db_session.query(User).count()
    employees_before = db_session.query(Employee).count()

    res = client.post(
        "/api/v1/settings/purge",
        headers=headers,
        json={
            "mot_de_passe": pwd,
            "confirmation": "PURGER",
            "purger_audit_logs": False,
        },
    )
    assert res.status_code == 200
    data = res.json()["data"]
    assert "repas_supprimes" in data
    assert "recus_supprimes" in data
    assert "grants_supprimes" in data

    # Transactional tables must be empty
    assert db_session.query(Receipt).count() == 0
    assert db_session.query(Meal).count() == 0
    assert db_session.query(IdentificationGrant).count() == 0

    # Master data must be preserved
    assert db_session.query(User).count() >= users_before
    assert db_session.query(Employee).count() == employees_before
