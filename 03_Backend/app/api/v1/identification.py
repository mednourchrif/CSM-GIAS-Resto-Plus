"""Kiosk identification endpoints."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.core.exceptions import BusinessException
from app.models.admin import Admin
from app.schemas.identification import (
    IdentificationGrantResponse,
    QrIdentificationRequest,
)
from app.schemas.qr_code import ValidationStatut
from app.schemas.response import SuccessResponse
from app.security.dependencies import require_kiosk_access
from app.services.identification_service import IdentificationService
from app.services.meal_service import MealService
from app.services.qr_code_service import QrCodeService
from app.services.setting_service import SettingService
from app.utils.date_utils import ensure_utc

router = APIRouter(prefix="/identification", tags=["identification"])

_identification_service = IdentificationService()
_meal_service = MealService()
_qr_service = QrCodeService()
_setting_service = SettingService()


@router.post(
    "/qr",
    response_model=SuccessResponse[IdentificationGrantResponse],
)
async def identify_by_qr(
    body: QrIdentificationRequest,
    db: Session = Depends(get_db),
    _kiosk_identity: Admin | None = Depends(require_kiosk_access),
) -> SuccessResponse[IdentificationGrantResponse]:
    if _setting_service.get_runtime_value(db, "qr_validation_enabled", "true").lower() != "true":
        raise BusinessException(message="L'identification par QR Code est désactivée.")
    validation = _qr_service.validate(db, body.token)
    if validation.statut != ValidationStatut.VALID or validation.proprietaire_uuid is None:
        raise BusinessException(
            message=validation.message or "QR code invalide.",
        )
    _meal_service.ensure_no_meal_today(db, validation.proprietaire_uuid)
    grant, raw_token = _identification_service.issue(
        db,
        user_uuid=validation.proprietaire_uuid,
        identification_type="QR",
        qr_uuid=validation.qr_uuid,
    )
    return SuccessResponse(
        data=IdentificationGrantResponse(
            identification_token=raw_token,
            identification_type=grant.identification_type,
            expires_at=ensure_utc(grant.expires_at),
        ),
    )
