"""Visitor — one-day guest (``visiteur`` extension).

Business purpose
----------------
Visitors are external guests who need temporary access to the restaurant.
They receive a **temporary QR code** that expires at ``23:59`` on their
``date_visite`` (BR-019, BR-024).

Key business rules enforced at the application layer (future module):

* A visitor cannot have multiple active QR codes for the same visit date.
* QR codes are single-use per meal registration.
* Only the reception or an admin can create visitor accounts.

Designed for
------------
- **QR-code generation** (future module) — reads ``date_visite`` to
  set the QR code's expiration timestamp.
- **Meal registration** (future module) — validates account status and
  visit date before allowing meal selection.
- **Reporting** (future module) — distinguishes visitor meals from
  employee / intern meals in daily statistics.

See also
--------
``app.models.user.User`` — base table providing ``nom``, ``prenom``,
``email``, ``statut``.
"""

from datetime import date

from sqlalchemy import Date, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.user import User


class Visitor(User):
    """A one-day guest who uses a temporary QR code.

    Extends ``utilisateur`` with visit date and company name.
    """

    __tablename__ = "visiteur"

    # -- Primary key (shared with utilisateur) ----------------------------

    id: Mapped[int] = mapped_column(
        ForeignKey("utilisateur.id", ondelete="CASCADE"),
        primary_key=True,
    )

    # -- Company name ------------------------------------------------------

    societe: Mapped[str | None] = mapped_column(
        String(255),
        default=None,
    )

    # -- Visit date --------------------------------------------------------

    date_visite: Mapped[date] = mapped_column(
        Date,
        index=True,
    )

    # -- Mapper ------------------------------------------------------------

    __mapper_args__ = {
        "polymorphic_identity": "VISITEUR",
    }

    # -- Representation ----------------------------------------------------

    def __repr__(self) -> str:
        return (
            f"<Visitor id={self.id} nom={self.nom} prenom={self.prenom} "
            f"visite={self.date_visite}>"
        )
