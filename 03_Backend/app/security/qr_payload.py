"""Authenticated encryption for persisted QR-code images."""

import base64
import hashlib

from cryptography.fernet import Fernet, InvalidToken

from app.core.config import BaseAppSettings, settings
from app.core.exceptions import ConfigurationException

_FORMAT_PREFIX = "fernet:v1:"


class QrPayloadCipher:
    """Protect QR images so a database-only leak does not reveal tokens."""

    def __init__(self, config: BaseAppSettings = settings) -> None:
        digest = hashlib.sha256(f"qr-payload:{config.APP_SECRET_KEY}".encode()).digest()
        self._fernet = Fernet(base64.urlsafe_b64encode(digest))

    def encrypt(self, payload: str) -> str:
        return _FORMAT_PREFIX + self._fernet.encrypt(payload.encode("utf-8")).decode("ascii")

    def decrypt(self, stored: str) -> str:
        """Decrypt current records and accept legacy data URIs."""
        if not stored.startswith(_FORMAT_PREFIX):
            return stored
        try:
            decrypted = self._fernet.decrypt(stored.removeprefix(_FORMAT_PREFIX).encode("ascii"))
        except InvalidToken as exc:
            raise ConfigurationException(
                message="Impossible de déchiffrer l'image du QR code.",
            ) from exc
        return decrypted.decode("utf-8")
