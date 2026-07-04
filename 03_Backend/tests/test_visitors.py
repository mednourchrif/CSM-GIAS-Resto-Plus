"""Comprehensive tests for the Visitor management module.

Covers: CRUD, soft-delete, pagination, search, auth.
"""

from datetime import UTC, datetime, timedelta

import jwt
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.user import StatutUtilisateur
from app.security.password import PasswordService
from tests.test_auth import _auth_header, _login_payload, _seed_admin

_PASSWORD = PasswordService()


def _login(client: TestClient, db_session: Session) -> str:
    _seed_admin(db_session)
    resp = client.post("/api/v1/auth/login", json=_login_payload())
    return resp.json()["data"]["token"]["access_token"]


def _visitor_payload(**overrides: object) -> dict:
    payload = {
        "nom": "Bernard",
        "prenom": "Claire",
        "email": "claire.bernard@example.com",
        "societe": "ACME Corp",
        "date_visite": "2026-07-04",
        "statut": "ACTIF",
    }
    payload.update(overrides)
    return payload


class TestVisitorCRUD:
    """Full CRUD lifecycle for visitors."""

    def test_create_visitor(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.post(
            "/api/v1/visitors",
            json=_visitor_payload(),
            headers=_auth_header(token),
        )
        assert resp.status_code == 201
        body = resp.json()
        assert body["success"] is True
        assert body["data"]["nom"] == "Bernard"
        assert body["data"]["date_visite"] == "2026-07-04"

    def test_get_visitor(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/visitors",
            json=_visitor_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.get(f"/api/v1/visitors/{uuid}", headers=_auth_header(token))
        assert resp.status_code == 200
        assert resp.json()["data"]["uuid"] == uuid

    def test_get_visitor_not_found(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.get("/api/v1/visitors/nonexistent-uuid", headers=_auth_header(token))
        assert resp.status_code == 404

    def test_update_visitor(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/visitors",
            json=_visitor_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.put(
            f"/api/v1/visitors/{uuid}",
            json={
                "nom": "Dubois",
                "prenom": "Marc",
                "societe": "Other Corp",
                "date_visite": "2026-07-05",
            },
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["nom"] == "Dubois"

    def test_patch_visitor(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/visitors",
            json=_visitor_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.patch(
            f"/api/v1/visitors/{uuid}",
            json={"societe": "Updated Corp"},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        assert resp.json()["data"]["societe"] == "Updated Corp"

    def test_delete_visitor_soft_delete(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        create_resp = client.post(
            "/api/v1/visitors",
            json=_visitor_payload(),
            headers=_auth_header(token),
        )
        uuid = create_resp.json()["data"]["uuid"]

        resp = client.delete(f"/api/v1/visitors/{uuid}", headers=_auth_header(token))
        assert resp.status_code == 204

        get_resp = client.get(f"/api/v1/visitors/{uuid}", headers=_auth_header(token))
        assert get_resp.status_code == 404


class TestVisitorValidation:
    """Business rule validation for visitors."""

    def test_duplicate_email(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        client.post("/api/v1/visitors", json=_visitor_payload(), headers=_auth_header(token))
        resp = client.post(
            "/api/v1/visitors",
            json=_visitor_payload(nom="Autre"),
            headers=_auth_header(token),
        )
        assert resp.status_code == 409

    def test_create_without_required_fields(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        resp = client.post("/api/v1/visitors", json={}, headers=_auth_header(token))
        assert resp.status_code == 422


class TestVisitorPagination:
    """Pagination, sorting, and search."""

    def _seed_many(self, client: TestClient, token: str, count: int = 5) -> None:
        for i in range(count):
            client.post(
                "/api/v1/visitors",
                json=_visitor_payload(
                    nom=f"Nom{i+1}",
                    email=f"visitor{i+1}@example.com",
                ),
                headers=_auth_header(token),
            )

    def test_pagination_defaults(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get("/api/v1/visitors", headers=_auth_header(token))
        assert resp.status_code == 200
        assert resp.json()["total"] >= 5

    def test_search_by_name(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        self._seed_many(client, token)
        resp = client.get("/api/v1/visitors?search=Nom1", headers=_auth_header(token))
        assert resp.status_code == 200
        assert len(resp.json()["data"]) >= 1

    def test_search_by_societe(self, client: TestClient, db_session: Session) -> None:
        token = _login(client, db_session)
        client.post(
            "/api/v1/visitors",
            json=_visitor_payload(societe="SpecialCorp"),
            headers=_auth_header(token),
        )
        resp = client.get("/api/v1/visitors?search=SpecialCorp", headers=_auth_header(token))
        assert resp.status_code == 200
        assert len(resp.json()["data"]) >= 1


class TestVisitorAuth:
    """Authentication and authorization for visitor endpoints."""

    def test_without_token_returns_401(self, client: TestClient) -> None:
        resp = client.get("/api/v1/visitors")
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

        resp = client.get("/api/v1/visitors", headers=_auth_header(token))
        assert resp.status_code == 401
