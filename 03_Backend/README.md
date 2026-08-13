# CSM-GIAS Resto+ API

FastAPI service for the CSM-GIAS restaurant kiosk and administration
application.

## Stack

Python 3.13+, FastAPI, Pydantic 2, SQLAlchemy 2, Alembic, MySQL 8, JWT,
bcrypt, Fernet, Loguru, and Pytest.

## Setup

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -e ".[dev]"
Copy-Item .env.example .env
docker compose up -d
alembic upgrade head
python scripts/seed.py
python -m uvicorn app.main:app --reload
```

Always run the server with the Python interpreter from this backend's `.venv`.
If another virtual environment is active, deactivate it first:

```powershell
deactivate  # repeat if a parent environment is still active
\.venv\Scripts\Activate.ps1
python -m pip install -e ".[dev]"
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

You can also bypass activation completely:

```powershell
\.venv\Scripts\python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Configure real secrets and database credentials in `.env`; never commit it.
Swagger UI is at `http://127.0.0.1:8000/docs`.
API documentation is enabled for development and disabled by default in
production; expose it in production only through an authenticated, controlled
operations path if required.

Migration `d7f4a2c9e810` adds the receipt journal. Every newly confirmed meal
creates one immutable receipt snapshot, and new employees receive an active QR
credential automatically while face enrollment remains optional.

## Structure

```text
app/
├── api/v1/       # Routes
├── schemas/      # Request/response validation
├── services/     # Business rules and transactions
├── repositories/ # SQLAlchemy queries
├── models/       # ORM entities
├── security/     # JWT, passwords, grants, encryption, rate limit
├── middlewares/  # Request and security middleware
├── core/         # Settings, errors, logging, lifespan
└── ai/           # Face-engine contract/development adapter
tests/
migrations/
scripts/
```

## Quality commands

```powershell
python -m pytest -q
python -m ruff check .
python -m black --check app tests scripts migrations
python -m isort --check-only app tests scripts migrations
python -m mypy app
python -m pip check
alembic heads
```

The production environment rejects placeholder secrets, wildcard
hosts/origins, a missing tablet key, a missing explicit IANA timezone, the
development face adapter, a missing biometric key when face mode is enabled,
and an unavailable database. `FACE_ENGINE=disabled` is the supported QR-only
production mode until a reviewed face adapter is installed.

See the repository [README](../README.md),
[architecture](../docs/ARCHITECTURE.md), and
[API overview](../docs/API_OVERVIEW.md).
