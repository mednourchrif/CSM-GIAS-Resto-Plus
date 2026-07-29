"""Image utility functions — encoding, decoding, and validation.

All face images flow through these helpers so that validation (format,
size, dimension limits) is enforced in a single place before any
AI processing occurs.
"""

import base64
import binascii
import re
from io import BytesIO

from PIL import Image, UnidentifiedImageError

from app.core.exceptions import ValidationException

_DATA_URI_PATTERN = re.compile(r"^data:image/(png|jpeg|webp);base64,(.+)$")
_MAX_IMAGE_BYTES = 5 * 1024 * 1024


def decode_base64_image(data_uri: str) -> Image.Image:
    """Decode a base64 data URI to a PIL ``Image``.

    :param data_uri: A data URI string such as
        ``data:image/png;base64,iVBORw0KGgo…``.
    :returns: An RGB PIL Image.
    :raises ValidationException: If the URI format is invalid.
    """
    match = _DATA_URI_PATTERN.match(data_uri.strip())
    if not match:
        raise ValidationException(
            message=("Format d'image invalide. " "Utilisez data:image/png;base64,..."),
        )
    encoded = match.group(2)
    if len(encoded) > ((_MAX_IMAGE_BYTES * 4) // 3) + 4:
        raise ValidationException(
            message="L'image dépasse la taille maximale de 5 Mo.",
        )
    try:
        raw = base64.b64decode(encoded, validate=True)
        if len(raw) > _MAX_IMAGE_BYTES:
            raise ValidationException(
                message="L'image dépasse la taille maximale de 5 Mo.",
            )
        with Image.open(BytesIO(raw)) as source:
            source.verify()
        with Image.open(BytesIO(raw)) as source:
            return source.convert("RGB")
    except ValidationException:
        raise
    except (binascii.Error, ValueError, UnidentifiedImageError) as exc:
        raise ValidationException(
            message="Le contenu de l'image est invalide.",
        ) from exc


def validate_image_format(image: Image.Image) -> None:
    """Validate image dimensions.

    Enforces minimum 100×100 and maximum 4096×4096 pixel limits.

    :param image: PIL Image to validate.
    :raises ValidationException: If dimensions are out of range.
    """
    if image.width < 100 or image.height < 100:
        raise ValidationException(
            message="L'image est trop petite (minimum 100x100 pixels).",
            details={"width": image.width, "height": image.height},
        )
    if image.width > 4096 or image.height > 4096:
        raise ValidationException(
            message="L'image est trop grande (maximum 4096x4096 pixels).",
            details={"width": image.width, "height": image.height},
        )
