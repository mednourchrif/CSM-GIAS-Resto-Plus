"""Comprehensive tests for the authentication and authorisation module.

Covers: successful login, wrong password, unknown email, disabled
account, expired token, invalid token, protected endpoint access,
role-based authorisation, and token decoding.
"""

from datetime import UTC, datetime, timedelta

import jwt
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.admin import Admin
from app.models.role import Role
from app.models.user import StatutUtilisateur
from app.security.password import PasswordService

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_PASSWORD = PasswordService()


def _seed_admin(db: Session, **overrides: object) -> Admin:
    """Create a fully-populated admin in the test database."""
    role = Role(nom="super-admin", description="Test role", actif=True)
    db.add(role)
    db.flush()

    admin = Admin(
        nom=overrides.get("nom", "Admin"),
        prenom=overrides.get("prenom", "Test"),
        email=overrides.get("email", "admin@test.com"),
        mot_de_passe=overrides.get("mot_de_passe", _PASSWORD.hash("StrongPass1!")),
        type="ADMINISTRATEUR",
        statut=overrides.get("statut", StatutUtilisateur.ACTIF),
        role_id=role.id,
        langue="FR",
    )
    db.add(admin)
    db.flush()
    return admin


def _login_payload(email: str = "admin@test.com", password: str = "StrongPass1!") -> dict:
    return {"email": email, "mot_de_passe": password}


def _auth_header(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------


class TestLogin:
    """POST /api/v1/auth/login"""

    def test_successful_login(self, client: TestClient, db_session: Session) -> None:
        """Authenticate with valid credentials returns token + admin summary."""
        _seed_admin(db_session)

        resp = client.post("/api/v1/auth/login", json=_login_payload())
        assert resp.status_code == 200

        body = resp.json()
        assert body["success"] is True

        data = body["data"]
        token = data["token"]
        assert token["access_token"]
        assert token["token_type"] == "bearer"
        assert token["expires_in"] > 0

        admin = data["admin"]
        assert admin["nom"] == "Admin"
        assert admin["prenom"] == "Test"
        assert admin["email"] == "admin@test.com"
        assert admin["role"] == "super-admin"

    def test_wrong_password(self, client: TestClient, db_session: Session) -> None:
        """Login with wrong password returns 401."""
        _seed_admin(db_session)

        resp = client.post(
            "/api/v1/auth/login",
            json=_login_payload(password="WrongPass1!"),
        )
        assert resp.status_code == 401
        body = resp.json()
        assert body["success"] is False
        assert body["error_code"] == "UNAUTHORIZED"

    def test_unknown_email(self, client: TestClient, db_session: Session) -> None:
        """Login with unregistered email returns 401."""
        _seed_admin(db_session)

        resp = client.post(
            "/api/v1/auth/login",
            json=_login_payload(email="unknown@test.com"),
        )
        assert resp.status_code == 401
        body = resp.json()
        assert body["success"] is False
        assert body["error_code"] == "UNAUTHORIZED"

    def test_disabled_account(self, client: TestClient, db_session: Session) -> None:
        """Login with an INACTIF account returns 401."""
        _seed_admin(db_session, statut=StatutUtilisateur.INACTIF)

        resp = client.post("/api/v1/auth/login", json=_login_payload())
        assert resp.status_code == 401
        body = resp.json()
        assert body["success"] is False
        assert body["error_code"] == "UNAUTHORIZED"

    def test_deleted_account(self, client: TestClient, db_session: Session) -> None:
        """Login with a soft-deleted account returns 401."""
        admin = _seed_admin(db_session)
        admin.date_suppression = datetime.now(UTC)

        resp = client.post("/api/v1/auth/login", json=_login_payload())
        assert resp.status_code == 401

    def test_employee_cannot_login(self, client: TestClient, db_session: Session) -> None:
        """A user with type EMPLOYE cannot authenticate."""
        from app.models.employee import Employee  # noqa: PLC0415

        emp = Employee(
            nom="Emp",
            prenom="Test",
            email="emp@test.com",
            mot_de_passe=_PASSWORD.hash("StrongPass1!"),
            type="EMPLOYE",
            matricule="EMP001",
            statut=StatutUtilisateur.ACTIF,
        )
        db_session.add(emp)

        resp = client.post("/api/v1/auth/login", json=_login_payload(email="emp@test.com"))
        assert resp.status_code == 401

    def test_login_updates_derniere_connexion(
        self, client: TestClient, db_session: Session
    ) -> None:
        """After login, the admin's derniere_connexion is set."""
        _seed_admin(db_session)

        client.post("/api/v1/auth/login", json=_login_payload())

        admin = db_session.query(Admin).first()
        assert admin is not None
        assert admin.derniere_connexion is not None
        assert admin.tentatives_echouees == 0


class TestMe:
    """GET /api/v1/auth/me"""

    def test_me_returns_admin(self, client: TestClient, db_session: Session) -> None:
        """Authenticated request to /me returns admin info."""
        _seed_admin(db_session)

        login_resp = client.post("/api/v1/auth/login", json=_login_payload())
        token = login_resp.json()["data"]["token"]["access_token"]

        resp = client.get("/api/v1/auth/me", headers=_auth_header(token))
        assert resp.status_code == 200

        body = resp.json()
        assert body["success"] is True
        data = body["data"]
        assert data["nom"] == "Admin"
        assert data["prenom"] == "Test"
        assert data["email"] == "admin@test.com"
        assert data["role"] == "super-admin"

    def test_me_without_token(self, client: TestClient) -> None:
        """Request without Authorization header returns 403 (HTTPBearer requires auth)."""
        resp = client.get("/api/v1/auth/me")
        assert resp.status_code == 401

    def test_me_with_invalid_token(self, client: TestClient) -> None:
        """Request with garbage token returns 401."""
        resp = client.get(
            "/api/v1/auth/me",
            headers=_auth_header("this.is.not.a.valid.jwt"),
        )
        assert resp.status_code == 401

    def test_me_with_expired_token(self, client: TestClient, db_session: Session) -> None:
        """Request with an expired token returns 401."""
        _seed_admin(db_session)

        expired_payload = {
            "sub": "1",
            "uuid": "test-uuid",
            "role": "super-admin",
            "type": "ADMINISTRATEUR",
            "iat": datetime.now(UTC) - timedelta(hours=2),
            "exp": datetime.now(UTC) - timedelta(hours=1),
        }
        token = jwt.encode(
            expired_payload,
            settings.JWT_SECRET_KEY,
            algorithm=settings.JWT_ALGORITHM,
        )

        resp = client.get("/api/v1/auth/me", headers=_auth_header(token))
        assert resp.status_code == 401

    def test_me_with_disabled_account(self, client: TestClient, db_session: Session) -> None:
        """A valid token for a disabled account returns 401 on /me."""
        admin = _seed_admin(db_session)

        login_resp = client.post("/api/v1/auth/login", json=_login_payload())
        token = login_resp.json()["data"]["token"]["access_token"]

        admin.statut = StatutUtilisateur.INACTIF

        resp = client.get("/api/v1/auth/me", headers=_auth_header(token))
        assert resp.status_code == 401

    def test_me_with_deleted_account(self, client: TestClient, db_session: Session) -> None:
        """A valid token for a soft-deleted account returns 401."""
        admin = _seed_admin(db_session)

        login_resp = client.post("/api/v1/auth/login", json=_login_payload())
        token = login_resp.json()["data"]["token"]["access_token"]

        admin.date_suppression = datetime.now(UTC)

        resp = client.get("/api/v1/auth/me", headers=_auth_header(token))
        assert resp.status_code == 401


class TestTokenDecoding:
    """Verify JWT token contents."""

    def test_token_contains_expected_claims(self, client: TestClient, db_session: Session) -> None:
        """The JWT token includes sub, uuid, role, type, iat, exp."""
        _seed_admin(db_session)

        resp = client.post("/api/v1/auth/login", json=_login_payload())
        token = resp.json()["data"]["token"]["access_token"]

        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
            options={"require": ["sub", "uuid", "role", "type", "iat", "exp"]},
        )
        assert payload["sub"] is not None
        assert payload["uuid"] is not None
        assert payload["role"] == "super-admin"
        assert payload["type"] == "ADMINISTRATEUR"
        assert "iat" in payload
        assert "exp" in payload


class TestAuthorization:
    """Role-based access control dependencies."""

    def test_admin_with_role_can_access(self, client: TestClient, db_session: Session) -> None:
        """Admin with the 'super-admin' role can access a role-protected endpoint."""
        _seed_admin(db_session)

        login_resp = client.post("/api/v1/auth/login", json=_login_payload())
        token = login_resp.json()["data"]["token"]["access_token"]

        resp = client.get("/api/v1/auth/me", headers=_auth_header(token))
        assert resp.status_code == 200

    def test_receptionist_cannot_access_admin_endpoint(
        self, client: TestClient, db_session: Session
    ) -> None:
        """A receptionist cannot access an admin endpoint."""
        from app.models.admin import Receptionist  # noqa: PLC0415

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

        # The /me endpoint uses get_current_admin which already filters
        # by Admin type, so a Receptionist should be rejected.
        resp = client.get("/api/v1/auth/me", headers=_auth_header(token))
        assert resp.status_code == 401
