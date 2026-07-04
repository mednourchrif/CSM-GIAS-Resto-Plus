"""Intern — temporary staff (``stagiaire`` extension).

Business purpose
----------------
Interns have temporary contracts.  They identify via a **nominative QR
code** whose validity is tied to their internship period: the QR code
expires at ``23:59`` on ``date_fin_stage`` (BR-016, BR-018).

Internship dates are mandatory because they determine:

* The QR-code expiration date.
* Eligibility windows for meal registration.
* Automated account deactivation after the internship ends.

Designed for
------------
- **QR-code generation** (future module) — reads ``date_fin_stage``
  to set the ``qr_code.date_expiration`` column.
- **Meal registration** (future module) — validates that the intern's
  account is ``ACTIF`` and the current date falls within the internship
  period.
- **Reporting** (future module) — counts intern meal consumption
  separately from employee consumption.

See also
--------
``app.models.user.User`` — base table providing ``nom``, ``prenom``,
``email``, ``statut``.
"""

from datetime import date

from sqlalchemy import Date, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.user import User


class Intern(User):
    """A temporary staff member who uses a nominative QR code.

    Extends ``utilisateur`` with internship period columns and an HR
    matricule.
    """

    __tablename__ = "stagiaire"

    # -- Primary key (shared with utilisateur) ----------------------------

    id: Mapped[int] = mapped_column(
        ForeignKey("utilisateur.id", ondelete="CASCADE"),
        primary_key=True,
    )

    # -- HR identifier -----------------------------------------------------

    matricule: Mapped[str] = mapped_column(
        String(20),
        unique=True,
        index=True,
    )

    # -- Internship period ------------------------------------------------

    date_debut_stage: Mapped[date] = mapped_column(
        Date,
    )

    date_fin_stage: Mapped[date] = mapped_column(
        Date,
        index=True,
    )

    # -- Mapper ------------------------------------------------------------

    __mapper_args__ = {
        "polymorphic_identity": "STAGIAIRE",
    }

    # -- Representation ----------------------------------------------------

    def __repr__(self) -> str:
        return (
            f"<Intern id={self.id} matricule={self.matricule} "
            f"stage={self.date_debut_stage}→{self.date_fin_stage}>"
        )
