"""Administrative receipt history and print audit endpoints."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.models.admin import Admin
from app.models.receipt import Receipt
from app.schemas.receipt import ReceiptFilterParams, ReceiptQrRequest, ReceiptResponse
from app.schemas.response import PaginatedResponse, SuccessResponse
from app.security.dependencies import require_admin, require_kiosk_access
from app.services.receipt_service import ReceiptService
from app.utils.receipt_qr import make_receipt_token, parse_receipt_token
from app.core.exceptions import BusinessException

router = APIRouter(prefix="/receipts", tags=["receipts"])
_service = ReceiptService()


def _response(receipt: Receipt) -> ReceiptResponse:
    return ReceiptResponse.model_validate(receipt, from_attributes=True).model_copy(
        update={"qr_token": make_receipt_token(receipt.uuid, receipt.numero)}
    )


@router.get("", response_model=PaginatedResponse[ReceiptResponse])
async def list_receipts(
    params: ReceiptFilterParams = Depends(),
    db: Session = Depends(get_db),
    _admin: Admin = Depends(require_admin),
) -> PaginatedResponse[ReceiptResponse]:
    result = _service.list(db, params)
    return PaginatedResponse(
        data=[_response(item) for item in result.items],
        total=result.total,
        page=result.page,
        page_size=result.page_size,
        total_pages=result.total_pages,
    )


@router.get("/{uuid}", response_model=SuccessResponse[ReceiptResponse])
async def get_receipt(
    uuid: str,
    db: Session = Depends(get_db),
    _admin: Admin = Depends(require_admin),
) -> SuccessResponse[ReceiptResponse]:
    return SuccessResponse(data=_response(_service.get(db, uuid)))


@router.post("/scan", response_model=SuccessResponse[ReceiptResponse])
async def scan_receipt_qr(
    body: ReceiptQrRequest,
    db: Session = Depends(get_db),
    _kiosk_identity: Admin | None = Depends(require_kiosk_access),
) -> SuccessResponse[ReceiptResponse]:
    parsed = parse_receipt_token(body.token)
    if parsed is None:
        raise BusinessException(message="QR de reçu invalide.")
    receipt_uuid, number = parsed
    receipt = _service.get(db, receipt_uuid)
    if receipt.numero != number:
        raise BusinessException(message="QR de reçu invalide.")
    return SuccessResponse(data=_response(receipt))


@router.post("/{uuid}/printed", response_model=SuccessResponse[ReceiptResponse])
async def record_receipt_print(
    uuid: str,
    db: Session = Depends(get_db),
    _kiosk_identity: Admin | None = Depends(require_kiosk_access),
) -> SuccessResponse[ReceiptResponse]:
    return SuccessResponse(data=_response(_service.record_print(db, uuid)))
