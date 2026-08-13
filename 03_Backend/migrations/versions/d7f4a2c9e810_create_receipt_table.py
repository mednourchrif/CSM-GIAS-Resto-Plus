"""create receipt table

Revision ID: d7f4a2c9e810
Revises: b4d62f9c31a8
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "d7f4a2c9e810"
down_revision: str | None = "b4d62f9c31a8"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "recu",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("uuid", sa.String(length=36), nullable=False),
        sa.Column("numero", sa.String(length=40), nullable=False),
        sa.Column("repas_uuid", sa.String(length=36), nullable=False),
        sa.Column("utilisateur_uuid", sa.String(length=36), nullable=False),
        sa.Column("nom", sa.String(length=100), nullable=False),
        sa.Column("prenom", sa.String(length=100), nullable=False),
        sa.Column("matricule", sa.String(length=20), nullable=True),
        sa.Column("type_utilisateur", sa.String(length=20), nullable=False),
        sa.Column("categorie_uuid", sa.String(length=36), nullable=False),
        sa.Column("categorie_nom", sa.String(length=100), nullable=False),
        sa.Column("type_identification", sa.String(length=20), nullable=False),
        sa.Column("date_repas", sa.Date(), nullable=False),
        sa.Column("heure_repas", sa.DateTime(timezone=True), nullable=False),
        sa.Column("nombre_impressions", sa.Integer(), server_default="0", nullable=False),
        sa.Column("derniere_impression", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(
            ["repas_uuid"], ["repas.uuid"], name="fk_recu_repas_uuid_repas", ondelete="RESTRICT"
        ),
        sa.ForeignKeyConstraint(
            ["utilisateur_uuid"],
            ["utilisateur.uuid"],
            name="fk_recu_utilisateur_uuid_utilisateur",
            ondelete="RESTRICT",
        ),
        sa.PrimaryKeyConstraint("id", name="pk_recu"),
        sa.UniqueConstraint("numero", name="uq_recu_numero"),
        sa.UniqueConstraint("repas_uuid", name="uq_recu_repas_uuid"),
    )
    for column in (
        "uuid",
        "numero",
        "repas_uuid",
        "utilisateur_uuid",
        "nom",
        "prenom",
        "matricule",
        "type_utilisateur",
        "categorie_uuid",
        "categorie_nom",
        "type_identification",
        "date_repas",
        "heure_repas",
    ):
        op.create_index(f"ix_recu_{column}", "recu", [column], unique=column == "uuid")


def downgrade() -> None:
    op.drop_table("recu")
