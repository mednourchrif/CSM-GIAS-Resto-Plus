"""Face service — business logic for enrollment, verification, and identification.

This service orchestrates the face recognition pipeline:

1. Decode and validate the input image.
2. Extract a face embedding via the pluggable :class:`FaceRecognitionEngine`.
3. Persist / compare embeddings via the :class:`FaceEmbeddingRepository`.
4. Optionally register a meal via :class:`MealService` (identification-agnostic
   integration — the meal service never knows recognition happened).

Design
------
* The service depends **only** on the abstract :class:`FaceRecognitionEngine`
  interface, never on a concrete implementation.
* Embeddings are serialised to raw bytes (``numpy.ndarray.tobytes()``) for
  storage and deserialised (``numpy.frombuffer``) for comparison.
* Re-enrollment deactivates the previous active embedding before storing the
  new one — at most one active embedding per user at any time.
"""

from typing import TypeGuard

import numpy as np
from loguru import logger
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.ai.engine import FaceRecognitionEngine, StubFaceRecognitionEngine
from app.core.config import BaseAppSettings, settings
from app.core.exceptions import (
    BusinessException,
    ConfigurationException,
    NotFoundException,
)
from app.models.employee import Employee, StatutEnrolement
from app.models.face_embedding import FaceEmbedding
from app.models.user import StatutUtilisateur, User
from app.repositories.face_repository import FaceEmbeddingRepository
from app.repositories.setting import SettingRepository
from app.repositories.user import UserRepository
from app.schemas.face import FaceStatut
from app.security.biometrics import BiometricCipher
from app.utils.date_utils import now_utc
from app.utils.image import decode_base64_image, validate_image_format

_EMBEDDING_DIM = 512
_DEFAULT_CONFIDENCE_THRESHOLD = 0.75
FaceVerificationResult = tuple[
    FaceStatut,
    float | None,
    str,
    str | None,
    str | None,
    str | None,
]
FaceIdentificationResult = tuple[
    FaceStatut,
    float | None,
    str | None,
    str | None,
    str | None,
    str | None,
    str | None,
]


class FaceService:
    """Face recognition business logic."""

    def __init__(
        self,
        engine: FaceRecognitionEngine | None = None,
        repository: FaceEmbeddingRepository | None = None,
        user_repo: UserRepository | None = None,
        setting_repo: SettingRepository | None = None,
        cipher: BiometricCipher | None = None,
        config: BaseAppSettings = settings,
    ) -> None:
        self._engine: FaceRecognitionEngine | None
        if engine is not None:
            self._engine = engine
        elif config.FACE_ENGINE.strip().lower() == "stub":
            self._engine = StubFaceRecognitionEngine()
        elif config.FACE_ENGINE.strip().lower() == "disabled":
            self._engine = None
        else:
            raise ConfigurationException(
                message=(f"Le moteur facial « {config.FACE_ENGINE} » " "n'est pas installé."),
            )
        self._repo = repository or FaceEmbeddingRepository()
        self._user_repo = user_repo or UserRepository()
        self._setting_repo = setting_repo or SettingRepository()
        self._cipher = cipher or BiometricCipher()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def enroll(
        self,
        db: Session,
        image_base64: str,
        user_uuid: str,
    ) -> tuple[FaceEmbedding, bool]:
        """Enroll a face embedding for a user.

        1. Validates the image.
        2. Extracts a face embedding.
        3. Deactivates any previous active embedding for the same user.
        4. Persists the new embedding.
        :param db: Active database session.
        :param image_base64: Base64-encoded data URI of the face image.
        :param user_uuid: UUID of the user to enroll.
        :returns: A tuple of ``(FaceEmbedding, meal_registered_flag)``.
        :raises BusinessException: If no face is detected.
        """
        engine = self._require_engine()
        employee = self._get_active_employee(db, user_uuid)
        image = decode_base64_image(image_base64)
        validate_image_format(image)

        detection = engine.detect_face(image)
        if detection is None or detection.confidence < 0.5:
            raise BusinessException(
                message="Aucun visage détecté dans l'image.",
            )

        embedding_vec = engine.extract_embedding(image)
        if embedding_vec.shape[0] != _EMBEDDING_DIM:
            raise BusinessException(
                message=f"Dimension d'empreinte invalide : {embedding_vec.shape[0]}.",
            )

        embedding_bytes = self._cipher.encrypt(embedding_vec.astype(np.float32).tobytes())

        self._repo.deactivate_all_for_user(db, user_uuid)

        face_embedding = self._repo.create(
            db=db,
            utilisateur_uuid=user_uuid,
            embedding=embedding_bytes,
            model_name=type(engine).__name__,
            model_version="2.0.0-dev-perceptual",
            quality_score=0.95,
            active=True,
        )

        employee.statut_enrolement = StatutEnrolement.ENROLE
        employee.date_enrolement = now_utc()
        db.flush()

        return face_embedding, False

    def verify(
        self,
        db: Session,
        image_base64: str,
        user_uuid: str,
    ) -> FaceVerificationResult:
        """Verify a user's identity against their stored face embedding.

        :param db: Active database session.
        :param image_base64: Base64-encoded data URI of the face image.
        :param user_uuid: UUID of the claimed user.
        :returns: A tuple of
            ``(statut, confidence, utilisateur_uuid, nom, prenom, message)``.
        """
        engine = self._require_engine()
        image = decode_base64_image(image_base64)
        validate_image_format(image)

        user = self._user_repo.get_by_uuid(db, user_uuid)
        if not self._is_active_employee(user):
            return (
                FaceStatut.NO_MATCH,
                None,
                user_uuid,
                None,
                None,
                "Aucune empreinte faciale enregistrée pour cet utilisateur.",
            )
        stored = self._repo.get_active_by_user(db, user_uuid)
        if stored is None:
            return (
                FaceStatut.NO_MATCH,
                None,
                user_uuid,
                None,
                None,
                "Aucune empreinte faciale enregistrée pour cet utilisateur.",
            )

        new_embedding = engine.extract_embedding(image)
        stored_vec = self._stored_vector(stored.embedding)

        confidence = engine.compare(new_embedding, stored_vec)

        nom = user.nom
        prenom = user.prenom

        if confidence >= self._confidence_threshold(db):
            return (
                FaceStatut.MATCH,
                confidence,
                user_uuid,
                nom,
                prenom,
                None,
            )
        return (
            FaceStatut.NO_MATCH,
            confidence,
            user_uuid,
            nom,
            prenom,
            "La correspondance faciale est inférieure au seuil requis.",
        )

    def identify(
        self,
        db: Session,
        image_base64: str,
    ) -> FaceIdentificationResult:
        """Identify a user by comparing against all stored active embeddings.

        :param db: Active database session.
        :param image_base64: Base64-encoded data URI of the face image.
        :returns: A tuple of
            ``(statut, confidence, utilisateur_uuid, nom, prenom, type, message)``.
        """
        engine = self._require_engine()
        image = decode_base64_image(image_base64)
        validate_image_format(image)

        all_embeddings = self._repo.get_all_active(db)
        if not all_embeddings:
            return (
                FaceStatut.NO_MATCH,
                None,
                None,
                None,
                None,
                None,
                "Aucune empreinte faciale enregistrée dans le système.",
            )

        query_embedding = engine.extract_embedding(image)

        best_match: FaceEmbedding | None = None
        best_confidence = -1.0

        for emb in all_embeddings:
            stored_vec = self._stored_vector(emb.embedding)
            confidence = engine.compare(query_embedding, stored_vec)
            if confidence > best_confidence:
                best_confidence = confidence
                best_match = emb

        if best_match is None or best_confidence < self._confidence_threshold(db):
            return (
                FaceStatut.NO_MATCH,
                best_confidence if best_confidence >= 0 else None,
                None,
                None,
                None,
                None,
                "Aucune correspondance faciale trouvée.",
            )

        user = self._user_repo.get_by_uuid(db, best_match.utilisateur_uuid)
        if not self._is_active_employee(user):
            return (
                FaceStatut.NO_MATCH,
                best_confidence,
                None,
                None,
                None,
                None,
                "Utilisateur associé à l'empreinte introuvable.",
            )

        return (
            FaceStatut.MATCH,
            best_confidence,
            user.uuid,
            user.nom,
            user.prenom,
            str(user.type) if hasattr(user, "type") else None,
            None,
        )

    def _confidence_threshold(self, db: Session) -> float:
        setting = self._setting_repo.get_by_key(db, "face_similarity_threshold")
        if setting is None:
            return _DEFAULT_CONFIDENCE_THRESHOLD
        try:
            threshold = float(setting.value)
        except ValueError:
            return _DEFAULT_CONFIDENCE_THRESHOLD
        return threshold if 0.5 <= threshold <= 0.99 else _DEFAULT_CONFIDENCE_THRESHOLD

    def _require_engine(self) -> FaceRecognitionEngine:
        if self._engine is None:
            raise BusinessException(
                message=(
                    "La reconnaissance faciale est indisponible. "
                    "Veuillez utiliser un QR Code ou contacter l'administration."
                ),
            )
        return self._engine

    def _stored_vector(self, stored: bytes) -> np.ndarray:
        if not self._cipher.is_encrypted(stored):
            logger.warning(
                "Legacy unencrypted biometric template detected; "
                "administrator re-enrollment is required"
            )
        raw = self._cipher.decrypt(stored)
        expected_size = _EMBEDDING_DIM * np.dtype(np.float32).itemsize
        if len(raw) != expected_size:
            raise ConfigurationException(
                message="L'empreinte biométrique stockée a un format invalide.",
            )
        return np.frombuffer(raw, dtype=np.float32)

    def get_by_uuid(self, db: Session, uuid: str) -> FaceEmbedding:
        """Fetch a face embedding record by UUID.

        :raises NotFoundException: If the record does not exist.
        """
        embedding = self._repo.get_by_uuid(db, uuid)
        if embedding is None:
            raise NotFoundException(
                message="Empreinte faciale introuvable.",
                details={"uuid": uuid},
            )
        return embedding

    def delete_embedding(self, db: Session, uuid: str) -> None:
        """Permanently delete a face embedding.

        Resets the employee's enrollment status to ``NON_ENROLE`` if no
        active embeddings remain for that user.

        :raises NotFoundException: If the record does not exist.
        """
        embedding = self.get_by_uuid(db, uuid)
        user_uuid = embedding.utilisateur_uuid
        db.delete(embedding)
        db.flush()

        remaining = self._repo.get_active_by_user(db, user_uuid)
        if remaining is None:
            stmt = select(Employee).where(Employee.uuid == user_uuid)
            employee = db.execute(stmt).scalar_one_or_none()
            if employee is not None:
                employee.statut_enrolement = StatutEnrolement.NON_ENROLE
                db.flush()

    def delete_for_user(self, db: Session, user_uuid: str) -> int:
        """Permanently erase every face template for one employee."""
        employee = self._get_active_employee(db, user_uuid)
        deleted = self._repo.delete_all_for_user(db, user_uuid)
        if deleted == 0:
            raise NotFoundException(
                message="Aucune empreinte faciale à supprimer.",
            )
        employee.statut_enrolement = StatutEnrolement.NON_ENROLE
        employee.date_enrolement = None
        db.flush()
        return deleted

    @staticmethod
    def _is_active_employee(user: User | None) -> TypeGuard[Employee]:
        return (
            isinstance(user, Employee)
            and user.date_suppression is None
            and user.statut == StatutUtilisateur.ACTIF
        )

    def _get_active_employee(self, db: Session, user_uuid: str) -> Employee:
        user = self._user_repo.get_by_uuid(db, user_uuid)
        if user is None or user.date_suppression is not None:
            raise NotFoundException(message="Employé introuvable.")
        if not isinstance(user, Employee):
            raise BusinessException(
                message="L'enrôlement facial est réservé aux employés.",
            )
        if user.statut != StatutUtilisateur.ACTIF:
            raise BusinessException(
                message="Impossible d'enrôler un employé inactif.",
            )
        return user
