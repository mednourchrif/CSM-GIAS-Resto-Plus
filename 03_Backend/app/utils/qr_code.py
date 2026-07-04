"""QR code generation utilities.

Provides:
* ``generate_token()`` — cryptographically secure URL-safe token.
* ``hash_token()`` — SHA-256 hash for database storage.
* ``generate_qr_image()`` — PNG image bytes from a token.
* ``generate_qr_base64()`` — Base64-encoded PNG data URI.
"""

import base64
import hashlib
import io
import secrets

import qrcode


def generate_token(byte_length: int = 48) -> str:
    """Generate a cryptographically secure, URL-safe token.

    Uses ``secrets.token_urlsafe`` which produces a base64-encoded string
    with ``byte_length`` bytes of entropy (default 48 → 64 chars).

    The token is:
    * **Unique** — 384 bits of randomness makes collisions negligible.
    * **Unpredictable** — backed by the OS CSPRNG.
    * **URL-safe** — only ``[A-Za-z0-9_-]`` characters.
    """
    return secrets.token_urlsafe(byte_length)


def hash_token(token: str) -> str:
    """Return the SHA-256 hex digest of *token*.

    The raw token is never stored in the database.  Only the hash is
    persisted, so a DB compromise does not leak valid QR tokens.
    """
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def generate_qr_image(token: str, box_size: int = 10, border: int = 4) -> bytes:
    """Generate a QR code PNG image for the given *token*.

    :param token: The raw QR token to encode.
    :param box_size: Size of each QR module (pixels).
    :param border: Width of the quiet zone (modules).
    :returns: PNG image bytes.
    """
    qr = qrcode.QRCode(box_size=box_size, border=border)
    qr.add_data(token)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")

    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


def generate_qr_base64(token: str, box_size: int = 10, border: int = 4) -> str:
    """Generate a Base64-encoded data URI of the QR PNG image.

    Suitable for embedding in JSON responses or ``<img>`` tags::

        data:image/png;base64,iVBORw0K...
    """
    png_bytes = generate_qr_image(token, box_size=box_size, border=border)
    b64 = base64.b64encode(png_bytes).decode("ascii")
    return f"data:image/png;base64,{b64}"
