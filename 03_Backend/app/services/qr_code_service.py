"""QR Code service — business logic for QR lifecycle management.

Overview
--------
The service provides five core operations:

1. **Generate** — Create a new QR code for an intern or visitor.
2. **Validate** — Check a raw QR token and return a standardised status.
3. **Revoke** — Invalidate a QR code (lost, regeneration, manual, …).
4. **Regenerate** — Revoke the current QR and create a new one.
5. **Get / Download** — Retrieve QR metadata or the PNG image.
"""

from datetime import UTC, datetime

from loguru import logger
from sqlalchemy.orm import Session

from sqlalchemy import select

from app.core.exceptions import BusinessException, NotFoundException
from app.models.admin import Admin
from app.models.intern import Intern
from app.models.qr_code import QrCode
from app.models.user import StatutUtilisateur
from app.models.visitor import Visitor
from app.repositories.qr_code import QrCodeRepository
from app.repositories.user import UserRepository
from app.schemas.qr_code import QrValidationResponse, ValidationStatut
from app.utils.date_utils import end_of_day, is_expired, now_utc
from app.utils.qr_code import generate_qr_base64, generate_qr_image, generate_token, hash_token


class QrCodeService:
    """Business logic for QR code lifecycle management."""

    def __init__(
        self,
        qr_repo: QrCodeRepository | None = None,
        user_repo: UserRepository | None = None,
    ) -> None:
        self._qr_repo = qr_repo or QrCodeRepository()
        self._user_repo = user_repo or UserRepository()

    # ==================================================================
    # Generate
    # ==================================================================

    def generate_for_intern(self, db: Session, intern_uuid: str, admin: Admin) -> QrCode:
        """Generate a new QR code for an intern.

        The QR expires at ``23:59:59`` on the intern's ``date_fin_stage``.
        Any previously active QR for this intern is automatically revoked.
        """
        intern = self._load_owner(db, intern_uuid, Intern, "Stagiaire")

        self._revoke_active_qr(db, intern_uuid, admin, "Regénération")

        token = generate_token()
        qr_hash = hash_token(token)
        expires_at = end_of_day(intern.date_fin_stage)

        qr_base64 = generate_qr_base64(token)

        qr = self._qr_repo.create(
            db,
            qr_hash=qr_hash,
            proprietaire_uuid=intern.uuid,
            type_proprietaire="STAGIAIRE",
            statut="ACTIF",
            date_expiration=expires_at,
            cree_par_uuid=admin.uuid,
            metadata_json=qr_base64,
        )

        logger.info(
            "QR generated for intern",
            extra={"qr_uuid": qr.uuid, "intern_uuid": intern_uuid, "admin": admin.uuid},
        )
        qr._raw_token = token
        return qr

    def generate_for_visitor(self, db: Session, visitor_uuid: str, admin: Admin) -> QrCode:
        """Generate a new QR code for a visitor.

        The QR expires at ``23:59:59`` on the visitor's ``date_visite``.
        Any previously active QR for this visitor is automatically revoked.
        """
        visitor = self._load_owner(db, visitor_uuid, Visitor, "Visiteur")

        self._revoke_active_qr(db, visitor_uuid, admin, "Regénération")

        token = generate_token()
        qr_hash = hash_token(token)
        expires_at = end_of_day(visitor.date_visite)

        qr_base64 = generate_qr_base64(token)

        qr = self._qr_repo.create(
            db,
            qr_hash=qr_hash,
            proprietaire_uuid=visitor.uuid,
            type_proprietaire="VISITEUR",
            statut="ACTIF",
            date_expiration=expires_at,
            cree_par_uuid=admin.uuid,
            metadata_json=qr_base64,
        )

        logger.info(
            "QR generated for visitor",
            extra={"qr_uuid": qr.uuid, "visitor_uuid": visitor_uuid, "admin": admin.uuid},
        )
        qr._raw_token = token
        return qr

    # ==================================================================
    # Validate
    # ==================================================================

    def validate(self, db: Session, token: str) -> QrValidationResponse:
        """Validate a raw QR token and return a standardised result.

        Validation checks in order:
        1. Token format (length ≥ 32).
        2. QR exists in database.
        3. QR not revoked.
        4. QR not expired.
        5. Owner account is ``ACTIF`` and not soft-deleted.
        """
        if not token or len(token) < 32:
            return QrValidationResponse(statut=ValidationStatut.INVALID, message="Token invalide.")

        qr_hash = hash_token(token)
        qr = self._qr_repo.get_by_hash(db, qr_hash)

        if qr is None:
            return QrValidationResponse(statut=ValidationStatut.NOT_FOUND, message="QR code introuvable.")

        if qr.statut == "REVOQUE":
            return QrValidationResponse(
                statut=ValidationStatut.REVOKED,
                message="QR code révoqué.",
                qr_uuid=qr.uuid,
                proprietaire_uuid=qr.proprietaire_uuid,
                type_proprietaire=qr.type_proprietaire,
            )

        if is_expired(qr.date_expiration):
            qr.statut = "EXPIRE"
            db.flush()
            return QrValidationResponse(
                statut=ValidationStatut.EXPIRED,
                message="QR code expiré.",
                qr_uuid=qr.uuid,
                proprietaire_uuid=qr.proprietaire_uuid,
                type_proprietaire=qr.type_proprietaire,
                date_expiration=qr.date_expiration,
            )

        owner = self._user_repo.get_by_uuid(db, qr.proprietaire_uuid)
        if owner is None or owner.statut != StatutUtilisateur.ACTIF or owner.date_suppression is not None:
            return QrValidationResponse(
                statut=ValidationStatut.OWNER_DISABLED,
                message="Compte propriétaire désactivé ou supprimé.",
                qr_uuid=qr.uuid,
                proprietaire_uuid=qr.proprietaire_uuid,
                type_proprietaire=qr.type_proprietaire,
            )

        qr.derniere_validation = now_utc()
        qr.nombre_validations = (qr.nombre_validations or 0) + 1
        db.flush()

        logger.info(
            "QR validated",
            extra={"qr_uuid": qr.uuid, "proprietaire_uuid": qr.proprietaire_uuid},
        )

        return QrValidationResponse(
            statut=ValidationStatut.VALID,
            message="QR code valide.",
            qr_uuid=qr.uuid,
            proprietaire_uuid=qr.proprietaire_uuid,
            type_proprietaire=qr.type_proprietaire,
            nom=owner.nom,
            prenom=owner.prenom,
            date_expiration=qr.date_expiration,
            nombre_validations=qr.nombre_validations,
        )

    # ==================================================================
    # Revoke
    # ==================================================================

    def revoke(self, db: Session, qr_uuid: str, admin: Admin, reason: str = "Révoqué manuellement") -> QrCode:
        """Revoke a QR code manually.

        :param reason: One of ``Perdu``, ``Regénération``, ``Stage terminé``,
            ``Visite annulée``, or a custom description.
        """
        qr = self._get_qr(db, qr_uuid)

        if qr.statut != "ACTIF":
            raise BusinessException(
                message=f"Impossible de révoquer un QR code avec le statut « {qr.statut} ».",
            )

        qr.statut = "REVOQUE"
        qr.date_revocation = now_utc()
        qr.revoque_par_uuid = admin.uuid
        qr.motif_revocation = reason
        db.flush()

        logger.info(
            "QR revoked",
            extra={"qr_uuid": qr_uuid, "reason": reason, "admin": admin.uuid},
        )
        return qr

    # ==================================================================
    # Regenerate
    # ==================================================================

    def regenerate(self, db: Session, owner_uuid: str, owner_type: str, admin: Admin) -> QrCode:
        """Regenerate a QR code for an owner.

        Revokes the currently active QR (if any) and creates a new one.
        Preserves full audit history.
        """
        if owner_type == "STAGIAIRE":
            return self.generate_for_intern(db, owner_uuid, admin)
        elif owner_type == "VISITEUR":
            return self.generate_for_visitor(db, owner_uuid, admin)
        else:
            raise BusinessException(message=f"Type de propriétaire inconnu : {owner_type}")

    # ==================================================================
    # Get & Download
    # ==================================================================

    def get(self, db: Session, qr_uuid: str, include_token: bool = False) -> QrCode:
        """Retrieve a QR code by its UUID.

        :param include_token: If ``True``, attaches ``_raw_token`` to the
            instance for generating the QR image.  This is only possible
            if the QR was just created in the same transaction (the raw
            token is never persisted).
        """
        qr = self._get_qr(db, qr_uuid)

        qr._include_token = include_token
        return qr

    def download(self, db: Session, qr_uuid: str) -> tuple[bytes, str]:
        """Return the QR PNG image bytes and the owner type.

        The base64-encoded PNG is stored in ``metadata_json`` at
        generation time, so it is always available for download.
        """
        qr = self._get_qr(db, qr_uuid)

        png_bytes = self._get_png_from_metadata(qr)
        return png_bytes, qr.type_proprietaire

    def _get_png_from_metadata(self, qr: QrCode) -> bytes:
        """Decode a base64 data URI stored in metadata_json back to PNG bytes."""
        import base64

        if not qr.metadata_json or not qr.metadata_json.startswith("data:image/png;base64,"):
            raise BusinessException(
                message="Aucune image QR stockée. Régénérez le QR code.",
            )
        b64_data = qr.metadata_json.split(",", 1)[1]
        return base64.b64decode(b64_data)

    def get_history(self, db: Session, owner_uuid: str) -> list[QrCode]:
        """Return all QR codes ever issued to an owner."""
        owner = self._user_repo.get_by_uuid(db, owner_uuid)
        if owner is None:
            raise NotFoundException(message=f"Utilisateur {owner_uuid} introuvable.")
        return self._qr_repo.get_history_by_owner(db, owner_uuid)

    # ==================================================================
    # Internal helpers
    # ==================================================================

    def _load_owner(self, db: Session, uuid: str, model_cls: type, label: str):
        """Load a polymorphic owner by UUID and verify it is active."""
        stmt = select(model_cls).where(model_cls.uuid == uuid)
        owner = db.execute(stmt).scalar_one_or_none()

        if owner is None or owner.date_suppression is not None:
            raise NotFoundException(message=f"{label} {uuid} introuvable.")
        if owner.statut != StatutUtilisateur.ACTIF:
            raise BusinessException(
                message=f"{label} {uuid} est désactivé.",
                details={"statut": str(owner.statut)},
            )
        return owner

    def _revoke_active_qr(self, db: Session, owner_uuid: str, admin: Admin, reason: str) -> None:
        """If the owner has an active QR, revoke it before generating a new one."""
        active = self._qr_repo.get_active_by_owner(db, owner_uuid)
        if active is not None:
            active.statut = "REVOQUE"
            active.date_revocation = now_utc()
            active.revoque_par_uuid = admin.uuid
            active.motif_revocation = reason
            db.flush()
            logger.info(
                "Previous QR revoked during regeneration",
                extra={"qr_uuid": active.uuid, "owner_uuid": owner_uuid, "admin": admin.uuid},
            )

    def _get_qr(self, db: Session, qr_uuid: str) -> QrCode:
        """Load a QR code by UUID or raise."""
        qr = self._qr_repo.get_by_uuid(db, qr_uuid)
        if qr is None:
            raise NotFoundException(message=f"QR code {qr_uuid} introuvable.")
        return qr
