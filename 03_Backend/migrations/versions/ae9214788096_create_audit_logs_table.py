"""create audit_logs table

Revision ID: ae9214788096
Revises: 1a2b3c4d5e6f
Create Date: 2026-07-15 08:14:54.478551+00:00
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = 'ae9214788096'
down_revision: Union[str, None] = '1a2b3c4d5e6f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table('audit_logs',
        sa.Column('id', sa.BigInteger().with_variant(sa.Integer(), 'sqlite'), autoincrement=True, nullable=False),
        sa.Column('uuid', sa.String(length=36), nullable=False),
        sa.Column('timestamp', sa.DateTime(timezone=True), nullable=False),
        sa.Column('user_uuid', sa.String(length=36), nullable=True),
        sa.Column('user_name', sa.String(length=200), nullable=False),
        sa.Column('user_role', sa.String(length=50), nullable=False),
        sa.Column('action', sa.String(length=100), nullable=False),
        sa.Column('entity_type', sa.String(length=100), nullable=True),
        sa.Column('entity_uuid', sa.String(length=36), nullable=True),
        sa.Column('entity_name', sa.String(length=300), nullable=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('http_method', sa.String(length=10), nullable=True),
        sa.Column('endpoint', sa.String(length=500), nullable=True),
        sa.Column('ip_address', sa.String(length=45), nullable=True),
        sa.Column('user_agent', sa.String(length=500), nullable=True),
        sa.Column('status', sa.String(length=20), nullable=False),
        sa.Column('metadata_json', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint('id', name=op.f('pk_audit_logs'))
    )
    op.create_index(op.f('ix_audit_logs_action'), 'audit_logs', ['action'], unique=False)
    op.create_index(op.f('ix_audit_logs_timestamp'), 'audit_logs', ['timestamp'], unique=False)
    op.create_index(op.f('ix_audit_logs_user_uuid'), 'audit_logs', ['user_uuid'], unique=False)
    op.create_index(op.f('ix_audit_logs_uuid'), 'audit_logs', ['uuid'], unique=True)


def downgrade() -> None:
    op.drop_index(op.f('ix_audit_logs_uuid'), table_name='audit_logs')
    op.drop_index(op.f('ix_audit_logs_user_uuid'), table_name='audit_logs')
    op.drop_index(op.f('ix_audit_logs_timestamp'), table_name='audit_logs')
    op.drop_index(op.f('ix_audit_logs_action'), table_name='audit_logs')
    op.drop_table('audit_logs')