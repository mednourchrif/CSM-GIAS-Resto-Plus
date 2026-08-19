"""Regenerate every active employee, intern, and visitor QR credential."""

from __future__ import annotations

import sys
from pathlib import Path

from sqlalchemy import select

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.database.session import SessionLocal  # noqa: E402
from app.models.admin import Admin  # noqa: E402
from app.models.qr_code import QrCode  # noqa: E402
from app.models.user import StatutUtilisateur, TypeUtilisateur  # noqa: E402
from app.services.qr_code_service import QrCodeService  # noqa: E402


def main() -> int:
    db = SessionLocal()
    try:
        admin = db.execute(
            select(Admin)
            .where(Admin.type == TypeUtilisateur.ADMINISTRATEUR)
            .where(Admin.statut == StatutUtilisateur.ACTIF)
            .order_by(Admin.id)
            .limit(1)
        ).scalar_one_or_none()
        if admin is None:
            raise RuntimeError("No active administrator exists.")

        active = list(
            db.execute(select(QrCode).where(QrCode.statut == "ACTIF")).scalars().all()
        )
        service = QrCodeService()
        regenerated = 0
        for qr in active:
            service.regenerate(db, qr.proprietaire_uuid, qr.type_proprietaire, admin)
            regenerated += 1

        db.commit()
        remaining_active = db.scalar(
            select(QrCode).where(QrCode.statut == "ACTIF").limit(1)
        )
        print(f"Regenerated active QR codes: {regenerated}")
        print(f"One active QR remains per owner: {remaining_active is not None}")
        return 0
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
