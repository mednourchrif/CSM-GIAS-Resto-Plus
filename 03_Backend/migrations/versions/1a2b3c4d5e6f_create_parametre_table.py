"""create parametre (settings) table

Revision ID: 1a2b3c4d5e6f
Revises: 032ceaac0575
Create Date: 2026-07-07 10:00:00.000000+00:00
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '1a2b3c4d5e6f'
down_revision: Union[str, None] = '032ceaac0575'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table('parametre',
    sa.Column('id', sa.BigInteger().with_variant(sa.Integer(), 'sqlite'), autoincrement=True, nullable=False),
    sa.Column('uuid', sa.String(length=36), nullable=False),
    sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    sa.Column('key', sa.String(length=100), nullable=False),
    sa.Column('value', sa.Text(), nullable=False),
    sa.Column('category', sa.String(length=50), nullable=False, server_default='general'),
    sa.Column('label', sa.String(length=200), nullable=False),
    sa.Column('description', sa.Text(), nullable=True),
    sa.Column('field_type', sa.String(length=20), nullable=False, server_default='text'),
    sa.Column('options', sa.Text(), nullable=True),
    sa.Column('default_value', sa.Text(), nullable=False),
    sa.Column('is_encrypted', sa.Boolean(), nullable=False, server_default=sa.text('false')),
    sa.Column('order', sa.Integer(), nullable=False, server_default='0'),
    sa.PrimaryKeyConstraint('id', name=op.f('pk_parametre')),
    sa.UniqueConstraint('uuid', name=op.f('uq_parametre_uuid'))
    )
    op.create_index(op.f('ix_parametre_key'), 'parametre', ['key'], unique=True)


def downgrade() -> None:
    op.drop_index(op.f('ix_parametre_key'), table_name='parametre')
    op.drop_table('parametre')
