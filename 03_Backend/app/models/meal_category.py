"""MealCategory — static meal categories (``categorie_repas``).

Three categories exist by default: ``Plat``, ``Pizza``, ``Sandwich``.
These are seeded once and never change through the API.
"""

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class MealCategory(BaseModel):
    __tablename__ = "categorie_repas"

    nom: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        index=True,
    )

    description: Mapped[str | None] = mapped_column(
        String(255),
        default=None,
    )

    def __repr__(self) -> str:
        return f"<MealCategory id={self.id} nom={self.nom}>"
