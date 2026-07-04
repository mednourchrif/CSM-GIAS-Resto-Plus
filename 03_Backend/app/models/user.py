"""User — central identity entity (``utilisateur``).

Business purpose
----------------
Every person interacting with CSM-GIAS Resto+ has exactly one row in the
``utilisateur`` table.  This is the **single source of truth** for identity
attributes shared across all profiles: name, email, password hash, status,
and preferred language.

Five sub-types exist, each stored in a dedicated extension table:

* ``Admin``        — full system administration
* ``Receptionist``  — visitor & intern registration
* ``Employee``      — permanent staff (face recognition)
* ``Intern``        — temporary staff (QR code)
* ``Visitor``       — one-day guests (QR code)

The ``type`` column is the **discriminator** that tells SQLAlchemy which
sub-class to materialise when a row is loaded.

Designed for
------------
- **Authentication** — ``mot_de_passe`` is checked during login (admin /
  reception only; null for other types per BR-004).
- **Audit** — ``uuid`` is exposed via API so audit trails reference
  stable, non-enumerable identifiers.
- **Localisation** — ``langue`` controls the UI language on the tablet.

Inheritance
-----------
``User`` inherits from ``BaseModel`` which provides:

* ``id``              — auto-increment integer primary key
* ``uuid``            — UUID v7 (time-ordered, index-friendly)
* ``created_at``      — row creation timestamp (UTC)
* ``updated_at``      — last-update timestamp (UTC)

See also
--------
``app.database.mixins.SoftDeleteMixin`` — the ``date_suppression`` column
plays the same role as ``deleted_at`` but is named to match the documented
schema conventions.
"""

from datetime import datetime
from enum import StrEnum

from sqlalchemy import DateTime
from sqlalchemy import Enum as SAEnum
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel

# ===========================================================================
# Enumerations
# ===========================================================================


class TypeUtilisateur(StrEnum):
    """Discriminator values for the ``utilisateur.type`` column.

    Each value corresponds to a concrete sub-class of ``User``.
    """

    EMPLOYE = "EMPLOYE"
    STAGIAIRE = "STAGIAIRE"
    VISITEUR = "VISITEUR"
    ADMINISTRATEUR = "ADMINISTRATEUR"
    RECEPTION = "RECEPTION"


class StatutUtilisateur(StrEnum):
    """Lifecycle status of a user account."""

    ACTIF = "ACTIF"
    INACTIF = "INACTIF"
    SUPPRIME = "SUPPRIME"


class Langue(StrEnum):
    """Supported UI languages for tablet notifications."""

    FR = "FR"
    AR = "AR"
    EN = "EN"


# ===========================================================================
# Base user entity
# ===========================================================================


class User(BaseModel):
    """A person registered in the restaurant management system.

    This is the **base table** for all user profiles.  Concrete sub-types
    (``Admin``, ``Employee``, etc.) add profile-specific columns via
    SQLAlchemy **joined table inheritance** — the discriminator ``type``
    column determines which sub-class is instantiated for a given row.
    """

    __tablename__ = "utilisateur"

    # -- Identity ----------------------------------------------------------

    nom: Mapped[str] = mapped_column(
        String(100),
        index=True,
    )

    prenom: Mapped[str] = mapped_column(
        String(100),
        index=True,
    )

    email: Mapped[str | None] = mapped_column(
        String(255),
        unique=True,
        index=True,
    )

    # -- Authentication ----------------------------------------------------

    mot_de_passe: Mapped[str | None] = mapped_column(
        String(255),
        default=None,
    )

    # -- Discriminator & status -------------------------------------------

    type: Mapped[TypeUtilisateur] = mapped_column(
        SAEnum(TypeUtilisateur),
    )

    statut: Mapped[StatutUtilisateur] = mapped_column(
        SAEnum(StatutUtilisateur),
        default=StatutUtilisateur.ACTIF,
        index=True,
    )

    # -- Preferences -------------------------------------------------------

    langue: Mapped[Langue | None] = mapped_column(
        SAEnum(Langue),
        default=None,
    )

    # -- Soft-delete -------------------------------------------------------

    date_suppression: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        default=None,
    )

    # -- Mapper ------------------------------------------------------------

    __mapper_args__ = {
        "polymorphic_on": "type",
        "polymorphic_identity": "utilisateur",
    }

    # -- Representation ----------------------------------------------------

    def __repr__(self) -> str:
        return (
            f"<User id={self.id} type={self.type} statut={self.statut} "
            f"nom={self.nom} prenom={self.prenom}>"
        )
