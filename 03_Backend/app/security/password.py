"""Password operations — hashing, verification, and strength validation.

This module wraps the low-level ``app.utils.password`` helpers and adds
business-level validation rules on top.

Business rules enforced
-----------------------
* Minimum length: 8 characters (``MIN_PASSWORD_LENGTH``).
* Maximum length: 128 characters (``MAX_PASSWORD_LENGTH``).
* At least one uppercase letter.
* At least one lowercase letter.
* At least one digit.
* At least one special character (``!@#$%^&*(),.?\":{}|<>_~-``).
"""

import re

from app.core.constants import MAX_PASSWORD_LENGTH, MIN_PASSWORD_LENGTH
from app.utils.password import hash_password as _hash
from app.utils.password import verify_password as _verify

# Characters considered "special" for password strength checks
_SPECIAL_CHARS = re.compile(r"[!@#$%^&*(),.?\":{}|<>_~\-]")


class PasswordService:
    """Password hashing, verification, and policy enforcement."""

    @staticmethod
    def hash(plain: str) -> str:
        """Hash a plain-text password using bcrypt.

        :param plain: The raw password string.
        :returns: A bcrypt hash string.
        """
        return _hash(plain)

    @staticmethod
    def verify(plain: str, hashed: str) -> bool:
        """Check a plain-text password against a stored bcrypt hash.

        Uses **constant-time comparison** via ``bcrypt.checkpw`` to
        prevent timing attacks.

        :param plain: The raw password to check.
        :param hashed: The stored bcrypt hash.
        :returns: ``True`` if the password matches.
        """
        return _verify(plain, hashed)

    @staticmethod
    def validate_strength(password: str) -> tuple[bool, str]:
        """Validate password strength against business rules.

        :param password: The password to validate.
        :returns: A tuple of ``(is_valid, message)``.  When ``is_valid``
            is ``True`` the message is empty.
        """
        errors: list[str] = []

        if len(password) < MIN_PASSWORD_LENGTH:
            errors.append(
                f"Le mot de passe doit contenir au moins {MIN_PASSWORD_LENGTH} caractères."
            )

        if len(password) > MAX_PASSWORD_LENGTH:
            errors.append(
                f"Le mot de passe doit contenir au maximum {MAX_PASSWORD_LENGTH} caractères."
            )

        if not re.search(r"[A-Z]", password):
            errors.append("Le mot de passe doit contenir au moins une lettre majuscule.")

        if not re.search(r"[a-z]", password):
            errors.append("Le mot de passe doit contenir au moins une lettre minuscule.")

        if not re.search(r"\d", password):
            errors.append("Le mot de passe doit contenir au moins un chiffre.")

        if not _SPECIAL_CHARS.search(password):
            errors.append("Le mot de passe doit contenir au moins un caractère spécial.")

        if errors:
            return False, " ".join(errors)

        return True, ""
