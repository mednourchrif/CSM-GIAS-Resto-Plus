"""Encryption boundary for biometric templates stored in the database."""

import base64
import hashlib

from cryptography.fernet import Fernet, InvalidToken

from app.core.config import BaseAppSettings, settings
from app.core.exceptions import ConfigurationException

_FORMAT_PREFIX = b"fernet:v1:"


class BiometricCipher:
    """Encrypt and decrypt face embeddings with authenticated encryption.

    Development falls back to a key derived from ``APP_SECRET_KEY`` so older
    local environments keep working. Production configuration requires a
    dedicated Fernet key.
    """

    def __init__(self, config: BaseAppSettings = settings) -> None:
        configured_key = config.BIOMETRIC_ENCRYPTION_KEY.strip()
        if configured_key:
            key = configured_key.encode("ascii")
        elif config.is_production:
            raise ConfigurationException(
                message="BIOMETRIC_ENCRYPTION_KEY is required in production.",
            )
        else:
            digest = hashlib.sha256(config.APP_SECRET_KEY.encode("utf-8")).digest()
            key = base64.urlsafe_b64encode(digest)

        try:
            self._fernet = Fernet(key)
        except (ValueError, TypeError) as exc:
            raise ConfigurationException(
                message="BIOMETRIC_ENCRYPTION_KEY is not a valid Fernet key.",
            ) from exc

    def encrypt(self, embedding: bytes) -> bytes:
        """Return a versioned, authenticated ciphertext."""
        return _FORMAT_PREFIX + self._fernet.encrypt(embedding)

    @staticmethod
    def is_encrypted(stored: bytes) -> bool:
        """Return whether a stored template uses the current protected format."""
        return stored.startswith(_FORMAT_PREFIX)

    def decrypt(self, stored: bytes) -> bytes:
        """Decrypt a template, accepting legacy raw vectors for migration."""
        if not stored.startswith(_FORMAT_PREFIX):
            return stored
        try:
            return self._fernet.decrypt(stored[len(_FORMAT_PREFIX) :])
        except InvalidToken as exc:
            raise ConfigurationException(
                message="Impossible de déchiffrer l'empreinte biométrique.",
            ) from exc
