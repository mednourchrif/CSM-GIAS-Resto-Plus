"""Signed, non-sensitive QR payloads for receipt verification."""

import hashlib
import hmac

from app.core.config import get_settings


def make_receipt_token(receipt_uuid: str, number: str) -> str:
    value = f"{receipt_uuid}|{number}"
    secret = get_settings().APP_SECRET_KEY.encode("utf-8")
    signature = hmac.new(secret, value.encode("utf-8"), hashlib.sha256).hexdigest()
    return f"RCP1|{receipt_uuid}|{number}|{signature}"


def parse_receipt_token(token: str) -> tuple[str, str] | None:
    parts = token.split("|")
    if len(parts) != 4 or parts[0] != "RCP1":
        return None
    _, receipt_uuid, number, signature = parts
    expected = make_receipt_token(receipt_uuid, number).rsplit("|", 1)[1]
    if not hmac.compare_digest(signature, expected):
        return None
    return receipt_uuid, number
