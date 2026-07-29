# CSM-GIAS Resto+ — Enhancement Changelog

## 2026-07-25 — Professional audit and stabilization

### Audit and architecture

- Added a full priority-classified audit in `docs/PROJECT_AUDIT.md`.
- Documented the implemented mobile/backend/data architecture and trust
  boundaries.
- Documented the current API groups, security model, response contracts,
  business rules, setup, testing, build, and production limitations.
- Corrected the root project description from React Native to Flutter and the
  real directory layout.

### Security

- Removed request/response bodies, headers, passwords, and tokens from mobile
  logs; retained debug-only method/path/status diagnostics.
- Fixed secure-storage/session-restoration ordering and `/auth/me` response
  parsing.
- Added `X-Tablet-Key` protection to identification, category, and registration
  operations.
- Replaced direct user UUID meal registration with opaque one-use,
  two-minute identification grants.
- Hashed grant tokens at rest and consumed them with row locking.
- Removed person names and UUIDs from kiosk identification/registration
  responses and the success screen.
- Added strict production validation for secrets, hosts, origins, tablet key,
  biometric key, HTTPS mobile URL, and face engine.
- Added encrypted storage for new biometric templates and QR payload images,
  with legacy read compatibility.
- Added password policy and email validation for account administration.
- Added process-local login failure throttling and generic credential errors.
- Sanitized validation errors so submitted passwords and other raw inputs are
  never reflected.
- Prevented administrator self-disable/delete and final-admin removal.
- Made employee deletion erase biometric templates permanently.
- Protected face metadata and explicit biometric erasure routes.
- Added security headers and production HSTS behavior.

### Business flow and integration

- Implemented identify → select → confirm → register.
- Corrected the restaurant window to 12:30–14:00 in the configured IANA
  timezone.
- Enforced employee/face, intern/QR/stage, and visitor/QR/visit-date rules.
- Added an atomic duplicate-meal conflict path for concurrent requests.
- Aligned mobile request/response DTOs with the hardened API.
- Made category-loading failures visible instead of treating them as an empty
  success.
- Added real QR generation from intern/visitor detail screens.
- Added QR print output using the installed PDF/printing libraries.
- Connected employee “full history” to filtered meal history.
- Added a functional, searchable face-enrollment directory for the “Visages”
  administration section.
- Added a tablet-protected runtime-settings endpoint and loaded its safe values
  during kiosk startup.
- Removed inert settings from the administration form, validated every
  remaining value, and connected face/QR enablement, similarity threshold,
  camera quality, detection timeout, maximum attempts, theme, messages, and
  success return delay to real behavior.

### Mobile UI/UX

- Consolidated the existing Material 3 color, typography, spacing, radius,
  shadow, button, input, and card tokens.
- Redesigned the kiosk home around a single obvious identification action,
  responsive category cards, explicit confirmation, modal loading, error
  recovery, and privacy-safe success feedback.
- Added consistent snackbars and confirmation dialogs for important and
  destructive actions.
- Added camera permission/failure recovery, lifecycle scanning restart,
  camera-stream-safe capture, semantic camera labels, and live guidance.
- Replaced the development 404 placeholder with a useful not-found screen.
- Removed misleading employee QR and unfinished fingerprint controls.
- Completed QR generation, biometric enrollment, history, and print actions
  that previously displayed “coming soon”.
- Added Android internet/camera declarations and restricted cleartext traffic
  to debug/profile builds.
- Changed the Android identity from the template package to
  `com.csmgias.restoplus`.
- Removed debug signing from the release build configuration.

### Backend maintainability and performance

- Added centralized safe validation/error handling and production fail-closed
  database startup.
- Added deterministic image-derived development face fingerprints and blocked
  the stub engine in production.
- Added image type, integrity, count, and size validation.
- Batched meal response enrichment to remove per-row user/category queries.
- Filtered face candidates to active, non-deleted employees.
- Standardized formatting and eliminated all Ruff findings.
- Added Windows-console-safe request/startup logs.
- Added `email-validator` to the declared and installed dependencies.
- Added non-destructive Alembic migration `b4d62f9c31a8` for identification
  grants.

### Cleanup

- Removed confirmed unrouted legacy identification, processing, scanner, face
  placeholder, and old face-recognition screens.
- Removed the unused identification enum/provider path.
- Removed unused imports, locals, fields, duplicate code paths, and sensitive
  debug prints.
- Formatted Dart and Python sources with project-standard tools.

### Tests added or updated

- Identification grant one-use and replay rejection.
- Legacy direct UUID registration rejection.
- Kiosk endpoint authentication.
- Validation password redaction.
- Login throttling.
- Administrator self-disable and final-admin deletion protection.
- Correct restaurant hours and timezone behavior.
- Updated face hard-erasure and privacy contracts.
- Updated meal API tests to use the complete identification flow.
- Added runtime-setting allowlist, validation, and kiosk-authentication tests.

## Verification results

| Check | Result |
|---|---|
| Backend tests | `191 passed` (190 default-suite tests plus isolated MySQL migration chain) |
| Security regression tests | `15 passed` |
| Ruff | Passed, 0 findings |
| Black | Applied; check passed on final source set |
| isort | Applied; check passed on final source set |
| pip dependency check | Passed |
| mypy | Passed, 0 findings across 116 source files |
| Alembic head | `b4d62f9c31a8 (head)` |
| Live database health/readiness | HTTP 200; healthy/ready |
| Dart analyzer | Passed, 0 findings |
| Flutter tests | `13 passed` |
| Android debug APK | Built successfully |
| Android release compile | Built successfully, unsigned/non-production |

### Non-blocking verification notes

- The release compile used development Dart defines and no signing key. It
  proves compilation only and must not be deployed.
- Flutter reported future Kotlin-plugin migration warnings for camera,
  scanner, and share plugins.
- Physical Android tablet acceptance testing was not possible in this
  environment.

## Removed features/code

No supported business feature was removed. Only confirmed unrouted legacy
screens/enums and misleading placeholder controls were deleted or replaced.

## Database change

Migration `b4d62f9c31a8_create_identification_grant_table.py` adds one table and
indexes. It does not delete or rewrite existing data. Apply with:

```powershell
cd 03_Backend
alembic upgrade head
```

Review the migration and back up production data before any production schema
change.
