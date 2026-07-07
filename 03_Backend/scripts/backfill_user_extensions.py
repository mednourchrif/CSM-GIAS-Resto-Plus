"""Backfill missing extension table rows for users with buggy User(...) creation."""
import sys; sys.path.insert(0, '')
from app.database.session import SessionLocal
from app.models.admin import Admin, Receptionist
from app.models.user import User
from sqlalchemy import select, text

db = SessionLocal()
try:
    stmt = text("""
        SELECT u.id, u.uuid, u.type
        FROM utilisateur u
        LEFT JOIN administrateur a ON u.id = a.id AND u.type = 'ADMINISTRATEUR'
        LEFT JOIN reception r ON u.id = r.id AND u.type = 'RECEPTION'
        WHERE u.type IN ('ADMINISTRATEUR', 'RECEPTION')
          AND (
            (u.type = 'ADMINISTRATEUR' AND a.id IS NULL)
            OR
            (u.type = 'RECEPTION' AND r.id IS NULL)
          )
    """)
    rows = db.execute(stmt).all()

    if not rows:
        print("No missing extension rows found.")
        sys.exit(0)

    print(f"Found {len(rows)} users with missing extension rows:")
    for r in rows:
        print(f"  id={r.id}, uuid={r.uuid}, type={r.type}")

    for r in rows:
        user = db.get(User, r.id)
        if user is None:
            print(f"  SKIP id={r.id}: user not found")
            continue

        if isinstance(user, Admin):
            db.execute(
                text("INSERT INTO administrateur (id, tentatives_echouees) VALUES (:id, 0)"),
                {"id": r.id},
            )
            print(f"  -> Inserted administrateur row for id={r.id}")
        elif isinstance(user, Receptionist):
            db.execute(
                text("INSERT INTO reception (id) VALUES (:id)"),
                {"id": r.id},
            )
            print(f"  -> Inserted reception row for id={r.id}")

    db.commit()
    print("Done — all extension rows backfilled.")
except Exception as e:
    db.rollback()
    print(f"ERROR: {e}")
finally:
    db.close()
