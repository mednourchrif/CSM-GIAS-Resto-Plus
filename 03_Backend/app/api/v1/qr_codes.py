"""QR Code management endpoints.

All endpoints are protected by ``require_admin`` except the visitor
generation which uses ``require_reception`` (receptionists create
visitor QR codes per BR-019).

The ``validate`` endpoint is also protected by admin authentication.
In a future milestone, this endpoint may be exposed to internal
services (meal registration, mobile scanner) via an API key or
service-to-service token.
"""

from fastapi import APIRouter, Depends, Response
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.schemas.pagination import PaginationParams
from app.schemas.qr_code import (
    QrCodeResponse,
    QrGenerateResponse,
    QrValidateRequest,
    QrValidationResponse,
)
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.security.dependencies import require_admin, require_reception
from app.services.qr_code_service import QrCodeService
from app.utils.qr_code import generate_qr_base64

router = APIRouter(prefix="/qr", tags=["qr-codes"])

_service = QrCodeService()


@router.get(
    "",
    summary="Lister les QR codes",
    description=(
        "Retourne la liste paginée des codes QR avec possibilité de "
        "recherche, filtre par type et statut."
    ),
    response_model=PaginatedResponse[QrCodeResponse],
)
async def list_qr_codes(
    params: PaginationParams = Depends(),
    type: str | None = None,
    status: str | None = None,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> PaginatedResponse[QrCodeResponse]:
    """List QR codes with pagination, search, and optional filters."""
    result = _service.get_list(
        db,
        search=params.search,
        type_filter=type,
        status_filter=status,
        sort=params.sort,
        order=params.order,
        page=params.page,
        page_size=params.page_size,
    )
    return PaginatedResponse(
        success=True,
        data=[
            QrCodeResponse(
                id=qr.id,
                uuid=qr.uuid,
                created_at=qr.created_at,
                updated_at=qr.updated_at,
                qr_hash=qr.qr_hash,
                proprietaire_uuid=qr.proprietaire_uuid,
                type_proprietaire=qr.type_proprietaire,
                statut=qr.statut,
                date_expiration=qr.date_expiration,
                cree_par_uuid=qr.cree_par_uuid,
                date_revocation=qr.date_revocation,
                revoque_par_uuid=qr.revoque_par_uuid,
                motif_revocation=qr.motif_revocation,
                derniere_validation=qr.derniere_validation,
                nombre_validations=qr.nombre_validations,
                metadata_json=qr.metadata_json,
                proprietaire_nom=nom,
                proprietaire_prenom=prenom,
            )
            for qr, nom, prenom in result.items
        ],
        total=result.total,
        page=result.page,
        page_size=result.page_size,
        total_pages=result.total_pages,
    )


@router.post(
    "/generate/intern/{uuid}",
    summary="Générer un QR pour un stagiaire",
    description=(
        "Génère un nouveau code QR pour un stagiaire.  Le QR expire à "
        "23:59:59 le jour de fin de stage.  Tout QR actif précédent est "
        "révoqué automatiquement."
    ),
    response_model=SuccessResponse[QrGenerateResponse],
    status_code=201,
)
async def generate_intern_qr(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[QrGenerateResponse]:
    """Generate a new QR code for an intern.

    The QR expires at ``23:59:59`` on the intern's internship end date.
    Any previously active QR for this intern is revoked automatically.
    """
    qr = _service.generate_for_intern(db, uuid, admin)
    return SuccessResponse(
        data=QrGenerateResponse(
            id=qr.id,
            uuid=qr.uuid,
            created_at=qr.created_at,
            updated_at=qr.updated_at,
            qr_hash=qr.qr_hash,
            proprietaire_uuid=qr.proprietaire_uuid,
            type_proprietaire=qr.type_proprietaire,
            statut=qr.statut,
            date_expiration=qr.date_expiration,
            qr_token=qr._raw_token,
            qr_base64=generate_qr_base64(qr._raw_token),
            cree_par_uuid=qr.cree_par_uuid,
        ),
    )


@router.post(
    "/generate/visitor/{uuid}",
    summary="Générer un QR pour un visiteur",
    description=(
        "Génère un nouveau code QR pour un visiteur.  Le QR expire à "
        "23:59:59 le jour de la visite.  Tout QR actif précédent est "
        "révoqué automatiquement."
    ),
    response_model=SuccessResponse[QrGenerateResponse],
    status_code=201,
)
async def generate_visitor_qr(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_reception),
) -> SuccessResponse[QrGenerateResponse]:
    """Generate a new QR code for a visitor.

    The QR expires at ``23:59:59`` on the visitor's visit date.
    Any previously active QR for this visitor is revoked automatically.
    """
    qr = _service.generate_for_visitor(db, uuid, admin)
    return SuccessResponse(
        data=QrGenerateResponse(
            id=qr.id,
            uuid=qr.uuid,
            created_at=qr.created_at,
            updated_at=qr.updated_at,
            qr_hash=qr.qr_hash,
            proprietaire_uuid=qr.proprietaire_uuid,
            type_proprietaire=qr.type_proprietaire,
            statut=qr.statut,
            date_expiration=qr.date_expiration,
            qr_token=qr._raw_token,
            qr_base64=generate_qr_base64(qr._raw_token),
            cree_par_uuid=qr.cree_par_uuid,
        ),
    )


@router.post(
    "/validate",
    summary="Valider un token QR",
    description=(
        "Valide un token QR brut.  Retourne un statut parmi : ``VALID``, "
        "``EXPIRED``, ``REVOKED``, ``NOT_FOUND``, ``OWNER_DISABLED``, "
        "``INVALID``."
    ),
    response_model=SuccessResponse[QrValidationResponse],
)
async def validate_qr(
    body: QrValidateRequest,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[QrValidationResponse]:
    """Validate a raw QR token.

    Returns a standardised validation result with one of: ``VALID``,
    ``EXPIRED``, ``REVOKED``, ``NOT_FOUND``, ``OWNER_DISABLED``,
    ``INVALID``.

    .. note::
       Currently requires admin authentication.  In a future milestone
       this endpoint may be exposed to internal services (meal
       registration, mobile scanner).
    """
    result = _service.validate(db, body.token)
    return SuccessResponse(data=result)


@router.post(
    "/revoke/{uuid}",
    summary="Révoquer un QR code",
    description=(
        "Révoque un code QR actif.  Motifs possibles : ``Perdu``, "
        "``Regénération``, ``Stage terminé``, ``Visite annulée``."
    ),
    response_model=SuccessResponse[QrCodeResponse],
)
async def revoke_qr(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[QrCodeResponse]:
    """Revoke an active QR code.

    Provide a reason via the ``X-Revoke-Reason`` header or query param.
    Possible reasons: ``Perdu``, ``Regénération``, ``Stage terminé``,
    ``Visite annulée``.
    """
    qr = _service.revoke(db, uuid, admin)
    return SuccessResponse(
        data=QrCodeResponse(
            id=qr.id,
            uuid=qr.uuid,
            created_at=qr.created_at,
            updated_at=qr.updated_at,
            qr_hash=qr.qr_hash,
            proprietaire_uuid=qr.proprietaire_uuid,
            type_proprietaire=qr.type_proprietaire,
            statut=qr.statut,
            date_expiration=qr.date_expiration,
            cree_par_uuid=qr.cree_par_uuid,
            date_revocation=qr.date_revocation,
            revoque_par_uuid=qr.revoque_par_uuid,
            motif_revocation=qr.motif_revocation,
            derniere_validation=qr.derniere_validation,
            nombre_validations=qr.nombre_validations,
            metadata_json=qr.metadata_json,
        ),
    )


@router.post(
    "/regenerate/{uuid}",
    summary="Régénérer un QR code",
    description=(
        "Révoque le QR actif d'un propriétaire et en génère un nouveau. "
        "Utiliser le paramètre ``owner_type`` — ``STAGIAIRE`` (défaut) "
        "ou ``VISITEUR``."
    ),
    response_model=SuccessResponse[QrGenerateResponse],
    status_code=201,
)
async def regenerate_qr(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
    owner_type: str = "STAGIAIRE",
) -> SuccessResponse[QrGenerateResponse]:
    """Regenerate a QR code for an owner.

    Automatically revokes the previous active QR and creates a new one.
    Use query parameter ``owner_type`` — ``STAGIAIRE`` (default) or
    ``VISITEUR``.
    """
    qr = _service.regenerate(db, uuid, owner_type, admin)
    return SuccessResponse(
        data=QrGenerateResponse(
            id=qr.id,
            uuid=qr.uuid,
            created_at=qr.created_at,
            updated_at=qr.updated_at,
            qr_hash=qr.qr_hash,
            proprietaire_uuid=qr.proprietaire_uuid,
            type_proprietaire=qr.type_proprietaire,
            statut=qr.statut,
            date_expiration=qr.date_expiration,
            qr_token=qr._raw_token,
            qr_base64=generate_qr_base64(qr._raw_token),
            cree_par_uuid=qr.cree_par_uuid,
        ),
    )


@router.get(
    "/{uuid}",
    summary="Obtenir un QR code",
    description="Retourne les détails d'un code QR à partir de son UUID.",
    response_model=SuccessResponse[QrCodeResponse],
)
async def get_qr(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[QrCodeResponse]:
    """Get QR code details by UUID.

    Includes the Base64-encoded PNG image stored at generation time.
    """
    qr = _service.get(db, uuid)

    from app.repositories.user import UserRepository

    owner = UserRepository().get_by_uuid(db, qr.proprietaire_uuid)

    return SuccessResponse(
        data=QrCodeResponse(
            id=qr.id,
            uuid=qr.uuid,
            created_at=qr.created_at,
            updated_at=qr.updated_at,
            qr_hash=qr.qr_hash,
            proprietaire_uuid=qr.proprietaire_uuid,
            type_proprietaire=qr.type_proprietaire,
            statut=qr.statut,
            date_expiration=qr.date_expiration,
            cree_par_uuid=qr.cree_par_uuid,
            date_revocation=qr.date_revocation,
            revoque_par_uuid=qr.revoque_par_uuid,
            motif_revocation=qr.motif_revocation,
            derniere_validation=qr.derniere_validation,
            nombre_validations=qr.nombre_validations,
            metadata_json=qr.metadata_json,
            qr_base64=qr.metadata_json,
            proprietaire_nom=owner.nom if owner else None,
            proprietaire_prenom=owner.prenom if owner else None,
        ),
    )


@router.get(
    "/download/{uuid}",
    summary="Télécharger un QR code en PNG",
    description=(
        "Télécharge l'image PNG du code QR.  Le token brut n'est "
        "disponible qu'immédiatement après génération."
    ),
)
async def download_qr(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    """Download the QR code as a PNG image.

    The raw token is only available immediately after generation.
    For existing QRs, regenerate first to obtain a new downloadable image.
    """
    png_bytes, owner_type = _service.download(db, uuid)
    return Response(
        content=png_bytes,
        media_type="image/png",
        headers={
            "Content-Disposition": f"attachment; filename=qr_{uuid}.png",
        },
    )


@router.get(
    "/history/{owner_uuid}",
    summary="Historique des QR d'un propriétaire",
    description="Retourne tous les codes QR émis pour un propriétaire (du plus récent au plus ancien).",
    response_model=SuccessResponse[list[QrCodeResponse]],
)
async def get_qr_history(
    owner_uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[list[QrCodeResponse]]:
    """Get all QR codes ever issued to an owner (newest first)."""
    history = _service.get_history(db, owner_uuid)
    return SuccessResponse(
        data=[
            QrCodeResponse(
                id=qr.id,
                uuid=qr.uuid,
                created_at=qr.created_at,
                updated_at=qr.updated_at,
                qr_hash=qr.qr_hash,
                proprietaire_uuid=qr.proprietaire_uuid,
                type_proprietaire=qr.type_proprietaire,
                statut=qr.statut,
                date_expiration=qr.date_expiration,
                cree_par_uuid=qr.cree_par_uuid,
                date_revocation=qr.date_revocation,
                revoque_par_uuid=qr.revoque_par_uuid,
                motif_revocation=qr.motif_revocation,
                derniere_validation=qr.derniere_validation,
                nombre_validations=qr.nombre_validations,
                metadata_json=qr.metadata_json,
            )
            for qr in history
        ],
    )
