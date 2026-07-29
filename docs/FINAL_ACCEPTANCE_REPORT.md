# Final Acceptance and Production-Readiness Report

**Review date:** 2026-07-25  
**Baseline commit:** `774f8666807a379a0f6c63cf2ebb3c372c20ce78`  
**Baseline subject:** `feat: enhance visitor form validation and add meal card components`

## Executive summary

The enhanced Flutter/FastAPI project is **Ready for internship
demonstration**, with QR as the reliable identification path and the bundled
face adapter explicitly presented as a development prototype.

It is **Ready after manual tablet testing** as a candidate for a controlled
internship-demo installation. The checklist in
`PHYSICAL_TABLET_ACCEPTANCE.md` remains unexecuted; camera behavior, permissions,
secure storage, printing, orientation, network interruption, install/upgrade,
and shift-length stability therefore have no physical-device acceptance
evidence.

The bundled face implementation is **Development prototype only**. It is a
deterministic image fingerprint, not a biometric model, has no liveness
protection, and is rejected in production. QR-only production configuration is
now possible with `FACE_ENGINE=disabled`.

The complete application is **Not production-ready**. The blocking gates are an
authorized signed production build and private configuration, physical-tablet
acceptance, a business-owner-confirmed timezone, deployment/rollback rehearsal,
full localization if FR/EN/AR is required, distributed rate limiting/device
credential hardening for a fleet, and either an independently evaluated face
engine or an explicitly QR-only product decision.

No confirmed functional regression remains in the automated matrix. Compilation
and tests do not replace physical or production-environment validation.

## Exact review scope

At final inspection, the worktree relative to the baseline contains:

- 265 tracked changed/deleted paths;
- 35 untracked paths;
- 300 total affected paths;
- tracked diff size: 6,729 insertions and 5,397 deletions.

This is the complete main enhancement worktree, not a clean acceptance-only
commit. No commit, tag, database migration, APK installation, or external
deployment was made by this acceptance pass. Existing untracked screenshot
files (`mobile_app/flutter_02.png` and `flutter_03.png`) were preserved and were
not treated as acceptance artifacts.

The diff review covered routes/controllers, schemas/DTOs, services,
repositories, models, migrations, security/configuration, Flutter providers,
data sources, navigation and removed screens, Android configuration,
dependencies, tests, and documentation. Import/build checks and route/DTO
contract tests provide mechanical coverage across the large formatted diff.
Searches found no remaining references to the removed placeholder,
identification-method, old face-recognition, processing, or QR-scanner screens.
No dependency was added during this acceptance pass.

## Acceptance changes and completed requirements

### Kiosk business workflow

The implemented workflow is:

```text
Idle
→ identify by QR or development face adapter
→ backend validates credential and resolves the user
→ backend issues a short-lived, one-use opaque grant
→ user selects a meal category
→ user explicitly confirms
→ backend atomically consumes the grant and registers the meal
→ privacy-safe success
→ all transient state clears
→ automatic return to idle
```

Completed or verified behavior:

- The mobile registration DTO sends only `identification_token` and
  `categorie_uuid`; it cannot nominate a user UUID.
- QR payloads are random signed/stored-token values; only hashes are stored for
  lookup. API responses expose a raw QR token only on generation/regeneration,
  not on list/detail.
- Identification grants are random, hash-only at rest, short-lived and
  one-use. Replay, expiry and wrong-user-type cases are rejected.
- Registration re-resolves active/deleted state, employee/intern/visitor
  eligibility, internship/visit dates, category, local opening hours and daily
  uniqueness.
- Grant consumption and meal creation use a nested transaction. Eligibility,
  closed-hours, invalid-category and duplicate failures do not accidentally
  burn the grant.
- The kiosk has one central reset operation for pending grant, meal/category
  selection, registration state/result and the submission lock.
- Reset occurs on success, error, cancellation, timeout/expiry, backgrounding,
  logout and restart (grants exist only in memory).
- A request-operation ID prevents a late response from restoring state after a
  reset. A submission lock and notifier loading guard prevent double submits.
- A kiosk endpoint's unauthenticated `401` no longer clears an unrelated
  administrator session; only a request that carried `Authorization` triggers
  admin-session invalidation.
- Success output remains privacy-safe. The kiosk does not receive/display the
  matched person's name or UUID for the registration flow.

### Edge-case evidence

| Case | Evidence/status |
|---|---|
| Successful QR | Backend QR and grant tests; mobile contract tests — passed |
| Development face success | Stub service/API tests — passed; prototype only |
| Invalid, expired, revoked QR | QR/API suite — passed |
| Wrong user type | Security regression suite — passed |
| Inactive/deleted user | Security regression suite — passed |
| Expired/future internship | Security regression suite — passed |
| Visitor wrong date | Security regression suite — passed |
| Grant expiry/replay | Security and mobile contract tests — passed |
| Cancel before confirmation | Flutter widget acceptance test — passed |
| Duplicate daily meal | Meal/security suite — passed |
| Restaurant closed | Meal/security atomicity test — passed |
| Identification/registration network failure | Flutter repository tests — passed |
| Background during flow | Flutter lifecycle widget test — passed |
| Double confirmation | Notifier concurrency test — passed |
| App restart | Fresh ProviderContainer test — passed |
| Real camera/QR/face behavior | Requires physical-tablet execution |

## Deployment timezone

- **Configured development/test fallback:** `Africa/Casablanca`.
- **Defined in:** `BaseAppSettings.TZ` and `03_Backend/.env.example`.
- **Business requirement:** BR-042 specifies 12:30–14:00 “heure locale.”
  NFR-1503 and US-053 require a configurable local server/business timezone.
  The requirements do not name the restaurant country.
- **Decision:** Neither `Africa/Casablanca` nor `Africa/Tunis` can be confirmed
  from repository requirements. The development fallback remains for backward
  compatibility, but `ProductionSettings` has no default and rejects a missing
  or invalid IANA `TZ`. `Africa/Tunis` in one configuration test proves that a
  different valid explicit zone works; it is not a deployment recommendation.
- **Affected implementation:** configuration/environment example, local-time
  utilities, meal hours/date, dashboard date, employee “today” detail, expired
  internship queries, today's visitors, QR expiry statistics, README and API
  documentation.
- **Tests:** opening/closing and local-date meal tests plus production
  missing/invalid timezone tests pass.

UTC-aware timestamps are used in application code. MySQL `DATETIME` does not
preserve an offset despite SQLAlchemy's `timezone=True`; values must continue to
be written/read under the documented UTC convention and converted with `TZ`.

## Face-recognition status

The face boundary is isolated behind `FaceRecognitionEngine`. The current
adapter:

- is named/logged `DEVELOPMENT STUB (NOT BIOMETRIC)`;
- fingerprints image bytes so different images do not silently collapse to the
  same match, but still accepts any valid image as “one face”;
- has no model accuracy, capture-quality assurance, liveness or spoof
  protection;
- is rejected by production configuration;
- cannot be used to make or claim a real biometric identity decision.

`FACE_ENGINE=disabled` starts safely in production QR-only mode. Runtime kiosk
settings report face as disabled and face calls fail closed with a QR fallback
message. Unknown non-stub engine names fail startup instead of silently using
the stub.

New 512-float templates are versioned and Fernet-encrypted. Legacy plaintext
vectors are detected, length-checked, read for migration compatibility and
warned about without an identifier; malformed/encrypted-with-wrong-key data
fails safely. Raw images/templates are not logged or returned. Production
integration and evaluation requirements are in `FACE_ENGINE_INTEGRATION.md`.

The multi-image endpoint currently processes 3–5 captures sequentially and
leaves the last valid embedding active; it does not select the best capture or
fuse embeddings. This is documented and must be redesigned with the approved
engine, not presented as quality-based enrollment.

## Security status

Implemented security controls include:

- backend-only eligibility and object ownership decisions;
- hash-only QR/grant lookup values and one-use grant replay protection;
- encrypted new biometric templates and explicit deletion paths;
- production validation for strong secrets, explicit hosts/origins, tablet key,
  timezone, face mode and biometric key when applicable;
- HTTPS-only production mobile configuration and cleartext-disabled Android
  release manifest;
- Android backups disabled and unnecessary audio/shared-read permissions
  removed from the packaged manifest;
- secure admin-token storage and corrected session restoration/401 isolation;
- bounded login throttling, safe error envelopes, no production stack traces;
- operational logs stripped of UUID/token/QR payload detail; mobile API logs
  use path only (no query/body) and camera errors are debug-only;
- no embedded private-key/common-secret pattern found by the final tracked-file
  scan.

Remaining production concerns:

- the APK tablet key is a shared extractable application credential; a fleet
  needs per-device credentials, rotation and preferably attestation or mTLS;
- login throttling is process-local and must be shared for multi-worker/
  multi-instance deployment;
- final TLS/certificate, proxy headers, log access/retention and secret-manager
  behavior require deployment review;
- generated/shared reports and database backups need privacy retention and
  deletion procedures;
- biometric legal basis, consent, data-subject handling and independent model
  evaluation are not complete.

## Database migration status

Revision `b4d62f9c31a8`:

- adds only `identification_grant`; it does not rewrite an existing table;
- uses MySQL-compatible `BIGINT`, bounded strings and datetimes;
- makes `token_hash`, expiry, created/updated timestamps and user FK non-null;
- keeps `consumed_at` and QR FK nullable;
- has stable named primary/foreign keys and indexes for UUID, unique token hash,
  user, expiry and consumption cleanup;
- uses `SET NULL` for an optional deleted QR and `CASCADE` for its owner;
- downgrades only by dropping the introduced table.

The acceptance migration test ran against a disposable local `mysql:8.0`
container:

```text
fresh database → ae9214788096 → b4d62f9c31a8
→ inspect columns/indexes/FKs → downgrade ae9214788096
→ confirm existing user table remains → upgrade head
```

Result: **1 passed**. The container was removed afterward. The generic suite
skips this one test without `MIGRATION_TEST_DATABASE_URL`, because historical
migrations use constraint alterations SQLite cannot execute. `alembic current`
and `alembic heads` both returned `b4d62f9c31a8 (head)`. No migration was
executed against an unknown/production database.

## Android release status

Final inspected compile facts:

| Item | Result |
|---|---|
| Application ID | `com.csmgias.restoplus` |
| Label | `CSM-GIAS Resto+` |
| Version | `1.0.0` / code `1` |
| Compile / target / minimum SDK | 36 / 36 / 24 |
| Java/Kotlin target | 17 |
| Packaged permissions | Internet, Camera, legacy Write External Storage through API 28, Access Network State |
| Cleartext / backup | disabled / disabled |
| ABIs | armeabi-v7a, arm64-v8a, x86_64 |
| Universal release APK | 113,273,639 bytes (108.03 MiB) |
| Diagnostic SHA-256 | `FFDBD24B722EF81F47454906081F53630A89F332CE18567F1758A113E158219F` |
| Signing | absent; `apksigner` exit 1, “DOES NOT VERIFY” |
| R8/resource shrinking | not enabled; icon tree shaking enabled |
| Build configuration | development defaults, not production defines |

The APK is a compile artifact only. It is not install/deployment approved. A
signed production artifact needs private `PRODUCTION=true`, HTTPS
`API_BASE_URL`, provisioned `TABLET_API_KEY`, authorized signing and the entire
Android/physical checklist. The build also warns that
`camera_android_camerax`, `mobile_scanner` and `share_plus` still apply the
legacy Kotlin Gradle plugin; upgrade them before Flutter enforces built-in
Kotlin.

## Localization assessment

Localization is incomplete and is not accepted as FR/EN/AR support:

- no ARB file or generated product-string localization exists;
- the app declares French, English and Arabic framework locales, but at least
  235 direct `Text('…')` literals remain (a lower bound);
- most product strings are hardcoded French;
- some technical/fallback labels and source messages remain English;
- Arabic product strings are missing;
- 67 explicitly directional padding/alignment occurrences require RTL review,
  along with navigation rails, charts, camera overlays, reports/PDF and icons;
- explicit audit-screen date formats are fixed French-style patterns rather
  than locale-aware skeletons;
- many backend business/error messages are French and are displayed directly
  by Flutter, preventing independent client localization.

Backlog priority:

1. Extract kiosk instructions, permission/network/closed/QR/grant/duplicate/
   success messages and map backend error codes to client translations.
2. Add generated ARB resources with French as source, then professionally
   reviewed English and Arabic.
3. Replace physical left/right layout with directional start/end where
   appropriate and test semantic icons/media.
4. Localize date/time/number formatting using the configured business timezone.
5. Localize administration after the kiosk is complete.
6. Run native-speaker, long-string, text-scale and physical RTL acceptance.

## Strict typing and style debt

Mypy now reports **77 errors in 29 files** (116 checked), down from 91/31 after
fixing actual row-count ambiguity and an enum assignment. The remaining debt is
classified as:

- **SQLAlchemy typing:** result `rowcount`, ORM descriptor assignments, forward
  relationship names and dynamically shaped row results.
- **Generic repository/service typing:** the base service's repository type
  variable does not express CRUD protocol methods, causing attribute/`Any`
  errors.
- **Dynamic metadata:** transient QR response attributes, untyped response
  dictionaries and generic response models.
- **Potential correctness risks reviewed:** optional face/user narrowing is
  runtime-guarded but not expressed to mypy; dynamic report/statistic count
  access was changed to `row._mapping["count"]`; employee status now uses its
  enum. Report/statistic paths need dedicated integration tests beyond typing.
- **Annotation-only/cosmetic:** missing generic arguments, callback annotations,
  logger type signatures, validator parameter annotations, and Python 3.14
  `uuid7` stub support (runtime has a v4 fallback).

These typing findings were resolved without relaxing strict mypy settings.
SQLAlchemy transient QR data now uses an explicit non-persisted property,
nullable face/user paths use typed narrowing, repository/service generics are
bounded, and response/DTO contracts are explicit. Flutter's safe automated
fixes were applied and API-facing JSON keys remain snake_case while Dart fields
use lowerCamelCase. The analyzer now passes with no findings.

## Verification matrix

### Backend

| Command/check | Result |
|---|---|
| `python -m pytest -q` | 190 passed, 1 MySQL-gated skip in the default run |
| disposable MySQL migration test | passed; full upgrade/downgrade/upgrade chain |
| `python -m pytest tests/test_security_regressions.py -q` | 15 passed |
| `python -m ruff check app tests migrations` | passed |
| `python -m black --check app tests migrations` | passed; 139 files unchanged |
| `python -m isort --check-only app tests migrations` | passed |
| `python -m pip check` | no broken requirements |
| `python -m mypy app` | passed; 0 findings across 116 source files |
| `python -m alembic current` | `b4d62f9c31a8 (head)` |
| `python -m alembic heads` | `b4d62f9c31a8 (head)` |
| live Uvicorn + HTTP | health 200, OpenAPI 200, 50 paths |

### Flutter / Android

| Command/check | Result |
|---|---|
| Flutter version | 3.44.5 stable; Dart 3.12.2 |
| `flutter doctor -v` | Android toolchain/device/network pass; Flutter PATH warning; Chrome and Visual Studio unavailable (not Android blockers) |
| `flutter pub get` | passed; 63 constrained packages have newer incompatible versions |
| `dart format --output=none --set-exit-if-changed lib test` | passed; 232 files unchanged |
| `flutter analyze` | passed; no findings |
| `flutter test` | 13 passed |
| `flutter build apk --debug` | passed |
| `flutter build apk --release` | compile passed; unsigned/non-production |
| `apkanalyzer` / `aapt` / `apksigner` / archive inspection | package/SDK/permissions/ABIs/size confirmed; signature absent |
| tracked hardcoded URL scan | one code URL: emulator-only `http://10.0.2.2:8000/api/v1`; production getter requires explicit HTTPS |
| tracked common embedded-secret scan | 0 matches |
| mobile log scan | API path-only/debug logs and debug-only camera errors; no request body/token/image logging |

Flutter Doctor also detected an attached Android handset, but no APK was
installed and no device test was performed because that would change a device
without an explicit physical-test session.

## Known regressions and limitations

No automated regression is confirmed. Remaining risk/limitations:

- manual physical-tablet cases are not executed;
- release artifact is unsigned and uses development compile-time configuration;
- real face recognition/liveness is absent;
- full product localization/RTL is absent;
- reports/statistics have limited direct integration coverage;
- universal APK is large; split APK/AAB and size analysis remain a release task;
- dependency/Kotlin-plugin upgrades need a dedicated compatibility pass;
- no migration rollback was rehearsed against a copy of real deployment data.

## Demonstration recommendation

1. Use a disposable seeded environment and explicit demo timezone.
2. Start at idle and demonstrate a valid intern/visitor QR.
3. Select a meal, show explicit confirmation, privacy-safe success and
   automatic reset.
4. Show duplicate/revoked/expired or closed-hours feedback.
5. Show administrator login, QR management, meal history and one report.
6. If face UI is shown, label it “development prototype—not biometric,” use
   synthetic images and explain the production adapter boundary.
7. Do not distribute the acceptance APK. Build/sign a separate approved demo
   APK after completing the tablet checklist.

## Rollback instructions

### Source

There is no acceptance-only commit boundary, so a blanket `git restore`,
checkout or reset would also erase the main enhancement pass and possibly
pre-existing user changes. Before rollout:

1. Review and commit the full worktree on a dedicated branch.
2. Tag the last known-good application/backend revisions.
3. Archive the reviewed diff and configuration-variable list without secrets.
4. Roll back by redeploying the tagged backend/container and signed prior APK,
   not by destructively resetting this dirty working tree.

### Configuration

- If a face adapter fails, set the reviewed deployment to
  `FACE_ENGINE=disabled` and verify QR-only settings/UI.
- Restore the previous secret-manager version only under the documented key
  rotation procedure; do not change the biometric key while encrypted
  templates still depend on it.
- Revert API/mobile versions together when their contracts differ.

### Database

Back up and verify restore before migration. If `b4d62f9c31a8` must be rolled
back, stop application writes, verify that losing all outstanding
identification grants is acceptable, then downgrade exactly to
`ae9214788096`. Its downgrade drops only `identification_grant`, but that is
destructive to grant rows. Never run it blindly against an unidentified
database. Prefer restoring the tested backup if any unexpected schema/data
effect is observed.

## Files modified during this acceptance pass

### Backend behavior, configuration and tests

- `03_Backend/.env.example` — truthful face modes and explicit production
  timezone guidance.
- `03_Backend/README.md` — production QR-only/timezone configuration.
- `03_Backend/app/core/config.py` — IANA validation, explicit production TZ,
  stub rejection and disabled-face mode.
- `03_Backend/app/core/lifespan.py` — unmistakable startup face-mode banner.
- `03_Backend/app/security/biometrics.py` — encrypted/legacy format detection.
- `03_Backend/app/services/face_service.py` — disabled/unknown engine behavior,
  safe legacy decoding and no silent fallback.
- `03_Backend/app/services/setting_service.py` — disabled face reported and
  enforced through runtime settings.
- `03_Backend/app/services/meal_service.py` — atomic grant/meal savepoint and
  privacy-safe logs.
- `03_Backend/app/services/employee_service.py` — local-day detail, enum-safe
  deletion and privacy-safe logs.
- `03_Backend/app/services/intern_service.py`,
  `visitor_service.py`, `receptionist_service.py`,
  `user_admin_service.py`, `qr_code_service.py` — privacy-safe operational
  logging and maintained audit attribution.
- `03_Backend/app/services/report_service.py` — unambiguous SQLAlchemy labeled
  count access.
- `03_Backend/app/repositories/intern.py`,
  `visitor.py`, `statistics.py` — configured local-day behavior, aware UTC and
  safe labeled-row access.
- `03_Backend/app/api/v1/face.py`, `meals.py` — corrected API descriptions.
- `03_Backend/app/api/v1/stats.py` — configured local dashboard date.
- `03_Backend/migrations/env.py` — explicit grant model registration and
  disposable-test URL override.
- `03_Backend/tests/conftest.py` — deterministic test environment/host
  isolation from local `.env`.
- `03_Backend/tests/test_face.py` — encrypted storage, distinct-image and
  malformed-legacy tests.
- `03_Backend/tests/test_security_regressions.py` — grant/eligibility/replay/
  atomicity/privacy cases.
- `03_Backend/tests/test_production_readiness.py` — production timezone,
  stub-rejection and QR-only tests.
- `03_Backend/tests/test_migrations.py` — disposable MySQL fresh/previous/
  downgrade/re-upgrade chain test.

### Flutter and Android

- `mobile_app/lib/features/identification/presentation/providers/kiosk_flow_provider.dart`
  — one centralized transient-state reset/submission lock.
- `mobile_app/lib/features/meal_registration/presentation/providers/meal_registration_provider.dart`
  — concurrent-submit and late-response protection.
- `mobile_app/lib/features/home/presentation/screens/home_screen.dart` —
  lifecycle/expiry reset and guarded confirmation/cancellation.
- `mobile_app/lib/features/kiosk_camera/presentation/screens/kiosk_camera_screen.dart`
  — reset on completion/error/timeout/background/cancel and debug-only errors.
- `mobile_app/lib/features/recognition/presentation/screens/success_screen.dart`
  — success/background auto-reset.
- `mobile_app/lib/features/admin/presentation/screens/dashboard_screen.dart` —
  reset on logout.
- `mobile_app/lib/features/auth/data/datasources/auth_interceptor.dart` —
  authenticated-request-only admin logout on 401.
- `mobile_app/lib/core/network/api_interceptors.dart` — query/body-free debug
  request logging.
- `mobile_app/lib/shared/widgets/animated_fade_in.dart` — cancellable delayed
  timer, preventing disposal leak.
- `mobile_app/android/app/src/main/AndroidManifest.xml` — cleartext/backup
  restrictions and least-privilege permission removal.
- `mobile_app/android/app/src/debug/AndroidManifest.xml` and
  `src/profile/AndroidManifest.xml` — explicit local-cleartext merge override.
- `mobile_app/android/app/src/main/kotlin/com/csmgias/restoplus/MainActivity.kt`
  — removed platform stack-trace printing.
- `mobile_app/test/kiosk_acceptance_test.dart` — lifecycle, restart, cancel,
  concurrency, late response, network and 401 isolation tests.

### Documentation

- `README.md` and `docs/API_OVERVIEW.md` — removed unverified Casablanca claim,
  documented explicit TZ and new gates.
- `docs/FACE_ENGINE_INTEGRATION.md` — production adapter/security/evaluation
  boundary.
- `docs/ANDROID_RELEASE_CHECKLIST.md` — signing/config/build/artifact/release
  gates.
- `docs/PHYSICAL_TABLET_ACCEPTANCE.md` — 39 manual cases with preconditions,
  steps, expected/actual and pass/fail fields.
- `docs/FINAL_ACCEPTANCE_REPORT.md` — this evidence and classification record.
