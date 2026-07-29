"""Tests for the Face Recognition module.

Covers: enrollment, verification, identification, soft-delete,
image validation, and API auth gates.

The :class:`StubFaceRecognitionEngine` is used directly in service
tests so that real embeddings flow through the serialisation /
deserialisation pipeline.  For API-level tests the engine is mocked
to return predictable values.
"""

import base64
from io import BytesIO
from unittest.mock import patch

import numpy as np
import pytest
from fastapi.testclient import TestClient
from PIL import Image, ImageDraw, ImageEnhance
from sqlalchemy.orm import Session

from app.ai.engine import FaceDetection, StubFaceRecognitionEngine
from app.models.employee import Employee
from app.models.face_embedding import FaceEmbedding
from app.models.meal import Meal
from app.repositories.face_repository import FaceEmbeddingRepository
from app.schemas.employee import EmployeeCreate
from app.schemas.face import FaceStatut
from app.services.employee_service import EmployeeService
from app.services.face_service import FaceService
from app.services.meal_service import MealService
from app.utils.image import decode_base64_image
from tests.test_auth import _auth_header, _login_payload, _seed_admin

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_PASSWORD = "Test1234!"


def _valid_image_base64(color: str = "blue") -> str:
    """Generate a valid 200×200 RGB image as a base64 data URI."""
    img = Image.new("RGB", (200, 200), color=color)
    buf = BytesIO()
    img.save(buf, format="PNG")
    b64 = base64.b64encode(buf.getvalue()).decode()
    return f"data:image/png;base64,{b64}"


def _login(client: TestClient, db_session: Session) -> str:
    _seed_admin(db_session)
    resp = client.post("/api/v1/auth/login", json=_login_payload())
    return resp.json()["data"]["token"]["access_token"]


def _create_employee(db_session: Session) -> Employee:
    """Create an employee via the service layer (bypasses API auth)."""

    admin = _seed_admin(db_session)

    service = EmployeeService()
    employee = service.create(
        db=db_session,
        data=EmployeeCreate(
            nom="Test",
            prenom="User",
            email="test.employee@example.com",
            matricule=f"FAC{np.random.randint(1000, 9999)}",
            statut="ACTIF",
        ),
        admin=admin,
    )
    db_session.flush()
    return employee


# ---------------------------------------------------------------------------
# Image utility tests
# ---------------------------------------------------------------------------


class TestDecodeBase64Image:
    def test_valid_png(self):
        img = _valid_image_base64()
        result = decode_base64_image(img)
        assert result.size == (200, 200)
        assert result.mode == "RGB"

    def test_invalid_format(self):
        from app.core.exceptions import ValidationException

        with pytest.raises(ValidationException):
            decode_base64_image("not-a-data-uri")

    def test_empty_string(self):
        from app.core.exceptions import ValidationException

        with pytest.raises(ValidationException):
            decode_base64_image("")


# ---------------------------------------------------------------------------
# Service tests — FaceService (with real stub engine)
# ---------------------------------------------------------------------------


@pytest.mark.usefixtures("app")
class TestFaceService:
    def test_development_embedding_tolerates_brightness_change(self):
        image = Image.new("RGB", (240, 240), color=(80, 110, 140))
        draw = ImageDraw.Draw(image)
        draw.ellipse((55, 30, 185, 205), fill=(190, 150, 120))
        draw.ellipse((85, 85, 103, 103), fill=(30, 30, 30))
        draw.ellipse((137, 85, 155, 103), fill=(30, 30, 30))
        draw.arc((90, 120, 150, 170), 10, 170, fill=(50, 20, 20), width=5)
        brighter = ImageEnhance.Brightness(image).enhance(1.15)
        engine = StubFaceRecognitionEngine(seed=42)

        confidence = engine.compare(
            engine.extract_embedding(image),
            engine.extract_embedding(brighter),
        )

        assert confidence >= 0.9

    """Test face service business logic with the stub engine."""

    def test_enroll_success(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))

        embedding, meal_registered = service.enroll(
            db=db_session,
            image_base64=_valid_image_base64(),
            user_uuid=employee.uuid,
        )

        assert embedding is not None
        assert embedding.active is True
        assert embedding.utilisateur_uuid == employee.uuid
        assert meal_registered is False

        repo = FaceEmbeddingRepository()
        stored = repo.get_active_by_user(db_session, employee.uuid)
        assert stored is not None
        assert stored.uuid == embedding.uuid
        assert stored.embedding.startswith(b"fernet:v1:")

    def test_enroll_deactivates_previous(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))

        service.enroll(db=db_session, image_base64=_valid_image_base64(), user_uuid=employee.uuid)
        service.enroll(db=db_session, image_base64=_valid_image_base64(), user_uuid=employee.uuid)

        repo = FaceEmbeddingRepository()
        all_embs = (
            db_session.query(FaceEmbedding)
            .filter(
                FaceEmbedding.utilisateur_uuid == employee.uuid,
            )
            .all()
        )
        assert len(all_embs) == 2
        active = [e for e in all_embs if e.active]
        assert len(active) == 1

    def test_verify_match(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))
        service.enroll(db=db_session, image_base64=_valid_image_base64(), user_uuid=employee.uuid)

        statut, confidence, uuid, nom, prenom, message = service.verify(
            db=db_session,
            image_base64=_valid_image_base64(),
            user_uuid=employee.uuid,
        )

        assert statut == FaceStatut.MATCH
        assert confidence is not None and confidence >= 0.5
        assert uuid == employee.uuid

    def test_verify_no_embedding(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))

        statut, confidence, uuid, nom, prenom, message = service.verify(
            db=db_session,
            image_base64=_valid_image_base64(),
            user_uuid=employee.uuid,
        )

        assert statut == FaceStatut.NO_MATCH
        assert confidence is None

    def test_identify_no_embeddings(self, db_session: Session):
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))

        statut, confidence, uuid, nom, prenom, user_type, message = service.identify(
            db=db_session,
            image_base64=_valid_image_base64(),
        )

        assert statut == FaceStatut.NO_MATCH

    def test_identify_success(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))
        service.enroll(db=db_session, image_base64=_valid_image_base64(), user_uuid=employee.uuid)

        statut, confidence, uuid, nom, prenom, user_type, message = service.identify(
            db=db_session,
            image_base64=_valid_image_base64(),
        )

        assert statut == FaceStatut.MATCH
        assert uuid == employee.uuid
        assert confidence is not None and confidence >= 0.5

    def test_development_stub_does_not_match_a_different_image(
        self,
        db_session: Session,
    ):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))
        service.enroll(
            db=db_session,
            image_base64=_valid_image_base64("blue"),
            user_uuid=employee.uuid,
        )

        result = service.identify(
            db=db_session,
            image_base64=_valid_image_base64("red"),
        )

        assert result[0] == FaceStatut.NO_MATCH

    def test_malformed_legacy_template_fails_safely(self, db_session: Session):
        from app.core.exceptions import ConfigurationException

        employee = _create_employee(db_session)
        FaceEmbeddingRepository().create(
            db_session,
            utilisateur_uuid=employee.uuid,
            embedding=b"malformed-legacy-template",
            model_name="legacy",
            model_version="0",
            active=True,
        )

        with pytest.raises(ConfigurationException):
            FaceService(engine=StubFaceRecognitionEngine(seed=42)).verify(
                db=db_session,
                image_base64=_valid_image_base64(),
                user_uuid=employee.uuid,
            )

    def test_delete_embedding(self, db_session: Session):
        employee = _create_employee(db_session)
        service = FaceService(engine=StubFaceRecognitionEngine(seed=42))
        embedding, _ = service.enroll(
            db=db_session,
            image_base64=_valid_image_base64(),
            user_uuid=employee.uuid,
        )

        service.delete_embedding(db_session, embedding.uuid)

        repo = FaceEmbeddingRepository()
        stored = repo.get_by_uuid(db_session, embedding.uuid)
        assert stored is None

    def test_get_by_uuid_not_found(self, db_session: Session):
        service = FaceService()
        from app.core.exceptions import NotFoundException

        with pytest.raises(NotFoundException):
            service.get_by_uuid(db_session, "nonexistent-uuid")


# ---------------------------------------------------------------------------
# API tests — via TestClient
# ---------------------------------------------------------------------------


def _create_employee_via_api(client: TestClient, token: str) -> str:
    """Create an employee via the API and return its UUID."""
    resp = client.post(
        "/api/v1/employees",
        json={
            "nom": "Face",
            "prenom": "Test",
            "email": f"face.test.{np.random.randint(10000)}@example.com",
            "matricule": f"FCE{np.random.randint(1000, 9999)}",
            "statut": "ACTIF",
        },
        headers=_auth_header(token),
    )
    assert resp.status_code == 201
    return resp.json()["data"]["uuid"]


class TestFaceAPI:
    """Test face endpoints through the FastAPI TestClient."""

    _MOCK_EMBEDDING = np.random.default_rng(42).random(512).astype(np.float32)

    @pytest.fixture(autouse=True)
    def _patch_engine(self):
        with (
            patch(
                "app.services.face_service.StubFaceRecognitionEngine.extract_embedding",
                return_value=self._MOCK_EMBEDDING,
            ),
            patch(
                "app.services.face_service.StubFaceRecognitionEngine.detect_face",
                return_value=FaceDetection(bbox=(10, 10, 100, 100), confidence=0.95),
            ),
        ):
            yield

    def test_enroll_requires_auth(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
        )
        assert resp.status_code == 401

    def test_enroll_success(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )

        assert resp.status_code == 201
        data = resp.json()["data"]
        assert data["utilisateur_uuid"] == user_uuid
        assert data["active"] is True
        assert data["meal_registered"] is False

    def test_verify_success(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        enroll_resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        assert enroll_resp.status_code == 201

        resp = client.post(
            "/api/v1/face/verify",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["statut"] == "MATCH"

    def test_verify_no_embedding(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        resp = client.post(
            "/api/v1/face/verify",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["statut"] == "NO_MATCH"

    def test_identify_success(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )

        resp = client.post(
            "/api/v1/face/identify",
            json={"image_base64": _valid_image_base64()},
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["statut"] == "MATCH"
        assert data["utilisateur_uuid"] is None
        assert data["identification_token"]

    def test_face_grant_registers_meal(
        self,
        client: TestClient,
        db_session: Session,
    ):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)
        MealService.seed_categories(db_session)
        category = MealService().get_categories(db_session)[0]

        enroll_response = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        assert enroll_response.status_code == 201

        identify_response = client.post(
            "/api/v1/face/identify",
            json={"image_base64": _valid_image_base64()},
            headers=_auth_header(token),
        )
        grant = identify_response.json()["data"]["identification_token"]

        with patch("app.services.meal_service.is_restaurant_open", return_value=True):
            meal_response = client.post(
                "/api/v1/meals/register",
                json={
                    "identification_token": grant,
                    "categorie_uuid": category.uuid,
                },
                headers=_auth_header(token),
            )

        assert meal_response.status_code == 201
        assert meal_response.json()["data"]["type_identification"] == "FACE"
        stored = db_session.query(Meal).filter(Meal.utilisateur_uuid == user_uuid).one()
        assert stored.categorie_uuid == category.uuid

        repeated_identification = client.post(
            "/api/v1/face/identify",
            json={"image_base64": _valid_image_base64()},
            headers=_auth_header(token),
        )
        assert repeated_identification.status_code == 409
        assert "déjà été enregistré" in repeated_identification.json()["message"]

    def test_get_embedding(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        enroll_resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        embedding_uuid = enroll_resp.json()["data"]["uuid"]

        resp = client.get(
            f"/api/v1/face/{embedding_uuid}",
            headers=_auth_header(token),
        )
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["uuid"] == embedding_uuid
        assert data["utilisateur_uuid"] == user_uuid

    def test_delete_embedding(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        enroll_resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        embedding_uuid = enroll_resp.json()["data"]["uuid"]

        resp = client.delete(
            f"/api/v1/face/{embedding_uuid}",
            headers=_auth_header(token),
        )
        assert resp.status_code == 204

        get_resp = client.get(
            f"/api/v1/face/{embedding_uuid}",
            headers=_auth_header(token),
        )
        assert get_resp.status_code == 404

    def test_delete_requires_auth(self, client: TestClient, db_session: Session):
        token = _login(client, db_session)
        user_uuid = _create_employee_via_api(client, token)

        enroll_resp = client.post(
            "/api/v1/face/enroll",
            json={
                "image_base64": _valid_image_base64(),
                "utilisateur_uuid": user_uuid,
            },
            headers=_auth_header(token),
        )
        embedding_uuid = enroll_resp.json()["data"]["uuid"]

        resp = client.delete(
            f"/api/v1/face/{embedding_uuid}",
        )
        assert resp.status_code == 401
