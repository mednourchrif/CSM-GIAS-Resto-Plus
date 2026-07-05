"""Meal — meal registration record (``repas``).

Business purpose
----------------
Every meal served in the restaurant is registered as a row in this table.
The record captures who ate, what they ate (category), how they identified
(QR code, future: face recognition), and when.

The pair ``(utilisateur_uuid, date_repas)`` has a **unique constraint**
enforced at the database level to guarantee the **one-meal-per-person-per-day**
rule.

Design for future identification
--------------------------------
When **Face Recognition** is implemented, the ``qr_uuid`` column will be
``NULL`` and ``type_identification`` will be ``"FACE"``.  The meal service
will receive the employee's UUID directly from the Face Recognition module
and call ``MealService.register_by_user_uuid()`` — no changes to this
model are required.
"""

from datetime import date, datetime, time

from sqlalchemy import Date, DateTime, ForeignKey, String, Time, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class Meal(BaseModel):
    __tablename__ = "repas"

    __table_args__ = (
        UniqueConstraint(
            "utilisateur_uuid",
            "date_repas",
            name="uq_repas_utilisateur_date",
        ),
    )

    utilisateur_uuid: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("utilisateur.uuid"),
        index=True,
    )

    qr_uuid: Mapped[str | None] = mapped_column(
        String(36),
        ForeignKey("qr_code.uuid"),
        default=None,
        index=True,
    )

    categorie_uuid: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("categorie_repas.uuid"),
        index=True,
    )

    type_identification: Mapped[str] = mapped_column(
        String(20),
        default="QR",
    )

    date_repas: Mapped[date] = mapped_column(
        Date,
        index=True,
    )

    heure_repas: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
    )

    enregistre_par_uuid: Mapped[str | None] = mapped_column(
        String(36),
        ForeignKey("utilisateur.uuid"),
        default=None,
    )

    def __repr__(self) -> str:
        return (
            f"<Meal id={self.id} user={self.utilisateur_uuid} "
            f"date={self.date_repas} categorie={self.categorie_uuid}>"
        )
