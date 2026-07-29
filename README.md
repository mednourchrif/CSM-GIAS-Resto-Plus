# CSM-GIAS Resto+

CSM-GIAS Resto+ is a tablet-first corporate restaurant application. Employees
identify with their enrolled face; interns and same-day visitors use a managed
QR code. After identification, a person selects and confirms one meal. The
backend enforces eligibility, the restaurant window (12:30–14:00,
in the explicitly configured restaurant IANA timezone), and one meal per
person per local day.

The repository contains a Flutter application and a FastAPI/MySQL API. It was
reviewed and hardened as an internship demonstration project; the original
assessment is recorded in [the project audit](docs/PROJECT_AUDIT.md).

## Main features

- Private kiosk journey: identify → select → confirm → success
- Employee face enrollment and identification contract
- Intern and visitor QR generation, download, sharing, printing, revocation,
  and regeneration
- One-use, two-minute identification grants; direct user UUID registration is
  rejected
- Employee, intern, visitor, receptionist, and administrator management
- Meal history, filters, statistics, reports, settings, and audit trail
- Responsive Material 3 administration UI with light and dark themes
- Consistent loading, empty, error, success, and confirmation states
- JWT admin sessions stored in platform secure storage
- Tablet-key protection for kiosk endpoints
- Encrypted biometric templates and stored QR payload images

## Technology stack

| Area | Technology |
|---|---|
| Mobile | Flutter 3.44, Dart 3.12, Material 3 |
| Mobile state/navigation | Riverpod 2, GoRouter |
| Mobile I/O | Dio, Secure Storage, Camera, ML Kit, Printing |
| API | Python 3.13+, FastAPI, Pydantic 2 |
| Data | SQLAlchemy 2, Alembic, MySQL 8 |
| Security | JWT, bcrypt, Fernet, SHA-256 kiosk grants |
| Quality | Pytest, Ruff, Black, isort, mypy, Flutter analyzer |

## Architecture

```text
Flutter screen
  → Riverpod notifier/use case
  → repository interface
  → Dio remote data source
  → FastAPI route
  → service (business rules)
  → repository
  → SQLAlchemy/MySQL
```

The kiosk never sends a person UUID to register a meal. Face or QR
identification returns an opaque, short-lived grant. The meal service consumes
that grant atomically and derives the person and identification method on the
server. See [Architecture](docs/ARCHITECTURE.md) and
[API overview](docs/API_OVERVIEW.md).

## Repository layout

```text
.
├── 00_Project_Management/   # Planning and project records
├── 01_Documentation/        # Requirements, UML, UX, testing, DevOps
├── 02_Design/               # Design references
├── 03_Backend/              # FastAPI application, migrations, tests
├── 06_Database/             # Database reference documents
├── 07_API/                  # API reference documents
├── docs/                    # Current audit, architecture, API, changelog
└── mobile_app/              # Flutter tablet/mobile application
```

## Prerequisites

- Python 3.13 or newer
- Flutter 3.44 or a compatible stable release with Dart 3.12
- Java 17 and Android SDK for Android builds
- Docker Desktop, or an existing MySQL 8 server
- A physical Android tablet for final camera, ML Kit, QR, print, and secure
  storage acceptance testing

## Backend setup

From `03_Backend`:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -e ".[dev]"
Copy-Item .env.example .env
```

Edit `.env` with real local values. Never commit it. Then:

```powershell
docker compose up -d
alembic upgrade head
python scripts/seed.py
uvicorn app.main:app --reload
```

Swagger UI is available at `http://127.0.0.1:8000/docs`. Production startup
fails if strict configuration validation or database connectivity fails.

## Environment variables

The complete backend template is
[`03_Backend/.env.example`](03_Backend/.env.example). Important values are:

| Variable | Purpose |
|---|---|
| `APP_ENVIRONMENT` | `development`, `testing`, or `production` |
| `APP_SECRET_KEY` | Application encryption secret |
| `JWT_SECRET_KEY` | JWT signing secret |
| `DB_*` | MySQL connection and pool settings |
| `TABLET_API_KEY` | Shared credential for the managed kiosk |
| `FACE_ENGINE` | `stub` only in development/testing; `disabled` for QR-only production, or a reviewed installed adapter |
| `BIOMETRIC_ENCRYPTION_KEY` | Dedicated Fernet key for biometric templates |
| `CORS_ORIGINS` | Explicit production origins |
| `TRUSTED_HOSTS` | Explicit production hostnames |
| `TZ` | Restaurant IANA timezone; required explicitly in production because the requirements do not establish the country |

Generate secrets with a secure password manager. Generate the biometric key
with:

```powershell
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

## Mobile setup

From `mobile_app`:

```powershell
flutter pub get
Copy-Item env.example.json env.local.json
```

Edit `env.local.json` so `TABLET_API_KEY` matches the backend. The Android
emulator reaches the host backend through `10.0.2.2`; a physical tablet must
use the development machine's reachable LAN address.

```powershell
flutter run --dart-define-from-file=env.local.json
```

Production configuration requires HTTPS and all three compile-time values:

```powershell
flutter build apk --release `
  --dart-define=PRODUCTION=true `
  --dart-define=API_BASE_URL=https://api.example.org/api/v1 `
  --dart-define=TABLET_API_KEY=<real-secret>
```

Provision the Android release keystore in your private deployment environment.
The repository intentionally does not contain a signing key or password.

## Database setup and migrations

Docker exposes project MySQL on host port `3307`. Ensure `.env` matches
`docker-compose.yml`, then run:

```powershell
alembic current
alembic upgrade head
alembic heads
```

Migration `b4d62f9c31a8` adds the non-destructive `identification_grant` table.
Existing plaintext biometric rows remain readable for migration compatibility;
new writes are encrypted. Plan a controlled re-encryption operation before
production if legacy rows exist.

## Testing and quality

Backend:

```powershell
python -m pytest -q
python -m ruff check .
python -m black --check app tests scripts migrations
python -m isort --check-only app tests scripts migrations
python -m mypy app
python -m pip check
```

Mobile:

```powershell
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

The verified results for this audit are in
[the changelog](docs/CHANGELOG.md#verification-results).

## API overview

The API uses `/api/v1`, standard success/error envelopes, bearer JWT for
administration, and `X-Tablet-Key` for kiosk operations. Core groups:

- `/auth`, `/identification`, `/face`
- `/meals`, `/qr`
- `/employees`, `/interns`, `/visitors`, `/receptionists`, `/users`
- `/stats`, `/reports`, `/settings`, `/audit`
- `/health`, `/ready`

See [API overview](docs/API_OVERVIEW.md) for access rules and request flows.

## Screenshots

Add final physical-tablet captures before the internship presentation:

| Screen | Placeholder |
|---|---|
| Kiosk home | `docs/screenshots/kiosk-home.png` |
| Camera identification | `docs/screenshots/kiosk-identification.png` |
| Confirmation/success | `docs/screenshots/kiosk-success.png` |
| Admin dashboard | `docs/screenshots/admin-dashboard.png` |
| Face enrollment | `docs/screenshots/face-enrollment.png` |
| QR management | `docs/screenshots/qr-management.png` |

## Known limitations

- The included face engine is a deterministic development/test adapter, not a
  production biometric model. Production configuration rejects it; use
  `FACE_ENGINE=disabled` for QR-only operation until an approved adapter exists.
- Requirements specify local restaurant time but not the country. The
  development fallback is `Africa/Casablanca`; production must explicitly
  configure the business-owner-approved IANA timezone.
- Login throttling is process-local; use a shared Redis-backed limiter for
  multi-worker or multi-instance production.
- The tablet key is a shared credential embedded in the managed APK and must be
  rotated if an installed package or device is compromised; high-assurance
  deployments should add per-device credentials and attestation or mTLS.
- Legacy unencrypted face templates are read-compatible but require a planned
  re-encryption job.
- French is the fully reviewed UI language. The locale list includes English
  and Arabic framework support, but complete product-string translation still
  requires generated localization resources and native-speaker review.
- Physical tablet camera quality, secure storage, QR scanning, printing, and
  network reachability require device acceptance testing.
- Flutter analysis passes with no findings.
- The release artifact built during audit was compile-only, unsigned, and used
  development compile-time configuration. It is not a deployable production
  artifact.

## Recommended future improvements

- Integrate and independently evaluate a consented production face engine,
  including bias, liveness, retention, and false-match acceptance criteria.
- Replace process-local login throttling with Redis.
- Replace the shared tablet key with provisioned per-device credentials for a
  production fleet.
- Add generated FR/EN/AR localization and native-speaker QA.
- Add Flutter integration tests on a managed Android emulator/device farm.
- Add CI for lint, tests, migration checks, and signed release promotion.
- Upgrade camera/scanner/share plugins before Flutter removes legacy Kotlin
  Gradle plugin support.

## Project documents

- [Project audit](docs/PROJECT_AUDIT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [API overview](docs/API_OVERVIEW.md)
- [Changelog](docs/CHANGELOG.md)
- [Final acceptance report](docs/FINAL_ACCEPTANCE_REPORT.md)
- [Face engine integration boundary](docs/FACE_ENGINE_INTEGRATION.md)
- [Android release checklist](docs/ANDROID_RELEASE_CHECKLIST.md)
- [Physical tablet acceptance](docs/PHYSICAL_TABLET_ACCEPTANCE.md)
