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

import numpy as np
from sqlalchemy.orm import Session

from app.ai.engine import FaceRecognitionEngine, StubFaceRecognitionEngine
from app.core.exceptions import BusinessException, NotFoundException
from app.models.face_embedding import FaceEmbedding
from app.repositories.face_repository import FaceEmbeddingRepository
from app.repositories.user import UserRepository
from app.schemas.face import FaceStatut
from app.services.meal_service import MealService
from app.utils.image import decode_base64_image, validate_image_format

_EMBEDDING_DIM = 512
_CONFIDENCE_THRESHOLD = 0.5


class FaceService:
    """Face recognition business logic."""

    def __init__(
        self,
        engine: FaceRecognitionEngine | None = None,
        repository: FaceEmbeddingRepository | None = None,
        user_repo: UserRepository | None = None,
        meal_service: MealService | None = None,
    ) -> None:
        self._engine = engine or StubFaceRecognitionEngine()
        self._repo = repository or FaceEmbeddingRepository()
        self._user_repo = user_repo or UserRepository()
        self._meal_service = meal_service or MealService()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def enroll(
        self,
        db: Session,
        image_base64: str,
        user_uuid: str,
        categorie_uuid: str | None = None,
    ) -> tuple[FaceEmbedding, bool]:
        """Enroll a face embedding for a user.

        1. Validates the image.
        2. Extracts a face embedding.
        3. Deactivates any previous active embedding for the same user.
        4. Persists the new embedding.
        5. Optionally registers a meal via :meth:`MealService.register_by_user_uuid`.

        :param db: Active database session.
        :param image_base64: Base64-encoded data URI of the face image.
        :param user_uuid: UUID of the user to enroll.
        :param categorie_uuid: Optional meal category UUID.  When provided,
            a meal is automatically registered after enrollment.
        :returns: A tuple of ``(FaceEmbedding, meal_registered_flag)``.
        :raises BusinessException: If no face is detected.
        """
        image = decode_base64_image(image_base64)
        validate_image_format(image)

        detection = self._engine.detect_face(image)
        if detection is None or detection.confidence < 0.5:
            raise BusinessException(
                message="Aucun visage détecté dans l'image.",
            )

        embedding_vec = self._engine.extract_embedding(image)
        if embedding_vec.shape[0] != _EMBEDDING_DIM:
            raise BusinessException(
                message=f"Dimension d'empreinte invalide : {embedding_vec.shape[0]}.",
            )

        embedding_bytes = embedding_vec.astype(np.float32).tobytes()

        self._repo.deactivate_all_for_user(db, user_uuid)

        face_embedding = self._repo.create(
            db=db,
            utilisateur_uuid=user_uuid,
            embedding=embedding_bytes,
            model_name="stub",
            model_version="1.0.0",
            quality_score=0.95,
            active=True,
        )

        meal_registered = False
        if categorie_uuid:
            self._meal_service.register_by_user_uuid(
                db=db,
                user_uuid=user_uuid,
                categorie_uuid=categorie_uuid,
                type_identification="FACE",
            )
            meal_registered = True

        return face_embedding, meal_registered

    def verify(
        self,
        db: Session,
        image_base64: str,
        user_uuid: str,
    ) -> tuple:
        """Verify a user's identity against their stored face embedding.

        :param db: Active database session.
        :param image_base64: Base64-encoded data URI of the face image.
        :param user_uuid: UUID of the claimed user.
        :returns: A tuple of
            ``(statut, confidence, utilisateur_uuid, nom, prenom, message)``.
        """
        image = decode_base64_image(image_base64)
        validate_image_format(image)

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

        new_embedding = self._engine.extract_embedding(image)
        stored_vec = np.frombuffer(stored.embedding, dtype=np.float32)

        confidence = self._engine.compare(new_embedding, stored_vec)

        user = self._user_repo.get_by_uuid(db, user_uuid)
        nom = user.nom if user else None
        prenom = user.prenom if user else None

        if confidence >= _CONFIDENCE_THRESHOLD:
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
    ) -> tuple:
        """Identify a user by comparing against all stored active embeddings.

        :param db: Active database session.
        :param image_base64: Base64-encoded data URI of the face image.
        :returns: A tuple of
            ``(statut, confidence, utilisateur_uuid, nom, prenom, type, message)``.
        """
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

        query_embedding = self._engine.extract_embedding(image)

        best_match: FaceEmbedding | None = None
        best_confidence = -1.0

        for emb in all_embeddings:
            stored_vec = np.frombuffer(emb.embedding, dtype=np.float32)
            confidence = self._engine.compare(query_embedding, stored_vec)
            if confidence > best_confidence:
                best_confidence = confidence
                best_match = emb

        if best_match is None or best_confidence < _CONFIDENCE_THRESHOLD:
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
        if user is None:
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
        """Soft-delete a face embedding by setting ``active=False``.

        :raises NotFoundException: If the record does not exist.
        """
        embedding = self.get_by_uuid(db, uuid)
        embedding.active = False
        db.flush()
