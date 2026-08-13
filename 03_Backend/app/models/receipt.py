"""Immutable meal receipt snapshot used for printing and audit history."""

from datetime import date, datetime

from sqlalchemy import Date, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import BaseModel


class Receipt(BaseModel):
    __tablename__ = "recu"

    numero: Mapped[str] = mapped_column(String(40), unique=True, index=True)
    repas_uuid: Mapped[str] = mapped_column(
        String(36), ForeignKey("repas.uuid", ondelete="RESTRICT"), unique=True, index=True
    )
    utilisateur_uuid: Mapped[str] = mapped_column(
        String(36), ForeignKey("utilisateur.uuid", ondelete="RESTRICT"), index=True
    )
    nom: Mapped[str] = mapped_column(String(100), index=True)
    prenom: Mapped[str] = mapped_column(String(100), index=True)
    matricule: Mapped[str | None] = mapped_column(String(20), index=True, default=None)
    type_utilisateur: Mapped[str] = mapped_column(String(20), index=True)
    categorie_uuid: Mapped[str] = mapped_column(String(36), index=True)
    categorie_nom: Mapped[str] = mapped_column(String(100), index=True)
    type_identification: Mapped[str] = mapped_column(String(20), index=True)
    date_repas: Mapped[date] = mapped_column(Date, index=True)
    heure_repas: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    nombre_impressions: Mapped[int] = mapped_column(Integer, default=0)
    derniere_impression: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), default=None
    )
    qr_token_hash: Mapped[str | None] = mapped_column(String(64), unique=True, index=True)
