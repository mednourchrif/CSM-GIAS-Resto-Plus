"""QrCode — QR code entity (``qr_code``).

Business purpose
----------------
QR codes are the primary identification mechanism for interns and visitors.
Each QR code has a status lifecycle: ``ACTIF`` → ``EXPIRE`` / ``REVOQUE``.

* Interns get one active QR code that expires on their internship end date.
* Visitors get one QR code that expires at 23:59 on their visit date.
* Employees never receive QR codes — they use Face Recognition.

Every QR code stores a **SHA-256 hash** of the raw token, so the database
never holds the plaintext token.  The raw token is returned only at
generation time and is embedded in the PNG image.
"""

from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class QrCode(BaseModel):
    __tablename__ = "qr_code"

    qr_hash: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        index=True,
    )

    proprietaire_uuid: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("utilisateur.uuid"),
        index=True,
    )

    type_proprietaire: Mapped[str] = mapped_column(String(20))

    statut: Mapped[str] = mapped_column(
        String(20),
        default="ACTIF",
        index=True,
    )

    date_expiration: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
    )

    cree_par_uuid: Mapped[str | None] = mapped_column(
        String(36),
        ForeignKey("utilisateur.uuid"),
        default=None,
    )

    date_revocation: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        default=None,
    )

    revoque_par_uuid: Mapped[str | None] = mapped_column(
        String(36),
        ForeignKey("utilisateur.uuid"),
        default=None,
    )

    motif_revocation: Mapped[str | None] = mapped_column(
        String(100),
        default=None,
    )

    derniere_validation: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        default=None,
    )

    nombre_validations: Mapped[int] = mapped_column(
        default=0,
    )

    metadata_json: Mapped[str | None] = mapped_column(
        Text,
        default=None,
    )

    def __repr__(self) -> str:
        return (
            f"<QrCode id={self.id} statut={self.statut} "
            f"proprietaire={self.proprietaire_uuid} type={self.type_proprietaire}>"
        )
