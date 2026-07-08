"""Face recognition API endpoints — enrollment, verification, and identification.

Endpoints
---------
* ``POST /api/v1/face/enroll``   — Enroll a face for a user (admin only).
* ``POST /api/v1/face/verify``   — Verify a user by face (public — kiosk).
* ``POST /api/v1/face/identify`` — Identify a user by face (public — kiosk).
* ``GET  /api/v1/face/{uuid}``   — Get face embedding metadata (public — kiosk).
* ``DELETE /api/v1/face/{uuid}`` — Soft-delete a face embedding (admin only).


Design
------
The verify and identify endpoints accept an optional ``categorie_uuid``.
When provided, a meal is registered automatically after a successful
match — this integrates with the existing meal registration system
without leaking face-recognition knowledge into :class:`MealService`.
"""

from fastapi import APIRouter, Depends, File, Form, Response, UploadFile, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
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
from app.security.dependencies import require_admin
from app.services.audit_service import AuditLogService
from app.services.face_service import FaceService

router = APIRouter(prefix="/face", tags=["face"])

_service = FaceService()
_audit = AuditLogService()


@router.post(
    "/enroll",
    summary="Enrôler une empreinte faciale",
    description=(
        "Enrôle une empreinte faciale pour un utilisateur.  Si "
        "``categorie_uuid`` est fourni, un repas est automatiquement "
        "enregistré après l'enrôlement."
    ),
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
        categorie_uuid=body.categorie_uuid,
    )
    employee = _service._user_repo.get_by_uuid(db, body.utilisateur_uuid)
    employee_name = f"{employee.prenom} {employee.nom}" if employee else body.utilisateur_uuid
    _audit.log_face_enrolled(
        db, admin=admin,
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
) -> SuccessResponse[FaceVerifyResponse]:
    """Verify a user by comparing against their stored embedding."""
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
) -> SuccessResponse[FaceIdentifyResponse]:
    """Identify a user by face against all stored embeddings."""
    result = _service.identify(
        db=db,
        image_base64=body.image_base64,
    )
    statut, confidence, user_uuid, nom, prenom, user_type, message = result
    return SuccessResponse(
        data=FaceIdentifyResponse(
            statut=statut,
            confidence=confidence,
            utilisateur_uuid=user_uuid,
            nom=nom,
            prenom=prenom,
            type=user_type,
            message=message,
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
    "/{uuid}",
    summary="Supprimer une empreinte faciale",
    description="Désactive une empreinte faciale (soft-delete).",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_embedding(
    uuid: str,
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
) -> Response:
    """Soft-delete a face embedding by UUID."""
    embedding = _service.get_by_uuid(db, uuid)
    employee = _service._user_repo.get_by_uuid(db, embedding.utilisateur_uuid)
    employee_name = f"{employee.prenom} {employee.nom}" if employee else embedding.utilisateur_uuid
    _service.delete_embedding(db, uuid)
    _audit.log_face_removed(
        db, admin=admin,
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
    images: list[UploadFile] = File(..., min_length=5, max_length=10),
    db: Session = Depends(get_db),
    admin: Admin = Depends(require_admin),
):
    """Enroll a face using multiple uploaded images."""
    embeddings = []
    for image in images:
        content = await image.read()
        import base64
        mime_type = image.content_type or "image/png"

        b64 = (
            f"data:{image.content_type};base64,"
            + base64.b64encode(content).decode("utf-8")
        )
        embedding, _ = _service.enroll(
            db=db,
            image_base64=b64,
            user_uuid=utilisateur_uuid,
        )
        embeddings.append(embedding)
    return SuccessResponse(
        data={
            "utilisateur_uuid": utilisateur_uuid,
            "images_processed": len(embeddings),
            "active_embedding_uuid": embeddings[-1].uuid,
        },
    )
