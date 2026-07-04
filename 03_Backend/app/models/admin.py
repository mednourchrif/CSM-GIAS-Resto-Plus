"""Admin & Receptionist — administration user extensions.

Business purpose
----------------
**Admin** (``administrateur``) users have full system access: user
management, configuration, QR-code generation, report scheduling, and
biometric enrollment.  An admin is always linked to a ``Role`` which
defines their operational tier (e.g. super-admin, manager, auditor).

**Receptionist** (``reception``) users have limited rights: they can
create intern and visitor accounts and generate their QR codes, but
cannot access configuration or reports.

Both types inherit ``nom``, ``prenom``, ``email``, ``mot_de_passe``
and all ``BaseModel`` columns from the parent ``utilisateur`` table.

Designed for
------------
- **Authentication** (future module) — ``tentatives_echouees`` tracks
  failed login attempts; ``derniere_connexion`` records the last
  successful login for audit.
- **Authorization** (future module) — ``role`` gates access to admin
  endpoints; ``Receptionist`` type gates access to visitor/intern
  creation screens.
- **Audit** (future module) — every destructive action records the
  acting admin's ``id`` from the ``utilisateur`` base.

See also
--------
``app.models.role.Role`` — the role assigned to an admin.
"""

from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, SmallInteger
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.user import User


class Admin(User):
    """A user with full administration privileges.

    Extends ``utilisateur`` with session-tracking columns and a
    foreign key to ``role``.
    """

    __tablename__ = "administrateur"

    # -- Primary key (shared with utilisateur) ----------------------------

    id: Mapped[int] = mapped_column(
        ForeignKey("utilisateur.id", ondelete="CASCADE"),
        primary_key=True,
    )

    # -- Role reference ---------------------------------------------------

    role_id: Mapped[int | None] = mapped_column(
        ForeignKey("role.id", ondelete="SET NULL"),
        index=True,
        default=None,
    )

    # -- Session tracking -------------------------------------------------

    derniere_connexion: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        default=None,
    )

    tentatives_echouees: Mapped[int] = mapped_column(
        SmallInteger,
        default=0,
    )

    # -- Relationships ----------------------------------------------------

    role: Mapped["Role | None"] = relationship(  # noqa: F821
        back_populates="administrateurs",
    )

    # -- Mapper ------------------------------------------------------------

    __mapper_args__ = {
        "polymorphic_identity": "ADMINISTRATEUR",
    }

    # -- Representation ----------------------------------------------------

    def __repr__(self) -> str:
        return f"<Admin id={self.id} nom={self.nom} prenom={self.prenom}>"


class Receptionist(User):
    """A user with reception privileges (intern & visitor registration only).

    The extension table is minimal because receptionists do not require
    additional profile-specific columns beyond those provided by
    ``utilisateur``.
    """

    __tablename__ = "reception"

    # -- Primary key (shared with utilisateur) ----------------------------

    id: Mapped[int] = mapped_column(
        ForeignKey("utilisateur.id", ondelete="CASCADE"),
        primary_key=True,
    )

    # -- Mapper ------------------------------------------------------------

    __mapper_args__ = {
        "polymorphic_identity": "RECEPTION",
    }

    # -- Representation ----------------------------------------------------

    def __repr__(self) -> str:
        return f"<Receptionist id={self.id} nom={self.nom} prenom={self.prenom}>"
