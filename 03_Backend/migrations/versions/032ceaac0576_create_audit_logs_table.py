"""create_audit_logs_table

Revision ID: 032ceaac0576
Revises: 434b6acc2c5f
Create Date: 2026-07-08 00:00:00.000000+00:00
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

revision: str = "032ceaac0576"
down_revision: Union[str, None] = "434b6acc2c5f"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "audit_logs",
        sa.Column(
            "id",
            sa.BigInteger().with_variant(sa.Integer(), "sqlite"),
            primary_key=True,
            autoincrement=True,
        ),
        sa.Column("uuid", sa.String(36), unique=True, index=True, nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=True,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=True,
        ),
        sa.Column("timestamp", sa.DateTime(timezone=True), index=True, nullable=False,
                  server_default=sa.text("CURRENT_TIMESTAMP")),
        sa.Column("user_uuid", sa.String(36), index=True, nullable=True),
        sa.Column("user_name", sa.String(200), nullable=False),
        sa.Column("user_role", sa.String(50), nullable=False),
        sa.Column("action", sa.String(100), index=True, nullable=False),
        sa.Column("entity_type", sa.String(100), nullable=True),
        sa.Column("entity_uuid", sa.String(36), nullable=True),
        sa.Column("entity_name", sa.String(300), nullable=True),
        sa.Column("description", sa.Text, nullable=True),
        sa.Column("http_method", sa.String(10), nullable=True),
        sa.Column("endpoint", sa.String(500), nullable=True),
        sa.Column("ip_address", sa.String(45), nullable=True),
        sa.Column("user_agent", sa.String(500), nullable=True),
        sa.Column("status", sa.String(20), nullable=False, server_default="SUCCESS"),
        sa.Column("metadata_json", sa.Text, nullable=True),
        mysql_engine="InnoDB",
        mysql_charset="utf8mb4",
    )


def downgrade() -> None:
    op.drop_table("audit_logs")
