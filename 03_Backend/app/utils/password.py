"""Password hashing and verification using bcrypt."""

import bcrypt


def hash_password(plain: str) -> str:
    """Hash a plain-text password with an auto-generated salt.

    The bcrypt cost factor is read from application settings; if the
    settings module is not yet initialized, a default of 12 is used.

    :param plain: The plain-text password (at least 8 characters).
    :returns: A bcrypt hash string suitable for storage in
        ``utilisateur.mot_de_passe``.
    """
    try:
        from app.core.config import (  # noqa: PLC0415 — lazy import avoids circular dependency
            settings,
        )

        rounds = settings.BCRYPT_ROUNDS
    except Exception:
        rounds = 12

    return bcrypt.hashpw(plain.encode("utf-8"), bcrypt.gensalt(rounds=rounds)).decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    """Verify a plain-text password against a bcrypt hash.

    :param plain: The plain-text password to check.
    :param hashed: The stored bcrypt hash (from
        ``utilisateur.mot_de_passe``).
    :returns: ``True`` if the password matches the hash.
    """
    return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))
