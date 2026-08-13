"""Regression coverage for high-impact authorization and privacy rules."""

from datetime import UTC, date, datetime, timedelta
from unittest.mock import patch

import pytest
from fastapi import Request
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.config import DevelopmentSettings, ProductionSettings
from app.core.exceptions import ConflictException, UnauthorizedException
from app.models.admin import Admin
from app.models.employee import Employee
from app.models.user import StatutUtilisateur
from app.models.visitor import Visitor
from app.security.dependencies import require_kiosk_access
from app.services.identification_service import IdentificationService
from app.services.meal_service import MealService
from app.services.user_admin_service import UserAdminService
from tests.test_auth import _auth_header, _login_payload, _seed_admin
from tests.test_qr_codes import _seed_intern


def _login(client: TestClient, db: Session) -> str:
    _seed_admin(db)
    response = client.post("/api/v1/auth/login", json=_login_payload())
    return response.json()["data"]["token"]["access_token"]


def test_identification_grant_is_one_use(
    client: TestClient,
    db_session: Session,
) -> None:
    token = _login(client, db_session)
    MealService.seed_categories(db_session)
    category = MealService().get_categories(db_session)[0]
    intern = _seed_intern(
        db_session,
        date_debut_stage=date.today() - timedelta(days=1),
        date_fin_stage=date.today() + timedelta(days=1),
    )
    qr_response = client.post(
        f"/api/v1/qr/generate/intern/{intern.uuid}",
        headers=_auth_header(token),
    )
    raw_qr = qr_response.json()["data"]["qr_token"]
    identity_response = client.post(
        "/api/v1/identification/qr",
        json={"token": raw_qr},
        headers=_auth_header(token),
    )
    assert identity_response.status_code == 200
    assert identity_response.json()["data"]["expires_at"].endswith(("+00:00", "Z"))
    grant = identity_response.json()["data"]["identification_token"]

    payload = {
        "identification_token": grant,
        "categorie_uuid": category.uuid,
    }
    first = client.post(
        "/api/v1/meals/register",
        json=payload,
        headers=_auth_header(token),
    )
    second = client.post(
        "/api/v1/meals/register",
        json=payload,
        headers=_auth_header(token),
    )

    assert first.status_code == 201
    assert second.status_code == 401

    repeated_identification = client.post(
        "/api/v1/identification/qr",
        json={"token": raw_qr},
        headers=_auth_header(token),
    )
    assert repeated_identification.status_code == 409
    assert "déjà été enregistré" in repeated_identification.json()["message"]


def test_expired_identification_grant_is_rejected(
    client: TestClient,
    db_session: Session,
) -> None:
    token = _login(client, db_session)
    MealService.seed_categories(db_session)
    category = MealService().get_categories(db_session)[0]
    intern = _seed_intern(db_session)
    grant, raw_token = IdentificationService().issue(
        db_session,
        user_uuid=intern.uuid,
        identification_type="QR",
    )
    grant.expires_at = datetime.now(UTC) - timedelta(seconds=1)
    db_session.flush()

    response = client.post(
        "/api/v1/meals/register",
        json={
            "identification_token": raw_token,
            "categorie_uuid": category.uuid,
        },
        headers=_auth_header(token),
    )

    assert response.status_code == 401


def test_failed_registration_does_not_burn_identification_grant(
    client: TestClient,
    db_session: Session,
) -> None:
    token = _login(client, db_session)
    MealService.seed_categories(db_session)
    category = MealService().get_categories(db_session)[0]
    intern = _seed_intern(db_session)
    grant, raw_token = IdentificationService().issue(
        db_session,
        user_uuid=intern.uuid,
        identification_type="QR",
    )

    with patch("app.services.meal_service.is_restaurant_open", return_value=False):
        response = client.post(
            "/api/v1/meals/register",
            json={
                "identification_token": raw_token,
                "categorie_uuid": category.uuid,
            },
            headers=_auth_header(token),
        )

    db_session.refresh(grant)
    assert response.status_code == 400
    assert grant.consumed_at is None


def test_qr_grant_can_register_an_active_employee(
    client: TestClient,
    db_session: Session,
) -> None:
    token = _login(client, db_session)
    MealService.seed_categories(db_session)
    category = MealService().get_categories(db_session)[0]
    employee = Employee(
        nom="QR",
        prenom="Autorise",
        email="employee.qr.allowed@example.com",
        type="EMPLOYE",
        statut=StatutUtilisateur.ACTIF,
        matricule="EMP-QR-ALLOWED",
        langue="FR",
    )
    db_session.add(employee)
    db_session.flush()
    grant, raw_token = IdentificationService().issue(
        db_session,
        user_uuid=employee.uuid,
        identification_type="QR",
    )

    response = client.post(
        "/api/v1/meals/register",
        json={
            "identification_token": raw_token,
            "categorie_uuid": category.uuid,
        },
        headers=_auth_header(token),
    )

    db_session.refresh(grant)
    assert response.status_code == 201
    assert response.json()["data"]["receipt"]["matricule"] == employee.matricule
    assert grant.consumed_at is not None


@pytest.mark.parametrize(
    ("start_offset", "end_offset"),
    [(-10, -1), (1, 10)],
)
def test_intern_outside_stage_cannot_register(
    client: TestClient,
    db_session: Session,
    start_offset: int,
    end_offset: int,
) -> None:
    token = _login(client, db_session)
    MealService.seed_categories(db_session)
    category = MealService().get_categories(db_session)[0]
    intern = _seed_intern(
        db_session,
        date_debut_stage=date.today() + timedelta(days=start_offset),
        date_fin_stage=date.today() + timedelta(days=end_offset),
    )
    grant, raw_token = IdentificationService().issue(
        db_session,
        user_uuid=intern.uuid,
        identification_type="QR",
    )

    response = client.post(
        "/api/v1/meals/register",
        json={
            "identification_token": raw_token,
            "categorie_uuid": category.uuid,
        },
        headers=_auth_header(token),
    )

    db_session.refresh(grant)
    assert response.status_code == 400
    assert grant.consumed_at is None


@pytest.mark.parametrize("deleted", [False, True])
def test_inactive_or_deleted_user_cannot_register(
    client: TestClient,
    db_session: Session,
    deleted: bool,
) -> None:
    token = _login(client, db_session)
    MealService.seed_categories(db_session)
    category = MealService().get_categories(db_session)[0]
    intern = _seed_intern(
        db_session,
        statut=StatutUtilisateur.ACTIF if deleted else StatutUtilisateur.INACTIF,
    )
    if deleted:
        intern.date_suppression = datetime.now(UTC)
    grant, raw_token = IdentificationService().issue(
        db_session,
        user_uuid=intern.uuid,
        identification_type="QR",
    )

    response = client.post(
        "/api/v1/meals/register",
        json={
            "identification_token": raw_token,
            "categorie_uuid": category.uuid,
        },
        headers=_auth_header(token),
    )

    db_session.refresh(grant)
    assert response.status_code in {400, 404}
    assert grant.consumed_at is None


def test_visitor_on_wrong_date_cannot_register(
    client: TestClient,
    db_session: Session,
) -> None:
    token = _login(client, db_session)
    MealService.seed_categories(db_session)
    category = MealService().get_categories(db_session)[0]
    visitor = Visitor(
        nom="Visite",
        prenom="Hors date",
        email="visitor.wrong.date@example.com",
        type="VISITEUR",
        statut=StatutUtilisateur.ACTIF,
        societe="Test",
        date_visite=date.today() + timedelta(days=1),
        langue="FR",
    )
    db_session.add(visitor)
    db_session.flush()
    grant, raw_token = IdentificationService().issue(
        db_session,
        user_uuid=visitor.uuid,
        identification_type="QR",
    )

    response = client.post(
        "/api/v1/meals/register",
        json={
            "identification_token": raw_token,
            "categorie_uuid": category.uuid,
        },
        headers=_auth_header(token),
    )

    db_session.refresh(grant)
    assert response.status_code == 400
    assert grant.consumed_at is None


def test_legacy_direct_uuid_registration_is_rejected(
    client: TestClient,
    db_session: Session,
) -> None:
    token = _login(client, db_session)
    response = client.post(
        "/api/v1/meals/register",
        json={
            "utilisateur_uuid": "forged-user-uuid",
            "categorie_uuid": "category-uuid",
        },
        headers=_auth_header(token),
    )
    assert response.status_code == 422


def test_kiosk_identification_requires_credentials(client: TestClient) -> None:
    response = client.post(
        "/api/v1/identification/qr",
        json={"token": "x" * 32},
    )
    assert response.status_code == 401


def _request_from(host: str) -> Request:
    return Request(
        {
            "type": "http",
            "method": "POST",
            "path": "/api/v1/face/identify",
            "headers": [],
            "client": (host, 12345),
            "server": ("api.example.com", 8000),
            "scheme": "http",
            "query_string": b"",
        }
    )


def test_private_lan_kiosk_is_allowed_only_in_development(db_session: Session) -> None:
    development = DevelopmentSettings(
        _env_file=None,
        APP_ENVIRONMENT="development",
        APP_SECRET_KEY="development-app-secret",
        JWT_SECRET_KEY="development-jwt-secret",
        TABLET_API_KEY="configured-but-not-in-debug-apk",
    )

    assert (
        require_kiosk_access(
            request=_request_from("10.138.217.34"),
            db=db_session,
            tablet_key=None,
            credentials=None,
            settings=development,
        )
        is None
    )

    production = ProductionSettings(
        _env_file=None,
        APP_ENVIRONMENT="production",
        APP_SECRET_KEY="a" * 48,
        JWT_SECRET_KEY="b" * 48,
        CORS_ORIGINS=["https://resto.example.com"],
        TRUSTED_HOSTS=["api.example.com"],
        TABLET_API_KEY="device-key-" + ("c" * 32),
        FACE_ENGINE="disabled",
        TZ="Africa/Tunis",
    )
    with pytest.raises(UnauthorizedException):
        require_kiosk_access(
            request=_request_from("10.138.217.34"),
            db=db_session,
            tablet_key=None,
            credentials=None,
            settings=production,
        )


def test_validation_error_never_echoes_password(client: TestClient) -> None:
    secret = "DoNotEcho-Secret-123!"
    response = client.post(
        "/api/v1/auth/login",
        json={"email": "invalid", "mot_de_passe": secret, "unexpected": secret},
    )
    assert response.status_code == 422
    assert secret not in response.text
    assert all("input" not in error for error in response.json()["details"]["errors"])


def test_repeated_login_failures_are_throttled(client: TestClient) -> None:
    payload = {
        "email": "rate-limit-target@example.com",
        "mot_de_passe": "WrongPass1!",
    }
    responses = [client.post("/api/v1/auth/login", json=payload) for _ in range(6)]
    assert responses[-1].status_code == 429


def test_admin_cannot_disable_own_account(db_session: Session) -> None:
    admin = _seed_admin(db_session)
    service = UserAdminService()

    with pytest.raises(ConflictException):
        service.set_status(
            db_session,
            admin.uuid,
            StatutUtilisateur.INACTIF,
            admin,
        )


def test_last_active_admin_cannot_be_removed(db_session: Session) -> None:
    target = _seed_admin(db_session)
    inactive_actor = Admin(
        nom="Secours",
        prenom="Inactif",
        email="inactive.actor@test.com",
        mot_de_passe=target.mot_de_passe,
        type="ADMINISTRATEUR",
        statut=StatutUtilisateur.INACTIF,
        langue="FR",
    )
    db_session.add(inactive_actor)
    db_session.flush()

    with pytest.raises(ConflictException):
        UserAdminService().delete(
            db_session,
            target.uuid,
            inactive_actor,
        )
