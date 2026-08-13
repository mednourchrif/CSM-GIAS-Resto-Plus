"""add signed receipt QR token hash"""

from alembic import op
import sqlalchemy as sa

revision = "e81b7c2d4f90"
down_revision = "d7f4a2c9e810"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("recu", sa.Column("qr_token_hash", sa.String(length=64), nullable=True))
    op.create_index("ix_recu_qr_token_hash", "recu", ["qr_token_hash"], unique=True)
    # Existing receipts predate QR support. They remain printable and receive
    # signed QR payloads on read; only newly created receipts need token hashes.


def downgrade() -> None:
    op.drop_index("ix_recu_qr_token_hash", table_name="recu")
    op.drop_column("recu", "qr_token_hash")
