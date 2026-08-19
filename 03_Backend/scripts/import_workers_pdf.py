"""Import employees from the CSM-GIAS worker-list PDF and export QR images.

Usage (from 03_Backend):
    .venv\\Scripts\\python.exe scripts\\import_workers_pdf.py --dry-run
    .venv\\Scripts\\python.exe scripts\\import_workers_pdf.py

The import is idempotent by employee number (matricule). New employees get
an active QR through the same service used by the administration API. Existing
employees are not modified; an existing active QR is exported if available.
"""

from __future__ import annotations

import argparse
import base64
import csv
import re
import sys
from pathlib import Path

from pypdf import PdfReader
from sqlalchemy import select

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.database.session import SessionLocal  # noqa: E402
from app.models.admin import Admin  # noqa: E402
from app.models.employee import Employee  # noqa: E402
from app.models.user import StatutUtilisateur, TypeUtilisateur  # noqa: E402
from app.services.employee_service import EmployeeService  # noqa: E402
from app.utils.qr_code import generate_qr_image  # noqa: E402

ROW_RE = re.compile(
    r"^(CSM GIAS|GIAS IND)\s+(\d+)\s+(.+?)\s{2,}(.+)$"
)


def parse_workers(pdf_path: Path) -> list[dict[str, str]]:
    workers: list[dict[str, str]] = []
    for page in PdfReader(str(pdf_path)).pages:
        text = page.extract_text(extraction_mode="layout") or ""
        for line in text.splitlines():
            line = line.strip()
            if not line or line.startswith("Soci"):
                continue
            match = ROW_RE.match(line)
            if not match:
                raise ValueError(f"Could not parse PDF row: {line!r}")
            company, matricule, prenom, surname_and_full_name = match.groups()
            full_name_start = surname_and_full_name.rfind(prenom)
            if full_name_start <= 0:
                raise ValueError(f"Could not separate name columns: {line!r}")
            nom = surname_and_full_name[:full_name_start].strip()
            full_name = surname_and_full_name[full_name_start:].strip()
            if f"{prenom} {nom}".casefold() != full_name.casefold():
                raise ValueError(f"Name columns disagree: {line!r}")
            workers.append(
                {
                    "company": company,
                    "matricule": matricule,
                    "prenom": prenom.strip(),
                    "nom": nom.strip(),
                }
            )

    matricules = [worker["matricule"] for worker in workers]
    if len(matricules) != len(set(matricules)):
        raise ValueError("The PDF contains duplicate employee numbers.")
    return workers


def write_qr(output_dir: Path, worker: dict[str, str], qr_uuid: str, png: bytes) -> str:
    output_dir.mkdir(parents=True, exist_ok=True)
    filename = f"{worker['matricule']}_{re.sub(r'[^A-Za-z0-9_-]+', '_', worker['prenom'] + '_' + worker['nom'])}.png"
    (output_dir / filename).write_bytes(png)
    return filename


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--pdf",
        type=Path,
        default=Path(r"C:\Users\appresto\Downloads\Liste Users APP RESTO - Feuille 1.pdf"),
    )
    parser.add_argument("--output", type=Path, default=ROOT / "exports" / "worker_qr_codes")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    workers = parse_workers(args.pdf)
    print(f"Parsed {len(workers)} workers from {args.pdf}")
    if args.dry_run:
        print("Dry run: no database changes made.")
        for worker in workers[:5]:
            print(f"  {worker['matricule']}: {worker['prenom']} {worker['nom']} ({worker['company']})")
        return 0

    args.output.mkdir(parents=True, exist_ok=True)
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
            raise RuntimeError("No active administrator exists; run the seed first.")

        service = EmployeeService()
        created = skipped = qr_exported = 0
        manifest: list[dict[str, str]] = []
        for worker in workers:
            employee = db.execute(
                select(Employee).where(Employee.matricule == worker["matricule"])
            ).scalar_one_or_none()
            if employee is None:
                from app.schemas.employee import EmployeeCreate

                employee = service.create(
                    db,
                    EmployeeCreate(
                        nom=worker["nom"],
                        prenom=worker["prenom"],
                        matricule=worker["matricule"],
                        statut=StatutUtilisateur.ACTIF,
                    ),
                    admin,
                )
                created += 1
                qr = employee.__dict__["_generated_qr"]
                png = generate_qr_image(qr.raw_token)
            else:
                skipped += 1
                qr = service._qr_repo.get_active_by_owner(db, employee.uuid)
                if qr is None:
                    qr = service._qr_service.generate_for_employee(db, employee.uuid, admin)
                    png = generate_qr_image(qr.raw_token)
                else:
                    data_uri = service._qr_service.get_image_base64(qr)
                    png = base64.b64decode(data_uri.split(",", 1)[1])

            filename = write_qr(args.output, worker, qr.uuid, png)
            qr_exported += 1
            manifest.append(
                {
                    "company": worker["company"],
                    "matricule": worker["matricule"],
                    "prenom": worker["prenom"],
                    "nom": worker["nom"],
                    "employee_uuid": employee.uuid,
                    "qr_uuid": qr.uuid,
                    "qr_file": filename,
                }
            )

        db.commit()
        with (args.output / "manifest.csv").open("w", newline="", encoding="utf-8-sig") as handle:
            writer = csv.DictWriter(handle, fieldnames=manifest[0].keys())
            writer.writeheader()
            writer.writerows(manifest)
        print(f"Created employees: {created}")
        print(f"Existing employees skipped: {skipped}")
        print(f"QR images exported: {qr_exported}")
        print(f"Output: {args.output.resolve()}")
        return 0
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
