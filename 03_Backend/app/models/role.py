"""Role — hierarchical access levels for administration.

Business purpose
----------------
Roles define fine-grained access permissions *within* the administration
module.  Unlike the ``type`` discriminator on ``utilisateur`` (which
separates employee / intern / visitor / admin / reception at the domain
level), ``role`` distinguishes *operational tiers* inside the admin
interface — e.g. super-admin, restaurant-manager, auditor.

The separation between ``type`` and ``role`` allows the system to evolve
without schema changes: new roles can be added at runtime without
altering the ``utilisateur.type`` enum.

Designed for
------------
- Authorization middleware (future module) will check ``role`` before
  granting access to admin endpoints.
- The UI will filter available screens based on the current admin's role.

See also
--------
``app.models.admin.Admin.role`` — many-to-one back-reference.
"""

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import BaseModel


class Role(BaseModel):
    """An operational tier within the administration interface.

    One ``Role`` can be assigned to many ``Admin`` accounts.
    """

    __tablename__ = "role"

    # ------------------------------------------------------------------
    # Columns
    # ------------------------------------------------------------------

    nom: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        index=True,
    )

    description: Mapped[str | None] = mapped_column(
        String(255),
        default=None,
    )

    actif: Mapped[bool] = mapped_column(
        default=True,
    )

    # ------------------------------------------------------------------
    # Relationships
    # ------------------------------------------------------------------

    administrateurs: Mapped[list["Admin"]] = relationship(  # noqa: F821
        back_populates="role",
    )

    # ------------------------------------------------------------------
    # Representation
    # ------------------------------------------------------------------

    def __repr__(self) -> str:
        return f"<Role id={self.id} nom={self.nom} actif={self.actif}>"
