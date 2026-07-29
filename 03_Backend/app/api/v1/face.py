"""Face recognition API endpoints — enrollment, verification, and identification.

Endpoints
---------
* ``POST /api/v1/face/enroll``   — Enroll a face for a user (admin only).
* ``POST /api/v1/face/verify``   — Verify by face (managed kiosk).
* ``POST /api/v1/face/identify`` — Identify by face (managed kiosk).
* ``GET  /api/v1/face/{uuid}``   — Get embedding metadata (admin only).
* ``DELETE /api/v1/face/{uuid}`` — Permanently erase a template (admin only).


Design
------
Meal selection and confirmation are intentionally separate operations.
Identification never registers a meal automatically.
"""

import base64

from fastapi import APIRouter, Depends, File, Form, Response, UploadFile, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.core.exceptions import BusinessException, ValidationException
from app.models.admin import Admin
from app.models.face_embedding import FaceEmbedding
from app.schemas.face import (
    FaceEmbeddingResponse,
    FaceEnrollRequest,
    FaceEnrollResponse,
    FaceIdentifyRequest,
    FaceIdentifyResponse,
    FaceVerifyRequest,
    FaceVerifyResponse,
)
from app.schemas.response import SuccessResponse
from app.security.dependencies import require_admin, require_kiosk_access
from app.services.audit_service import AuditLogService
from app.services.face_service import FaceService
from app.services.identification_service import IdentificationService
from app.services.meal_service import MealService
from app.services.setting_service import SettingService
from app.utils.date_utils import ensure_utc

router = APIRouter(prefix="/face", tags=["face"])

_service = FaceService()
_identification_service = IdentificationService()
_meal_service = MealService()
_setting_service = SettingService()
_audit = AuditLogService()


@router.post(
    "/enroll",
    summary="Enrôler une empreinte faciale",
    description="Enrôle une empreinte faciale pour un employé actif.",
    response_model=SuccessResponse[FaceEnrollResponse],
    status_code=status.HTTP_201_CREATED,
)
async def enroll(
    body: FaceEnrollRequest,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[FaceEnrollResponse]:
    """Enroll a face embedding for a user."""
    embedding, meal_registered = _service.enroll(
        db=db,
        image_base64=body.image_base64,
        user_uuid=body.utilisateur_uuid,
    )
    employee = _service._user_repo.get_by_uuid(db, body.utilisateur_uuid)
    employee_name = f"{employee.prenom} {employee.nom}" if employee else body.utilisateur_uuid
    _audit.log_face_enrolled(
        db,
        admin=admin,
        employee_uuid=body.utilisateur_uuid,
        employee_name=employee_name,
    )
    return SuccessResponse(
        data=FaceEnrollResponse(
            id=embedding.id,
            uuid=embedding.uuid,
            created_at=embedding.created_at,
            updated_at=embedding.updated_at,
            utilisateur_uuid=embedding.utilisateur_uuid,
            model_name=embedding.model_name,
            model_version=embedding.model_version,
            quality_score=embedding.quality_score,
            active=embedding.active,
            meal_registered=meal_registered,
        ),
    )


@router.post(
    "/verify",
    summary="Vérifier un utilisateur par son visage",
    description=(
        "Compare l'image fournie avec l'empreinte faciale stockée pour "
        "l'utilisateur spécifié.  Retourne un score de confiance et le "
        "statut de la correspondance."
    ),
    response_model=SuccessResponse[FaceVerifyResponse],
)
async def verify(
    body: FaceVerifyRequest,
    db: Session = Depends(get_db),
    _kiosk_identity: Admin | None = Depends(require_kiosk_access),
) -> SuccessResponse[FaceVerifyResponse]:
    """Verify a user by comparing against their stored embedding."""
    if _setting_service.get_runtime_value(db, "face_recognition_enabled", "true").lower() != "true":
        raise BusinessException(message="La reconnaissance faciale est désactivée.")
    result = _service.verify(
        db=db,
        image_base64=body.image_base64,
        user_uuid=body.utilisateur_uuid,
    )
    statut, confidence, user_uuid, nom, prenom, message = result
    return SuccessResponse(
        data=FaceVerifyResponse(
            statut=statut,
            confidence=confidence,
            utilisateur_uuid=user_uuid,
            nom=nom,
            prenom=prenom,
            message=message,
        ),
    )


@router.post(
    "/identify",
    summary="Identifier un utilisateur par son visage",
    description=(
        "Compare l'image fournie avec toutes les empreintes faciales "
        "actives du système et retourne l'utilisateur correspondant."
    ),
    response_model=SuccessResponse[FaceIdentifyResponse],
)
async def identify(
    body: FaceIdentifyRequest,
    db: Session = Depends(get_db),
    _kiosk_identity: Admin | None = Depends(require_kiosk_access),
) -> SuccessResponse[FaceIdentifyResponse]:
    """Identify a user by face against all stored embeddings."""
    if _setting_service.get_runtime_value(db, "face_recognition_enabled", "true").lower() != "true":
        raise BusinessException(message="La reconnaissance faciale est désactivée.")
    result = _service.identify(
        db=db,
        image_base64=body.image_base64,
    )
    statut, confidence, user_uuid, nom, prenom, user_type, message = result
    identification_token = None
    identification_expires_at = None
    if statut.value == "MATCH" and user_uuid:
        _meal_service.ensure_no_meal_today(db, user_uuid)
        grant, identification_token = _identification_service.issue(
            db,
            user_uuid=user_uuid,
            identification_type="FACE",
        )
        identification_expires_at = ensure_utc(grant.expires_at)
    return SuccessResponse(
        data=FaceIdentifyResponse(
            statut=statut,
            confidence=confidence,
            utilisateur_uuid=None,
            nom=None,
            prenom=None,
            type=user_type,
            message=message,
            identification_token=identification_token,
            identification_expires_at=identification_expires_at,
        ),
    )


@router.get(
    "/{uuid}",
    summary="Obtenir une empreinte faciale",
    response_model=SuccessResponse[FaceEmbeddingResponse],
)
async def get_embedding(
    uuid: str,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(require_admin),
) -> SuccessResponse[FaceEmbeddingResponse]:
    """Get face embedding metadata by UUID."""
    embedding = _service.get_by_uuid(db, uuid)
    return SuccessResponse(
        data=FaceEmbeddingResponse(
            id=embedding.id,
            uuid=embedding.uuid,
            created_at=embedding.created_at,
            updated_at=embedding.updated_at,
            utilisateur_uuid=embedding.utilisateur_uuid,
            model_name=embedding.model_name,
            model_version=embedding.model_version,
            quality_score=embedding.quality_score,
            active=embedding.active,
        ),
    )


@router.delete(
    "/user/{user_uuid}",
    summary="Supprimer les empreintes faciales d'un employé",
    description="Efface définitivement toutes les empreintes de l'employé.",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_user_embeddings(
    user_uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    """Permanently erase every biometric template owned by an employee."""
    employee = _service._user_repo.get_by_uuid(db, user_uuid)
    employee_name = f"{employee.prenom} {employee.nom}" if employee else user_uuid
    _service.delete_for_user(db, user_uuid)
    _audit.log_face_removed(
        db,
        admin=admin,
        employee_uuid=user_uuid,
        employee_name=employee_name,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.delete(
    "/{uuid}",
    summary="Supprimer une empreinte faciale",
    description="Supprime définitivement une empreinte faciale.",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_embedding(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    """Permanently delete a face embedding by UUID."""
    embedding = _service.get_by_uuid(db, uuid)
    employee = _service._user_repo.get_by_uuid(db, embedding.utilisateur_uuid)
    employee_name = f"{employee.prenom} {employee.nom}" if employee else embedding.utilisateur_uuid
    _service.delete_embedding(db, uuid)
    _audit.log_face_removed(
        db,
        admin=admin,
        employee_uuid=embedding.utilisateur_uuid,
        employee_name=employee_name,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/enroll-multiple",
    summary="Enrôler avec plusieurs images",
    description=(
        "Enrôle une empreinte faciale à partir de plusieurs images "
        "téléversées via multipart/form-data.  Chaque image est "
        "analysée et la meilleure est conservée."
    ),
    status_code=status.HTTP_201_CREATED,
)
async def enroll_multiple(
    utilisateur_uuid: str = Form(...),
    images: list[UploadFile] = File(..., min_length=3, max_length=5),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> SuccessResponse[dict[str, object]]:
    """Enroll a face using multiple uploaded images."""
    embeddings: list[FaceEmbedding] = []
    total_size = 0
    for image in images:
        if image.content_type not in {"image/jpeg", "image/png", "image/webp"}:
            raise ValidationException(
                message="Seules les images JPEG, PNG et WebP sont acceptées.",
            )
        content = await image.read()
        total_size += len(content)
        if len(content) > 5 * 1024 * 1024 or total_size > 20 * 1024 * 1024:
            raise ValidationException(
                message="Les images dépassent la taille autorisée.",
            )

        b64 = f"data:{image.content_type};base64," + base64.b64encode(content).decode("utf-8")
        embedding, _ = _service.enroll(
            db=db,
            image_base64=b64,
            user_uuid=utilisateur_uuid,
        )
        embeddings.append(embedding)
    employee = _service._user_repo.get_by_uuid(db, utilisateur_uuid)
    _audit.log_face_enrolled(
        db,
        admin=admin,
        employee_uuid=utilisateur_uuid,
        employee_name=(f"{employee.prenom} {employee.nom}" if employee else utilisateur_uuid),
    )
    return SuccessResponse(
        data={
            "utilisateur_uuid": utilisateur_uuid,
            "images_processed": len(embeddings),
            "active_embedding_uuid": embeddings[-1].uuid,
        },
    )
