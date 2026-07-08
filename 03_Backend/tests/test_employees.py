"""Comprehensive tests for the Employee management module.

Covers: CRUD, soft-delete, pagination, search, duplicate checks, auth.
"""

from datetime import UTC, datetime, timedelta

import jwt
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.admin import Admin
from app.models.employee import Employee
from app.models.role import Role
from app.models.user import StatutUtilisateur
from app.security.password import PasswordService
from tests.test_auth import _auth_header, _login_payload, _seed_admin

_PASSWORD = PasswordService()


def _login(client: TestClient, db_session: Session) -> str:
    """Authenticate as the seeded admin and return a valid JWT token."""
    _seed_admin(db_session)
    resp = client.post("/api/v1/auth/login", json=_login_payload())
    return resp.json()["data"]["token"]["access_token"]


def _employee_payload(**overrides: object) -> dict:
    payload = {
        "nom": "Dupont",
        "prenom": "Jean",
        "email": "jean.dupont@example.com",
        "matricule": "EMP001",
        "statut": "ACTIF",
    }
    payload.update(overrides)
    return payload


class TestEmployeeCRUD:
    """Full CRUD lifecycle for employees."""

    def test_create_employee(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.post(
            "/api/v1/employees",
            json=_employee_payload(),
            headers=_auth_header(token),
        )
        assert resp.status_code == 201
        body = resp.json()
        assert body["success"] is True
        assert body["data"]["nom"] == "Dupont"
        assert body["data"]["matricule"] == "EMP001"
        assert body["data"]["uuid"] is not None

    def test_get_employee(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/employees",
            json=_employee_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.get(f"/api/v1/employees/{uuid}", headers=_auth_header(token))
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["uuid"] == uuid
        assert data["face_enrolled"] is False
        assert data["qr_generated"] is False
        assert data["today_meal"] is None
        assert data["last_meals"] == []

    def test_get_employee_not_found(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.get("/api/v1/employees/nonexistent-uuid", headers=_auth_header(token))
        assert resp.status_code == 404

    def test_update_employee(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/employees",
            json=_employee_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.put(
            f"/api/v1/employees/{uuid}",
            json={"nom": "Martin", "prenom": "Pierre", "matricule": "EMP002"},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["nom"] == "Martin"

    def test_patch_employee(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/employees",
            json=_employee_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.patch(
            f"/api/v1/employees/{uuid}",
            json={"prenom": "Updated"},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["prenom"] == "Updated"

    def test_delete_employee_soft_delete(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/employees",
            json=_employee_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.delete(f"/api/v1/employees/{uuid}", headers=_auth_header(token))
        assert resp.status_code == 204

        get_resp = client.get(f"/api/v1/employees/{uuid}", headers=_auth_header(token))
        assert get_resp.status_code == 404


class TestEmployeeValidation:
    """Business rule validation for employees."""

    def test_duplicate_matricule(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        client.post(
            "/api/v1/employees",
            json=_employee_payload(),
            headers=_auth_header(token),
        )
        resp = client.post(
            "/api/v1/employees",
            json=_employee_payload(),
            headers=_auth_header(token),
        )
        assert resp.status_code == 409

    def test_duplicate_email(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        client.post(
            "/api/v1/employees",
            json=_employee_payload(),
            headers=_auth_header(token),
        )
        resp = client.post(
            "/api/v1/employees",
            json=_employee_payload(email="jean.dupont@example.com", matricule="EMP002"),
            headers=_auth_header(token),
        )
        assert resp.status_code == 409

    def test_create_without_required_fields(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.post(
            "/api/v1/employees",
            json={},
            headers=_auth_header(token),
        )
        assert resp.status_code == 422


class TestEmployeePagination:
    """Pagination, sorting, and search."""

    def _seed_many(self, client: TestClient, token: str, count: int = 5) -> None:
        for i in range(count):
            client.post(
                "/api/v1/employees",
                json=_employee_payload(
                    matricule=f"EMP{i+1:03d}",
                    nom=f"Nom{i+1}",
                    email=f"emp{i+1}@example.com",
                ),
                headers=_auth_header(token),
            )

    def test_pagination_defaults(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get("/api/v1/employees", headers=_auth_header(token))
        assert resp.status_code == 200
        body = resp.json()
        assert body["page"] == 1
        assert body["page_size"] == 20
        assert body["total"] >= 5

    def test_pagination_page_size(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get("/api/v1/employees?page=1&page_size=2", headers=_auth_header(token))
        assert resp.status_code == 200
        assert len(resp.json()["data"]) == 2

    def test_search_by_matricule(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get(
            "/api/v1/employees?search=EMP001",
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert len(resp.json()["data"]) >= 1

    def test_search_by_name(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get(
            "/api/v1/employees?search=Nom1",
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert len(resp.json()["data"]) >= 1

    def test_sort_by_nom(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get(
            "/api/v1/employees?sort=nom&order=asc",
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data[0]["nom"] <= data[-1]["nom"]


class TestEmployeeAuth:
    """Authentication and authorization for employee endpoints."""

    def test_without_token_returns_401(self, client: TestClient) -> None:
        resp = client.get("/api/v1/employees")
        assert resp.status_code == 401

    def test_with_invalid_token_returns_401(self, client: TestClient) -> None:
        resp = client.get(
            "/api/v1/employees",
            headers=_auth_header("invalid-token"),
        )
        assert resp.status_code == 401

    def test_receptionist_cannot_access(self, client: TestClient, db_session: Session) -> None:
        from app.models.admin import Receptionist

        reception = Receptionist(
            nom="Recept",
            prenom="Test",
            email="recept@test.com",
            mot_de_passe=_PASSWORD.hash("StrongPass1!"),
            type="RECEPTION",
            statut=StatutUtilisateur.ACTIF,
        )
        db_session.add(reception)
        db_session.flush()

        now = datetime.now(UTC)
        token = jwt.encode(
            {
                "sub": str(reception.id),
                "uuid": reception.uuid,
                "role": None,
                "type": "RECEPTION",
                "iat": now,
                "exp": now + timedelta(minutes=30),
            },
            settings.JWT_SECRET_KEY,
            algorithm=settings.JWT_ALGORITHM,
        )

        resp = client.get("/api/v1/employees", headers=_auth_header(token))
        assert resp.status_code == 401
