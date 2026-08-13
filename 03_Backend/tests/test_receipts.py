"""Meal receipt persistence, filtering, and print-audit tests."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from tests.test_auth import _auth_header
from tests.test_meals import _login, _register_meal, _seed_categories
from tests.test_qr_codes import _seed_intern


def _create_receipt(client: TestClient, db: Session) -> tuple[str, str]:
    token = _login(client, db)
    categories = _seed_categories(db)
    intern = _seed_intern(db, matricule="INT-RECEIPT")
    generated = client.post(
        f"/api/v1/qr/generate/intern/{intern.uuid}", headers=_auth_header(token)
    )
    response = _register_meal(
        client,
        token,
        generated.json()["data"]["qr_token"],
        categories["Plat"],
    )
    assert response.status_code == 201
    return token, response.json()["data"]["receipt"]["uuid"]


def test_receipt_is_persisted_and_filterable(client: TestClient, db_session: Session) -> None:
    token, receipt_uuid = _create_receipt(client, db_session)

    response = client.get(
        "/api/v1/receipts",
        params={"search": "INT-RECEIPT", "category": "Plat", "user_type": "STAGIAIRE"},
        headers=_auth_header(token),
    )

    assert response.status_code == 200
    assert response.json()["total"] == 1
    receipt = response.json()["data"][0]
    assert receipt["uuid"] == receipt_uuid
    assert receipt["matricule"] == "INT-RECEIPT"
    assert receipt["categorie_nom"] == "Plat"

    scanned = client.post(
        "/api/v1/receipts/scan",
        json={"token": receipt["qr_token"]},
        headers=_auth_header(token),
    )
    assert scanned.status_code == 200
    assert scanned.json()["data"]["uuid"] == receipt_uuid


def test_printing_receipt_updates_audit_count(client: TestClient, db_session: Session) -> None:
    token, receipt_uuid = _create_receipt(client, db_session)

    response = client.post(
        f"/api/v1/receipts/{receipt_uuid}/printed",
        headers=_auth_header(token),
    )

    assert response.status_code == 200
    assert response.json()["data"]["nombre_impressions"] == 1
    assert response.json()["data"]["derniere_impression"] is not None
