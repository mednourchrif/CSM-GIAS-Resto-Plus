# CSM-GIAS Resto+ — Project Audit

**Audit date:** 2026-07-25  
**Repository:** `CSM-GIAS-Resto-Plus`  
**Scope:** Flutter mobile/tablet application, FastAPI backend, MySQL data model,
API integration, configuration, security, usability, performance, tests, and
documentation.

## 1. Executive summary

CSM-GIAS Resto+ has a strong project foundation: the repository contains a
feature-oriented Flutter application, a layered FastAPI backend, database
migrations, consistent response wrappers, secure password hashing, pagination,
audit records, responsive administration screens, and a meaningful backend
test suite.

It is not yet safe or functionally consistent enough for a final demonstration.
The most serious gaps are in the central kiosk journey and biometric security:

- The current face engine is an explicit deterministic stub. Arbitrary images
  produce nearly identical embeddings and can be accepted as a match.
- Face embeddings are stored as unencrypted raw `float32` bytes.
- face identification, face verification, face metadata, meal categories, and
  meal registration are unauthenticated; the configured tablet API key is not
  used.
- The public meal endpoint accepts a user UUID directly, allowing callers to
  register a meal without proving that face identification occurred.
- The Flutter client logs login request bodies, authorization headers, tokens,
  and complete API responses.
- Session restoration is broken by both an interceptor race and an incorrect
  `/auth/me` response parser.
- The implemented journey is “select meal → identify → automatically
  register”, while the approved requirements specify “identify → select one
  meal → explicitly confirm”.
- Restaurant hours are implemented as 12:30–22:00 with a fixed UTC offset,
  while the approved rule is 12:30–14:00 local time.
- A successful kiosk screen may display a person's name, contrary to the
  explicit privacy rule.

The project should be improved incrementally. The recommended first release
should secure and correct the existing scope before adding visual novelty.

### Post-audit implementation status

The findings below intentionally preserve the **before-change** evidence used
to plan the work. The audit was followed by an implementation pass on the same
date. All Critical findings and the principal High findings were resolved or
converted into explicit production gates:

| Finding area | Status after implementation |
|---|---|
| Sensitive mobile logging | Resolved; method/path/status only in debug |
| Broken session restoration | Resolved and analyzer/test verified |
| Public direct-UUID meal registration | Removed; one-use grant required |
| Unprotected kiosk routes | Resolved with `X-Tablet-Key`/admin dependency |
| Incorrect select-first journey | Resolved: identify → select → confirm |
| Kiosk PII in responses/success | Removed |
| 12:30–22:00/fixed offset | Resolved: 12:30–14:00 with IANA timezone |
| Plain biometric/QR payload storage | New writes encrypted; legacy migration remains |
| Stub face engine presented as deployable | Production startup now rejects it |
| Admin self-lockout/final-admin removal | Resolved and regression tested |
| Duplicate registration race | Protected with DB constraint handling/transaction |
| Meal list N+1 enrichment | Replaced with batched lookup |
| Placeholder QR/face/history/print actions | Replaced by working flows |
| Android identity/permissions/debug signing | Corrected; private release signing remains external |
| Runtime settings were visible but ineffective | Resolved: safe kiosk endpoint, value validation, and backend/mobile consumption |
| Tests/build quality | 191 backend tests, 13 Flutter tests, analyzer/type checks and debug/release compile pass |

Residual limitations are not hidden:

- A reviewed production biometric engine is not included.
- Existing legacy plaintext face rows require controlled re-encryption.
- Multi-worker login throttling requires a shared store such as Redis.
- A production device fleet should replace the shared APK tablet key with
  provisioned per-device credentials.
- Full FR/EN/AR product-string localization and physical-tablet acceptance
  testing remain future work.

Detailed implementation and verification results are recorded in
`docs/CHANGELOG.md`.

## 2. Detected technology stack

### Mobile/tablet

- Flutter and Dart 3.12
- Material UI with a custom theme/token system
- Riverpod 2 for state management
- GoRouter for navigation and route guards
- Dio for HTTP
- `flutter_secure_storage` for admin access-token persistence
- Camera, Mobile Scanner, and Google ML Kit face/barcode detection
- `fl_chart`, PDF, printing, Excel, and sharing packages for administration
- Android, iOS, web, Windows, macOS, and Linux runner folders are generated,
  although the approved V1 target is one Android tablet

### Backend

- Python 3.13+ project metadata; local environment currently runs Python 3.14
- FastAPI and Pydantic 2
- SQLAlchemy 2 with synchronous sessions
- Alembic migrations
- MySQL 8 / PyMySQL
- JWT access tokens with PyJWT
- bcrypt password hashing
- Loguru logging
- Pillow and NumPy for the current biometric pipeline
- Pytest, Ruff, Black, isort, and mypy
- Docker Compose for MySQL and phpMyAdmin

## 3. Current architecture

### Mobile

The Flutter application uses a feature-first structure. Most substantial
features contain:

```text
feature/
├── data/
│   ├── datasources/
│   ├── dto/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

Cross-cutting concerns live under `lib/core`, while shared widgets, result
types, services, and error mapping live under `lib/shared`. Administration is a
single responsive dashboard whose section content is switched by a local
integer index. The public kiosk and authenticated administration interface are
part of the same application.

### Backend

The backend mostly follows this flow:

```text
FastAPI route → service → repository → SQLAlchemy model → MySQL
```

Pydantic schemas validate and serialize API data. All database writes in a
request share a transaction managed by `get_db`; success commits and exceptions
roll back. Users use joined-table inheritance:

```text
utilisateur
├── administrateur → role
├── reception
├── employe → face_embedding
├── stagiaire → qr_code
└── visiteur → qr_code

utilisateur + categorie_repas → repas
```

`repas` has a database unique constraint on `(utilisateur_uuid, date_repas)`,
which is an important last line of defense for the one-meal-per-day rule.

## 4. What currently works well

- The repository separates mobile, backend, database, design, project
  management, and requirements documentation.
- Flutter has an established design-token foundation for color, typography,
  spacing, radius, elevation, and duration.
- Shared Flutter widgets already cover empty, error, shimmer/loading, dialog,
  responsive layout, status, search, and detail patterns.
- The administration interface is responsive across mobile, tablet, and wider
  layouts.
- Feature data layers generally isolate Dio from presentation state.
- Riverpod providers model loading, pagination, errors, and action feedback for
  the main administration areas.
- Admin tokens use platform secure storage rather than plain preferences.
- Backend routes use Pydantic request models with `extra="forbid"`.
- Passwords are hashed with bcrypt.
- JWT verification checks signature, expiry, required claims, account type,
  account state, and soft-deletion state.
- Protected backend routes consistently use authentication dependencies.
- API successes, errors, and paginated lists already have standard wrappers.
- Unexpected backend exceptions return a safe generic production response;
  stack traces are logged rather than returned.
- Database sessions roll back failed requests.
- Pagination limits page size to 100.
- QR tokens are generated randomly and looked up by a hash.
- Destructive actions in several admin screens already request confirmation.
- Alembic contains a coherent migration chain for the core schema, face
  embeddings, settings, and audit log.
- The backend has 165 collected tests covering authentication, CRUD, QR, meal,
  face service behavior, health, roles, and seed idempotency.

## 5. Findings by priority

### Critical

#### C-01 — Face recognition is a nonfunctional stub

- **Affected:** `03_Backend/app/ai/engine.py`,
  `03_Backend/app/services/face_service.py`
- **Problem:** `StubFaceRecognitionEngine` ignores image content and generates
  small random variations around one seeded vector. Different people and even
  non-face images can produce a high similarity score.
- **Impact:** The core employee identification claim is false and unsafe. A
  demonstration can identify the wrong employee and register a meal against
  that account.
- **Recommendation:** Introduce an explicit engine mode. Stub mode must be
  labeled development-only and must fail application startup in production.
  Integrate a reviewed real embedding engine before claiming production-grade
  recognition. Until that is available, disable face recognition in production
  and keep QR/demo flows honest.

#### C-02 — Biometric templates are stored unencrypted

- **Affected:** `app/models/face_embedding.py`,
  `app/services/face_service.py`, migration
  `032ceaac0575_create_face_embedding_table.py`
- **Problem:** Embeddings are persisted as raw NumPy bytes. This contradicts
  BR-035 and BR-071 and the README's encryption claim.
- **Impact:** Database disclosure exposes irreversible biometric-derived data.
- **Recommendation:** Encrypt embedding bytes with authenticated encryption
  using a dedicated environment-provided key, record a key version, decrypt
  only inside the face service, and document a reversible migration. Never log
  or return templates.

#### C-03 — Kiosk/biometric endpoints lack device authentication

- **Affected:** `app/api/v1/face.py`, `app/api/v1/meals.py`,
  `app/core/config.py`, mobile Dio configuration
- **Problem:** `/face/identify`, `/face/verify`, `/face/{uuid}`,
  `/meals/categories`, and `/meals/register` are public. `TABLET_API_KEY`
  exists but is unused.
- **Impact:** Remote callers can use the biometric comparison API, enumerate
  face metadata, upload expensive images, or create meal records.
- **Recommendation:** Add a constant-time tablet credential dependency for
  kiosk-only routes, require it in production, remove public face metadata, and
  add bounded rate limits. Send the device credential from protected
  environment configuration; do not log it.

#### C-04 — Meal registration trusts a caller-supplied user UUID

- **Affected:** `app/schemas/meal.py`, `app/api/v1/meals.py`,
  `app/services/meal_service.py`
- **Problem:** A public caller can register a face meal by sending any known
  `utilisateur_uuid`; no proof links the request to a successful identification.
- **Impact:** Broken object-level authorization and falsified attendance.
- **Recommendation:** Replace direct public UUID registration with a short-lived,
  single-use identification grant issued by the server after successful QR or
  face identification. Bind the grant to user, method, expiry, and tablet, then
  consume it when the user confirms a category.

#### C-05 — Sensitive credentials and tokens are logged by the mobile client

- **Affected:** `lib/core/network/api_interceptors.dart`,
  `lib/features/auth/data/datasources/auth_remote_datasource.dart`,
  `lib/features/auth/data/repositories/auth_repository_impl.dart`
- **Problem:** Login bodies, request headers, authorization tokens, response
  bodies, and stack traces are printed.
- **Impact:** Passwords and bearer tokens can appear in IDE logs, attached bug
  reports, or device logs.
- **Recommendation:** Remove feature-level request dumps. Use a debug-only,
  redacting logger that masks authorization, cookies, passwords, API keys,
  images, QR tokens, and PII. Production network logging must be off.

#### C-06 — The primary kiosk journey contradicts approved business rules

- **Affected:** `lib/features/home/presentation/screens/home_screen.dart`,
  `lib/features/kiosk_camera/presentation/screens/kiosk_camera_screen.dart`,
  selection providers and meal APIs
- **Problem:** A meal category is selected first. Identification then
  automatically submits the meal without an explicit confirmation.
- **Impact:** Violates BR-038, BR-040 and FR-501–FR-504; accidental selection is
  immediately irreversible.
- **Recommendation:** Redesign the journey as:
  `start → identify → choose category → confirm → register → private success`.
  Keep the grant short-lived and reset all transient state on cancellation,
  timeout, success, or app backgrounding.

#### C-07 — Restaurant hours and local calendar dates are incorrect

- **Affected:** `app/services/meal_service.py`,
  `app/utils/date_utils.py`, `app/services/setting_service.py`
- **Problem:** Closing time is 22:00, documentation in the endpoint says
  00:00, settings say 20:00, and approved BR-042 says 14:00. A hardcoded `+1`
  offset is used instead of an IANA timezone. The meal date uses UTC rather
  than the configured local date.
- **Impact:** Meals can be accepted eight hours after service and may be
  assigned to the wrong day near midnight.
- **Recommendation:** Establish one source of truth: 12:30–14:00 in the
  configured IANA timezone. Use `zoneinfo`, local date boundaries, and tests
  for opening/closing edges and timezone transitions.

#### C-08 — Admin session restoration cannot reliably work

- **Affected:** `lib/features/auth/presentation/providers/auth_provider.dart`,
  `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- **Problem:** Token loading and `/auth/me` start concurrently, so the request
  may run before the interceptor has a token. The parser then expects
  `data.admin`, while the backend returns the admin summary directly in `data`.
- **Impact:** Users are logged out after restart even with a valid token.
- **Recommendation:** Restore sequentially: load token, attach token, call
  `/auth/me`, parse `data`, then publish authenticated state. Add unit tests for
  valid, missing, malformed, expired, and storage-failure cases.

#### C-09 — Last-active-admin and self-lockout rules are missing

- **Affected:** `app/services/user_admin_service.py`, `app/api/v1/users.py`,
  corresponding Flutter user actions
- **Problem:** An admin can deactivate or delete their own account and can
  remove the last active administrator despite BR-049 / FR-604 / FR-605.
- **Impact:** Administration can become permanently inaccessible.
- **Recommendation:** Block self-deactivation/self-deletion and preserve at
  least one other active administrator inside the same database transaction.
  Add authorization tests for concurrent/admin-edge cases.

#### C-10 — Deleted or ineligible identities can remain usable

- **Affected:** employee/intern/visitor delete services,
  `app/services/face_service.py`, `app/services/meal_service.py`
- **Problem:** Soft-deleting an employee does not permanently erase or
  deactivate their biometric template as required by BR-036. Face
  identification does not reject inactive/deleted/non-employee owners before
  returning a match. Direct face registration does not enforce employee type.
- **Impact:** Deleted or wrong-profile users may still be identified and
  receive a meal.
- **Recommendation:** Enforce eligible type/status/date in the server-side
  identification grant. Deactivate/cryptographically erase biometrics during
  employee deletion, and test the whole deletion-to-identification path.

### High

#### H-01 — Login defenses are incomplete and leak failure reasons

- **Affected:** `app/services/auth_service.py`, auth exception responses,
  `Admin.tentatives_echouees`
- **Problem:** Failed attempts are never incremented, lockout constants are
  unused, login is not rate-limited, and machine-readable details distinguish
  unknown email from wrong password.
- **Impact:** Brute-force and account-enumeration risk.
- **Recommendation:** Return one external credential error, audit both failed
  and successful attempts without passwords, implement bounded per-account and
  per-source throttling, and make lockout behavior explicit and tested.

#### H-02 — Authorization roles exist but are not actually applied

- **Affected:** `app/security/dependencies.py`, all admin routes, admin UI
- **Problem:** Nearly every protected endpoint uses the same `require_admin`.
  `require_role` has no route usage. Receptionist accounts cannot authenticate
  through the current auth service even though reception-specific permissions
  and endpoints exist.
- **Impact:** Any administrator can manage users, settings, audit, and
  biometrics; the reception role is structurally present but unusable.
- **Recommendation:** Define a small permission matrix from the approved
  requirements, enforce it in backend dependencies, and hide/disable
  unauthorized UI sections based on server-returned permissions.

#### H-03 — Password and email validation do not match the stated policy

- **Affected:** Pydantic user schemas, user services,
  `app/security/password.py`, Flutter user forms
- **Problem:** `PasswordService.validate_strength` is unused. Email fields are
  plain strings; `email-validator` is absent.
- **Impact:** Weak passwords and malformed emails can be persisted.
- **Recommendation:** Apply one password policy to create/reset operations,
  normalize emails, validate email shape, and return field-level errors that
  the Flutter forms can display.

#### H-04 — Validation errors and backend logs may include secrets

- **Affected:** `app/core/exception_handlers.py`
- **Problem:** Complete Pydantic error objects are logged and returned in
  `details`. Error objects can include rejected input, including a password or
  large base64 image.
- **Impact:** Secrets/PII can enter logs and responses.
- **Recommendation:** Convert validation failures to safe field/code/message
  entries; never include raw input. Redact structured logs centrally.

#### H-05 — The face upload path is unsafe and inconsistent

- **Affected:** `/face/enroll-multiple`, Flutter face enrollment screen/data
  source, image helpers
- **Problem:** Backend declares 5–10 files while Flutter permits 3–5. Files are
  read fully without explicit total-size or MIME/signature limits, and all
  images are processed by the stub.
- **Impact:** Enrollment fails at the mobile minimum and is vulnerable to
  memory/CPU abuse.
- **Recommendation:** Use one documented 3–5 image contract, enforce per-file
  and aggregate byte limits, allow only decoded JPEG/PNG/WebP images, reject
  decompression bombs and multiple/no-face images, and rate-limit uploads.

#### H-06 — QR token secrecy is undermined by persisted QR images

- **Affected:** `app/services/qr_code_service.py`, `QrCode.metadata_json`
- **Problem:** The raw token is hashed, but a Base64 PNG encoding that same raw
  token is stored in `metadata_json`. Decoding/scanning the stored image
  recovers the token.
- **Impact:** Database read access allows active QR impersonation.
- **Recommendation:** Either make QR retrieval explicitly sensitive and encrypt
  the image at rest, or return the image once at issuance and do not persist a
  recoverable token representation. Document the chosen lifecycle.

#### H-07 — Duplicate meal registration has a race window

- **Affected:** `MealService._register`, `MealRepository`
- **Problem:** The service performs count-then-insert. Concurrent requests can
  both pass the count; the unique constraint then raises an unhandled integrity
  error.
- **Impact:** One request can return a 500 instead of a safe duplicate result.
- **Recommendation:** Keep the unique constraint, catch the specific constraint
  violation, roll back safely, and return 409. Add a concurrency-oriented test.

#### H-08 — Settings are inconsistent, partly broken, and mostly inert

- **Affected:** settings service/API/mobile providers and meal/face logic
- **Problem:** Splash calls an authenticated settings endpoint before login.
  `get_version_info()` references nonexistent `cfg.ENVIRONMENT`. Several
  configurable values are not consumed by backend business logic. Arbitrary
  keys/values can be inserted without per-setting validation.
- **Impact:** Settings can appear saved while behavior does not change; version
  loading fails; unsafe values can enter the database.
- **Recommendation:** Separate a safe kiosk-config endpoint from protected
  admin settings, whitelist keys, validate types/ranges, consume settings
  through explicit services, and remove settings that are not genuinely
  supported.

#### H-09 — Android release configuration is not deployable

- **Affected:** `android/app/src/main/AndroidManifest.xml`,
  `android/app/build.gradle.kts`
- **Problem:** Main manifest lacks explicit internet/camera declarations,
  application label and package ID are generic, and release builds use the
  debug signing key.
- **Impact:** Release network/camera behavior or store/device installation may
  fail; the artifact is not presentation-ready.
- **Recommendation:** Add required permissions and privacy behavior, use a
  project package/label, configure a non-committed release signing path, and
  test a release APK on the target tablet.

#### H-10 — Error response parsing is inconsistent

- **Affected:** `lib/shared/utils/dio_error_mapper.dart`,
  backend validation response
- **Problem:** Flutter looks for top-level `errors`; backend returns
  `details.errors`, and the latter is a list rather than the map expected by
  Flutter.
- **Impact:** Forms show generic errors instead of actionable field feedback.
- **Recommendation:** Define one error contract and test it with real request
  validation failures.

#### H-11 — Required multilingual kiosk messages are not implemented

- **Affected:** most Flutter screens, localization setup
- **Problem:** French, English, and Arabic locales are declared, but visible
  strings are hardcoded mostly in French and no generated/localized resources
  exist.
- **Impact:** BR-067 and BR-078 are not met; changing locale cannot translate
  critical kiosk feedback.
- **Recommendation:** Localize essential kiosk states first (instructions,
  closed, invalid/expired/revoked, duplicate, success), including RTL checks.
  Administration may remain French per BR-051.

#### H-12 — Explicit reporting requirements are incomplete

- **Affected:** report service/API/mobile report screen
- **Problem:** On-demand aggregation/export exists, but scheduled daily,
  weekly, and monthly generation, recipient management, email delivery, and
  persisted report history are not implemented.
- **Impact:** BR-053–BR-059 and FR-712 are incomplete.
- **Recommendation:** For the internship release, clearly scope either a
  reliable on-demand report feature or the full scheduled pipeline. Do not
  present unimplemented automation as complete.

### Medium

#### M-01 — Meal list enrichment causes N+1 queries

- **Affected:** `_enrich_meal_response()` in `app/api/v1/meals.py`
- **Problem:** Each meal performs separate category and user queries.
- **Impact:** A page of 20 meals can add roughly 40 queries.
- **Recommendation:** Join or batch-load user/category data in the repository
  and map responses once.

#### M-02 — Synchronous SQLAlchemy runs inside async route functions

- **Affected:** most API route modules
- **Problem:** Blocking DB and CPU/image operations run on the event loop.
- **Impact:** Concurrent requests can stall, especially face uploads and
  reports.
- **Recommendation:** Use normal `def` routes for synchronous work so FastAPI
  uses the threadpool, or deliberately migrate to an async database stack.

#### M-03 — Face identification scans every active embedding

- **Affected:** `FaceService.identify`,
  `FaceEmbeddingRepository.get_all_active`
- **Problem:** Every biometric template is loaded and compared per request.
- **Impact:** Linear latency and memory growth; the under-three-second rule will
  fail as enrollment grows.
- **Recommendation:** Load/decrypt efficiently and introduce an appropriate
  vector index or bounded in-memory index only when a real engine is selected.

#### M-04 — Admin navigation is local widget state

- **Affected:** `DashboardScreen`
- **Problem:** Sections have no distinct routes. Back navigation, deep links,
  restoration, and direct testing are weak.
- **Impact:** Less predictable navigation and presentation behavior.
- **Recommendation:** Give major admin sections named routes within an
  authenticated shell while preserving responsive rail/drawer navigation.

#### M-05 — Some visible actions are placeholders or misleading

- **Affected:** employee detail identification area, admin face section,
  maintenance/settings UI
- **Problem:** Employee QR and fingerprint controls are disabled, a dedicated
  face navigation item opens a placeholder, and the face-delete confirmation
  refreshes state without calling a delete endpoint.
- **Impact:** Users encounter controls that do nothing or believe an operation
  succeeded when it did not.
- **Recommendation:** Remove out-of-scope fingerprint/employee QR controls,
  connect supported face actions, and never show an enabled action without
  implementation and feedback.

#### M-06 — Legacy kiosk screens and routes are dead

- **Affected:** `identification_method_screen.dart`,
  `qr_scanner_screen.dart`, `face_recognition_screen.dart`,
  `processing_screen.dart`, `face_placeholder_screen.dart`
- **Problem:** The combined kiosk camera replaced these flows, but the old
  screens remain unreachable.
- **Impact:** Duplication, stale debug logging, and maintenance confusion.
- **Recommendation:** Confirm no intended fallback depends on them, then remove
  them and their unused imports/providers.

#### M-07 — API URL fallback is unsuitable for an Android tablet

- **Affected:** `lib/core/config/environment.dart`
- **Problem:** The fallback is `http://localhost:8000/api/v1`; on a tablet,
  localhost is the tablet itself. Cleartext HTTP is not a production choice.
- **Impact:** Default builds cannot reach the backend and may encourage
  insecure deployment.
- **Recommendation:** Require `API_BASE_URL` for release builds, validate HTTPS
  in production, and document emulator/device development values.

#### M-08 — Backend documentation and code drift

- **Affected:** root README, backend docs, API documents, progress document
- **Problem:** Root README says React Native and references `04_Mobile`; actual
  code is Flutter in `mobile_app`. Progress says development is 0%. Multiple
  API/time/business descriptions conflict with code.
- **Impact:** Reviewers cannot trust setup or status documentation.
- **Recommendation:** Replace duplicated stale descriptions with a concise
  canonical README and generated/current API overview.

#### M-09 — Quality gates are configured but currently failing

- **Affected:** Python and Dart source broadly
- **Problem:** Ruff, mypy, Black, isort, and Dart analyzer findings are not
  clean. No CI workflow is present in the inspected repository.
- **Impact:** Regressions and inconsistent code reach the main branch.
- **Recommendation:** Fix behavior-affecting findings first, format touched
  files, then establish repeatable lint/test/build commands and CI.

#### M-10 — Mobile test coverage is negligible

- **Affected:** `mobile_app/test/widget_test.dart`
- **Problem:** One test only checks that `RestoApp` is present. There are no
  integration tests.
- **Impact:** Auth, routing, API parsing, kiosk state, confirmations, and error
  feedback can regress undetected.
- **Recommendation:** Add focused tests for DTO contracts, auth restoration,
  route guards, identify/choose/confirm state, and critical reusable states.

#### M-11 — Accessibility is not systematically verified

- **Affected:** Flutter presentation layer
- **Problem:** Some compact actions use small visual density, semantics are not
  consistently assigned to camera/status visuals, and no text scaling or
  contrast tests exist.
- **Impact:** Touch, vision, and assistive-technology usability is uncertain.
- **Recommendation:** Preserve 48dp touch targets, add semantic labels/live
  status announcements, test 200% text scaling, and verify contrast in both
  themes.

### Low

#### L-01 — Generated platform scope is broader than approved V1

- **Affected:** web/desktop/iOS runner directories
- **Problem:** The repository appears multi-platform while requirements target
  one Android tablet.
- **Impact:** Extra maintenance and confusing presentation claims.
- **Recommendation:** Keep generated runners only if they are useful for admin
  previews; document Android as the supported deployment target.

#### L-02 — Naming and formatting are inconsistent

- **Affected:** Dart DTOs and multiple Python modules
- **Problem:** Some Dart fields use snake_case, long lines remain, and imports
  are unsorted.
- **Impact:** Reduced readability, not direct functional failure.
- **Recommendation:** Use camelCase internally and map snake_case only at JSON
  boundaries; format incrementally.

#### L-03 — Large source archives remain in the workspace

- **Affected:** `04_Mobile.rar`, `mobile_app.rar`
- **Problem:** Archives are ignored but consume substantial local space and can
  confuse which source is authoritative.
- **Impact:** Local storage and handoff confusion.
- **Recommendation:** Keep backups outside the repository workspace after
  verifying they are not the only copy. No archive was deleted during audit.

## 6. Functional journey assessment

### Intended actors

- Employee: face identification only
- Intern: nominative QR only during internship
- Visitor: temporary QR for visit date only
- Administrator: authenticated management
- Reception: specified limited rights for interns/visitors/QR, but the current
  authentication path does not make this actor operational

### Intended kiosk journey

```text
Idle/start
  → identify by face or QR
  → server validates identity and eligibility
  → show Plat / Pizza / Sandwich
  → user selects one category
  → explicit confirmation
  → atomic meal registration
  → non-PII success feedback
  → automatic reset to idle
```

### Current kiosk journey

```text
Home category card
  → category is selected
  → combined camera scans face or QR
  → identification result exposes user UUID to client
  → meal is automatically submitted
  → success can display user name
  → automatic reset
```

The current journey is not logically complete against the approved contract:
there is no post-identification selection, no explicit final confirmation, no
server-issued identification grant, and no robust privacy boundary.

## 7. API integration findings

- All major Flutter administration data sources point to existing backend
  routes.
- `/auth/me` parsing is incompatible with the backend response.
- Face multi-enrollment count is incompatible (mobile 3–5, backend 5–10).
- Field validation errors are incompatible (`errors` vs `details.errors` and
  map vs list).
- Kiosk calls do not provide a tablet credential because the backend does not
  enforce one.
- The face identify schema accepts an optional category, but the endpoint
  ignores it; this is misleading contract surface.
- The meal registration response does not include a person's name, while the
  Flutter DTO tries to parse one. Not returning the name is preferable for the
  kiosk privacy requirement.
- Protected data sources consistently use the shared Dio instance, so a
  corrected auth interceptor can cover them centrally.

## 8. Database assessment

### Strengths

- Joined-table user inheritance matches the actor model.
- Public UUIDs are separated from integer primary keys.
- Unique email, employee/intern matricule, role name, category name, QR hash,
  and entity UUID constraints exist.
- Meal uniqueness is enforced at database level.
- Foreign keys connect meals, QR records, users, categories, roles, and face
  templates.
- Migration history is linear and documented.

### Gaps

- Only-one-active-face-template and only-one-active-QR-per-owner invariants are
  service conventions, not database-enforced constraints.
- Face template storage lacks encryption/key version metadata.
- Employee deletion does not enforce biometric erasure.
- Audit log immutability is an application convention rather than a database
  permission/append-only control.
- Some time values are timezone-aware in Python but depend on MySQL behavior;
  local business dates need a single conversion policy.
- A migration will be required for encrypted biometric payload length and key
  metadata. It must be documented and non-destructive.

## 9. Baseline verification

Commands were run without changing application source.

| Check | Result |
|---|---|
| `git status --short --branch` | Six pre-existing modified Flutter files; preserved as user-owned changes |
| Backend test collection | 165 tests collected |
| `pytest tests/test_meals.py -x -vv` | First failure: 14:00 closing edge incorrectly returns open |
| Full `pytest -q` | Did not complete within 90 seconds; not claimed passing |
| `ruff check app tests` | Failed: 174 findings |
| `black --check app tests` | Failed: 29 files would be reformatted |
| `isort --check-only app tests` | Failed: 12 reported files with import ordering issues |
| `mypy app` | Failed: 86 errors in 29 files |
| `pip check` | Passed: no broken installed requirements |
| `dart analyze --format machine` | No errors; 7 warnings and 311 info findings |
| Flutter widget tests | Not run: Flutter SDK unavailable; Dart alone cannot resolve `flutter_test` |
| Android/iOS build | Not run: Flutter SDK unavailable |
| Dependency vulnerability audit | Not run: `pip-audit` is not installed; Flutter audit tooling unavailable |
| Active `.env` | Present and ignored; values were not exposed or modified |
| `.env.example` | Present with documented backend variables |

## 10. Existing user changes

The following files were modified before this audit and are treated as
user-owned work:

- `mobile_app/lib/core/theme/app_shadows.dart`
- `mobile_app/lib/core/theme/app_theme.dart`
- `mobile_app/lib/core/theme/colors.dart`
- `mobile_app/lib/core/theme/spacing.dart`
- `mobile_app/lib/features/home/presentation/widgets/home_header.dart`
- `mobile_app/lib/features/recognition/presentation/screens/success_screen.dart`

Implementation must preserve these edits and integrate around them unless a
specific overlap is necessary and reviewed.

## 11. Prioritized enhancement plan

### Phase A — Security and contract stabilization

1. Remove/redact sensitive mobile logging.
2. Repair session restoration and `/auth/me` parsing.
3. Introduce tablet authentication and remove public face metadata.
4. Replace direct UUID registration with an identification grant.
5. Correct safe error contracts and validation redaction.
6. Add last-admin, self-lockout, eligibility, and deletion protections.
7. Mark the stub engine development-only and prevent false production claims.

### Phase B — Core business workflow

1. Implement local 12:30–14:00 enforcement with `zoneinfo`.
2. Build identify → select → confirm → register state and APIs.
3. Keep success feedback non-identifying.
4. Make QR/face outcomes distinct and actionable.
5. Make cancellation, timeout, app lifecycle, and retries deterministic.

### Phase C — Backend maintainability and performance

1. Apply password/email validation and a minimal authorization matrix.
2. Validate and consume supported settings; remove inert ones.
3. Fix duplicate-meal race handling.
4. Remove meal/statistics N+1 queries.
5. Move blocking work off the async event loop.
6. Add biometric encryption with a documented migration.

### Phase D — Mobile architecture and UI/UX

1. Convert admin sections to routes within an authenticated shell.
2. Apply one coherent design system to kiosk and administration states.
3. Add accessible loading, empty, error, success, and confirmation patterns.
4. Localize essential kiosk messages.
5. Remove confirmed legacy/placeholder controls and screens.
6. Finalize Android identity, permissions, and release configuration.

### Phase E — Quality and handoff

1. Add backend tests for every critical security/business rule.
2. Add Flutter unit/widget tests for auth, DTOs, routing, and kiosk state.
3. Run formatters, lint, type checks, tests, and builds.
4. Validate on a physical Android tablet when available.
5. Update README, architecture, API overview, changelog, and limitations.

## 12. Files/modules likely to change

### Backend

- `app/core/config.py`, exception handling, logging, and dependencies
- `app/security/*`
- `app/api/v1/auth.py`, `face.py`, `meals.py`, `settings.py`, `users.py`
- `app/services/auth_service.py`, `face_service.py`, `meal_service.py`,
  `setting_service.py`, `user_admin_service.py`
- related repositories, schemas, models, migrations, and tests

### Mobile

- `lib/providers.dart`
- `lib/core/config`, `network`, `router`, and storage/auth integration
- auth data source/repository/provider
- kiosk/home/recognition/meal-registration features
- shared error/state/dialog components
- admin routing, users, employee face actions, and settings
- Android manifest and Gradle configuration
- focused tests under `mobile_app/test`

### Documentation

- `README.md`
- `docs/PROJECT_AUDIT.md`
- `docs/ARCHITECTURE.md`
- `docs/API_OVERVIEW.md`
- `docs/CHANGELOG.md`

## 13. Scope decisions

- Do not add onboarding, social features, animations, notifications, or other
  generic mobile features that do not serve the restaurant workflow.
- Do not claim real biometric security while the stub engine remains.
- Do not add a complex cache layer; fix duplicate calls and query shape first.
- Do not delete legacy screens, endpoints, archives, or schema elements until
  usage is confirmed.
- Do not change the active `.env` or insert fake secrets.
- Do not make a destructive database migration. Any biometric migration must
  preserve rollback/recovery instructions.
- Preserve the useful teal/warm brand direction and existing design tokens;
  redesign should prioritize clarity, privacy, accessibility, and speed.

## 14. Audit conclusion

The project is more than a prototype skeleton: a substantial administration
application, backend domain model, and test base already exist. The correct
path is not a wholesale rewrite. The highest-value work is to make the central
meal journey truthful, atomic, private, and secure; then align the visual
experience and documentation with that reliable core.
