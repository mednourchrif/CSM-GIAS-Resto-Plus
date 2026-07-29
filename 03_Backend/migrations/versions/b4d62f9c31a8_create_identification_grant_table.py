"""create identification grant table

Revision ID: b4d62f9c31a8
Revises: ae9214788096
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "b4d62f9c31a8"
down_revision: str | None = "ae9214788096"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "identification_grant",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("uuid", sa.String(length=36), nullable=False),
        sa.Column("token_hash", sa.String(length=64), nullable=False),
        sa.Column("utilisateur_uuid", sa.String(length=36), nullable=False),
        sa.Column("identification_type", sa.String(length=20), nullable=False),
        sa.Column("qr_uuid", sa.String(length=36), nullable=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("consumed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(
            ["qr_uuid"],
            ["qr_code.uuid"],
            name="fk_identification_grant_qr_uuid_qr_code",
            ondelete="SET NULL",
        ),
        sa.ForeignKeyConstraint(
            ["utilisateur_uuid"],
            ["utilisateur.uuid"],
            name="fk_identification_grant_utilisateur_uuid_utilisateur",
            ondelete="CASCADE",
        ),
        sa.PrimaryKeyConstraint("id", name="pk_identification_grant"),
    )
    op.create_index(
        "ix_identification_grant_consumed_at",
        "identification_grant",
        ["consumed_at"],
    )
    op.create_index(
        "ix_identification_grant_expires_at",
        "identification_grant",
        ["expires_at"],
    )
    op.create_index(
        "ix_identification_grant_token_hash",
        "identification_grant",
        ["token_hash"],
        unique=True,
    )
    op.create_index(
        "ix_identification_grant_utilisateur_uuid",
        "identification_grant",
        ["utilisateur_uuid"],
    )
    op.create_index(
        "ix_identification_grant_uuid",
        "identification_grant",
        ["uuid"],
        unique=True,
    )


def downgrade() -> None:
    op.drop_table("identification_grant")
