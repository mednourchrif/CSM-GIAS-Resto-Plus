"""Tests for Chef Resto (New Rest) role and access permissions."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.role import Role
from app.models.user import User
from scripts.seed import CHEF_EMAIL, CHEF_PASSWORD, seed
from tests.test_auth import _auth_header


def test_seed_creates_chef_role_and_account(client: TestClient, db_session: Session):
    """Seeding creates the CHEF_RESTO role and default chef user."""
    seed(db_session)

    chef_role = db_session.query(Role).filter(Role.nom == "CHEF_RESTO").first()
    assert chef_role is not None
    assert "Chef de restaurant" in chef_role.description

    chef_user = db_session.query(User).filter(User.email == CHEF_EMAIL).first()
    assert chef_user is not None
    assert chef_user.nom == "Chef"
    assert chef_user.prenom == "New Rest"
    assert chef_user.role_id == chef_role.id


def test_chef_login_and_token(client: TestClient, db_session: Session):
    """Chef can log in with default credentials and receives access token."""
    seed(db_session)

    response = client.post(
        "/api/v1/auth/login",
        json={"email": CHEF_EMAIL, "mot_de_passe": CHEF_PASSWORD},
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert "token" in data
    assert data["admin"]["role"] == "CHEF_RESTO"
    assert data["admin"]["email"] == CHEF_EMAIL


def test_chef_can_access_dashboard_and_receipts(
    client: TestClient,
    db_session: Session,
):
    """Chef can access dashboard statistics and receipts."""
    seed(db_session)

    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": CHEF_EMAIL, "mot_de_passe": CHEF_PASSWORD},
    )
    token = login_resp.json()["data"]["token"]["access_token"]
    headers = _auth_header(token)

    # Dashboard access
    dash_resp = client.get("/api/v1/stats/dashboard", headers=headers)
    assert dash_resp.status_code == 200
    assert "overview" in dash_resp.json()["data"]

    # Receipts access
    receipts_resp = client.get("/api/v1/receipts", headers=headers)
    assert receipts_resp.status_code == 200
    assert "data" in receipts_resp.json()


def test_chef_cannot_access_mutating_admin_endpoints(
    client: TestClient,
    db_session: Session,
):
    """Chef is blocked with 403 Forbidden from mutating administration routes."""
    seed(db_session)

    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": CHEF_EMAIL, "mot_de_passe": CHEF_PASSWORD},
    )
    token = login_resp.json()["data"]["token"]["access_token"]
    headers = _auth_header(token)

    # Attempting to create an employee
    emp_resp = client.post(
        "/api/v1/employees",
        headers=headers,
        json={
            "nom": "Test",
            "prenom": "Forbidden",
            "email": "forbidden@test.com",
            "matricule": "FORBID-01",
        },
    )
    assert emp_resp.status_code == 403
    assert "Chef" in emp_resp.json()["message"]

    # Attempting to modify settings
    settings_resp = client.put(
        "/api/v1/settings",
        headers=headers,
        json={"restaurant_nom": "Hacked Resto"},
    )
    assert settings_resp.status_code == 403
    assert "Chef" in settings_resp.json()["message"]
