"""Tests for kiosk offline manifest and batch synchronization endpoints."""

from datetime import UTC, datetime, timedelta
import uuid

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.employee import Employee
from app.models.qr_code import QrCode
from app.services.qr_code_service import QrCodeService
from tests.test_auth import _auth_header, _login_payload, _seed_admin
from tests.test_meals import _login, _seed_categories, _seed_employee


def _get_token(client: TestClient) -> str:
    resp = client.post("/api/v1/auth/login", json=_login_payload())
    return resp.json()["data"]["token"]["access_token"]


@pytest.fixture
def active_employee_with_qr(db_session: Session) -> tuple[Employee, QrCode, str]:
    """Create an active employee and active QR code."""
    admin = _seed_admin(db_session)
    emp = _seed_employee(db_session, matricule=f"OFF-{uuid.uuid4().hex[:4].upper()}")

    qr_service = QrCodeService()
    qr = qr_service.generate_for_employee(db_session, emp.uuid, admin)
    raw_token = qr.raw_token
    db_session.flush()

    return emp, qr, raw_token


def test_offline_manifest_returns_categories_and_users(
    client: TestClient,
    db_session: Session,
    active_employee_with_qr: tuple[Employee, QrCode, str],
):
    """Manifest returns current categories and active user QR hashes."""
    emp, qr, raw_token = active_employee_with_qr
    _seed_categories(db_session)
    token = _get_token(client)

    response = client.get(
        "/api/v1/meals/offline-manifest",
        headers=_auth_header(token),
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert "categories" in data
    assert len(data["categories"]) > 0
    assert "users" in data

    user_matches = [u for u in data["users"] if u["user_uuid"] == emp.uuid]
    assert len(user_matches) == 1
    assert user_matches[0]["qr_hash"] == qr.qr_hash
    assert user_matches[0]["nom"] == emp.nom
    assert user_matches[0]["prenom"] == emp.prenom
    assert user_matches[0]["matricule"] == emp.matricule


def test_sync_offline_meals_success(
    client: TestClient,
    db_session: Session,
    active_employee_with_qr: tuple[Employee, QrCode, str],
):
    """Kiosk can synchronize an offline recorded meal with historic timestamp."""
    emp, qr, raw_token = active_employee_with_qr
    cats = _seed_categories(db_session)
    token = _get_token(client)

    registered_time = datetime.now(UTC) - timedelta(hours=1)
    offline_id = str(uuid.uuid4())

    payload = {
        "items": [
            {
                "offline_id": offline_id,
                "qr_token": raw_token,
                "categorie_uuid": cats["Plat"],
                "registered_at": registered_time.isoformat(),
                "identification_type": "QR",
            }
        ]
    }

    response = client.post(
        "/api/v1/meals/sync-offline",
        headers=_auth_header(token),
        json=payload,
    )
    assert response.status_code == 200
    res_data = response.json()["data"]
    assert res_data["synced_count"] == 1
    assert res_data["failed_count"] == 0
    assert len(res_data["results"]) == 1

    item_res = res_data["results"][0]
    assert item_res["offline_id"] == offline_id
    assert item_res["statut"] == "SYNCED"
    assert item_res["meal_uuid"] is not None
    assert item_res["receipt_number"] is not None


def test_sync_offline_meals_idempotency_already_registered(
    client: TestClient,
    db_session: Session,
    active_employee_with_qr: tuple[Employee, QrCode, str],
):
    """Re-syncing the same offline meal returns ALREADY_REGISTERED and succeeds gracefully."""
    emp, qr, raw_token = active_employee_with_qr
    cats = _seed_categories(db_session)
    token = _get_token(client)

    registered_time = datetime.now(UTC) - timedelta(minutes=30)
    offline_id = str(uuid.uuid4())

    payload = {
        "items": [
            {
                "offline_id": offline_id,
                "qr_token": raw_token,
                "categorie_uuid": cats["Pizza"],
                "registered_at": registered_time.isoformat(),
                "identification_type": "QR",
            }
        ]
    }

    # First sync
    res1 = client.post(
        "/api/v1/meals/sync-offline",
        headers=_auth_header(token),
        json=payload,
    )
    assert res1.status_code == 200
    assert res1.json()["data"]["results"][0]["statut"] == "SYNCED"

    # Second sync of the same item
    res2 = client.post(
        "/api/v1/meals/sync-offline",
        headers=_auth_header(token),
        json=payload,
    )
    assert res2.status_code == 200
    res2_data = res2.json()["data"]
    assert res2_data["synced_count"] == 1
    assert res2_data["failed_count"] == 0
    assert res2_data["results"][0]["statut"] == "ALREADY_REGISTERED"


def test_sync_offline_meals_invalid_qr(
    client: TestClient,
    db_session: Session,
):
    """Unknown or invalid QR code reports ERROR in sync result."""
    cats = _seed_categories(db_session)
    token = _login(client, db_session)

    payload = {
        "items": [
            {
                "offline_id": str(uuid.uuid4()),
                "qr_token": "a" * 64,  # Invalid/non-existent token
                "categorie_uuid": cats["Sandwich"],
                "registered_at": datetime.now(UTC).isoformat(),
                "identification_type": "QR",
            }
        ]
    }

    response = client.post(
        "/api/v1/meals/sync-offline",
        headers=_auth_header(token),
        json=payload,
    )
    assert response.status_code == 200
    res_data = response.json()["data"]
    assert res_data["synced_count"] == 0
    assert res_data["failed_count"] == 1
    assert res_data["results"][0]["statut"] == "ERROR"
    assert "QR code" in res_data["results"][0]["message"]

