"""Employee — permanent staff (``employe`` extension).

Business purpose
----------------
Employees are the primary users of the restaurant system.  They identify
via **face recognition** (biometric enrollment), and can register **one
meal per day** during the lunch service (12:30–14:00).

Each employee has an HR ``matricule`` (employee number) which is unique
across all employees and used for payroll reconciliation.  The optional
``photo_path`` stores a file-system reference to the employee's portrait
for the enrollment screen.

The ``date_enrolement`` and ``statut_enrolement`` columns track the
biometric enrollment lifecycle:

1. ``NON_ENROLE`` — account created, no face vector stored yet.
2. ``ENROLE`` — face vector captured and encrypted; the employee can
   now use face recognition.
3. ``ENROLEMENT_ECHOUE`` — enrollment attempt failed; administration
   must re-trigger the process.

Designed for
------------
- **Face recognition** (future module) — queries ``statut_enrolement``
  to determine whether the employee can use face login; joins
  ``empreinte_biometrique`` for the encrypted face vector.
- **Meal registration** (future module) — validates daily uniqueness
  via a DB constraint on ``(utilisateur_id, date_repas)``.
- **Reports & statistics** (future module) — aggregates meal data
  grouped by employee department, enrollment status, etc.

See also
--------
``app.models.user.User`` — base table providing ``nom``, ``prenom``,
``email``, ``statut`` (account active/inactive), and all ``BaseModel``
columns.
"""

from datetime import datetime
from enum import StrEnum

from sqlalchemy import DateTime
from sqlalchemy import Enum as SAEnum
from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.user import User


class StatutEnrolement(StrEnum):
    """Biometric enrollment status for an employee."""

    NON_ENROLE = "NON_ENROLE"
    ENROLE = "ENROLE"
    ENROLEMENT_ECHOUE = "ENROLEMENT_ECHOUE"


class Employee(User):
    """A permanent employee who uses face recognition for meal registration.

    Extends ``utilisateur`` with HR and biometric-enrollment columns.
    """

    __tablename__ = "employe"

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

    # -- Portrait reference -----------------------------------------------

    photo_path: Mapped[str | None] = mapped_column(
        String(500),
        default=None,
    )

    # -- Biometric enrollment ---------------------------------------------

    date_enrolement: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        default=None,
    )

    statut_enrolement: Mapped[StatutEnrolement] = mapped_column(
        SAEnum(StatutEnrolement),
        default=StatutEnrolement.NON_ENROLE,
        index=True,
    )

    # -- Mapper ------------------------------------------------------------

    __mapper_args__ = {
        "polymorphic_identity": "EMPLOYE",
    }

    # -- Representation ----------------------------------------------------

    def __repr__(self) -> str:
        return (
            f"<Employee id={self.id} matricule={self.matricule} "
            f"enrolement={self.statut_enrolement}>"
        )
