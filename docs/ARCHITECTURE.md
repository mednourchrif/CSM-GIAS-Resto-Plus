# CSM-GIAS Resto+ — Architecture

**Version:** 1.0  
**Updated:** 2026-07-25

## 1. System context

CSM-GIAS Resto+ has two user surfaces:

- A self-service Android tablet at the restaurant entrance.
- An authenticated administration area in the same Flutter application.

The tablet communicates with one FastAPI service. FastAPI owns all eligibility,
authorization, time-window, uniqueness, and persistence rules. MySQL is the
system of record.

```text
Employee ── face ──┐
Intern ───── QR ───┼─> Flutter kiosk ─HTTPS─> FastAPI ─> SQLAlchemy ─> MySQL
Visitor ──── QR ───┘                       │
                                          ├─> biometric engine adapter
Administrator ─> Flutter administration ──└─> audit/logging
```

## 2. Core trust boundary

The mobile application is not trusted to assert a person's identity.
Identification and meal registration are deliberately separated:

```text
1. Face image or raw QR token
      ↓
2. POST /face/identify or /identification/qr
      ↓
3. Server verifies eligibility and issues opaque 2-minute grant
      ↓
4. User selects a category and explicitly confirms
      ↓
5. POST /meals/register { identification_token, categorie_uuid }
      ↓
6. Server locks/consumes grant and creates at most one daily meal
```

Only the grant hash is stored. A grant is one-use, expires after two minutes,
and is consumed transactionally. The public contract cannot accept a user UUID,
which prevents the client from bypassing identification.

## 3. Mobile architecture

The Flutter code is feature-first with a pragmatic clean separation:

```text
lib/
├── core/
│   ├── config/       # Compile-time environment rules
│   ├── errors/       # Exceptions and failure mapping
│   ├── network/      # Dio client and safe interceptors
│   ├── router/       # GoRouter and auth redirect
│   ├── storage/      # Secure token storage
│   └── theme/        # Colors, typography, spacing, elevation
├── features/
│   ├── auth/
│   ├── identification/
│   ├── face_recognition/
│   ├── kiosk_camera/
│   ├── meal_registration/
│   ├── home/
│   ├── recognition/
│   └── admin/
├── shared/           # Reusable widgets, result types, services
├── providers.dart    # Cross-feature composition
└── main.dart
```

Each substantial feature follows:

```text
presentation (screen/widget/provider)
    ↓
domain (entity/repository contract/use case)
    ↓
data (DTO/remote data source/repository implementation)
```

### State and navigation

- Riverpod owns auth, API clients, selected category, identification grant,
  registration state, lists, filters, and administration state.
- GoRouter provides splash, kiosk, login, success, and administration routes.
- Auth restoration awaits secure-storage initialization before requesting
  `/auth/me`.
- On 401, memory and secure storage are cleared consistently.

### UI system

The Material 3 design tokens define:

- teal primary and warm secondary brand colors;
- light/dark surfaces and semantic status colors;
- typography hierarchy;
- 4-point-derived spacing and responsive breakpoints;
- consistent radii, touch targets, elevation, buttons, inputs, cards, dialogs,
  snackbars, loading, empty, error, and success states.

The kiosk uses responsive portrait/landscape layouts. Administration uses a
drawer on phones and navigation rail/content panel on wider devices.

## 4. Backend architecture

```text
app/
├── api/v1/          # HTTP transport and dependency injection
├── schemas/         # Pydantic requests/responses
├── services/        # Business rules and transaction orchestration
├── repositories/    # SQLAlchemy queries
├── models/          # ORM entities/relationships
├── security/        # JWT, password, tablet, grants, encryption, throttling
├── middlewares/     # Request IDs, timing, security headers
├── core/            # Settings, lifespan, exception handling, logging
├── ai/              # Face-engine interface and development adapter
└── utils/           # Dates, validation, image/QR helpers
```

Routes stay thin: validate transport input, resolve an authenticated principal,
invoke a service, and serialize a response. Services own rules and transactions.
Repositories own query shape and row locking.

## 5. Data model

`utilisateur` is the joined-inheritance identity root. Extension tables provide
role-specific data:

```text
utilisateur
├── administrateur ── role
├── receptionniste
├── employe ───────── face_embedding
├── stagiaire ─────── qr_code
└── visiteur ──────── qr_code

utilisateur ──< repas >── categorie_repas
utilisateur ──< identification_grant
administrateur ──< audit_log
```

Important constraints:

- public UUIDs are distinct from internal integer keys;
- email and matricule uniqueness are enforced;
- a database uniqueness constraint prevents duplicate daily meals;
- face templates refer to employees and have at most one active service-level
  record;
- grants store only SHA-256 token hashes and expiration/consumption timestamps;
- soft deletion is used for people, while employee biometric deletion is a
  permanent erasure.

## 6. Authentication and authorization

| Surface | Credential | Access |
|---|---|---|
| Admin UI | JWT bearer token | Administration routes |
| Managed kiosk | `X-Tablet-Key` | Identification/categories/register/runtime settings |
| Health | None | Liveness/readiness metadata |

Passwords are bcrypt hashed. Login errors do not disclose whether an email
exists. Repeated failures are throttled. Admin invariants prevent self-disable
and removal/disable of the final active administrator.

The current V1 login contract is administrator-only. Receptionist entities are
managed by administrators, but no restricted receptionist mobile session is
presented as complete.

## 7. Privacy and cryptography

- New face templates are encrypted with Fernet before database storage.
- A dedicated production `BIOMETRIC_ENCRYPTION_KEY` is mandatory.
- Existing raw templates are readable only for a controlled compatibility
  migration.
- Stored QR PNG payloads are encrypted; raw QR tokens are never stored.
- Identification and meal responses omit person names and UUIDs from the kiosk.
- Mobile logging excludes headers, bodies, tokens, passwords, and private data.
- Production errors omit stack traces and internal details.

Key rotation and legacy template re-encryption must be an operational procedure;
they are not performed automatically to avoid destructive migration behavior.

## 8. Configuration and deployment

Backend configuration is environment-driven through `.env`/process variables.
Production rejects placeholder secrets, wildcard hosts/origins, missing tablet
and biometric keys, and the stub face engine. Production startup also fails if
the database is unavailable.

Mobile configuration is compile-time:

- `PRODUCTION`
- `API_BASE_URL`
- `TABLET_API_KEY`

Production requires HTTPS. Development cleartext traffic is allowed only by the
Android debug/profile manifests. Release signing is intentionally external to
the repository.

`TABLET_API_KEY` is an internship-scale shared device credential, not a
hardware-backed identity. A production fleet should provision and rotate
per-device credentials and add attestation or mutual TLS.

## 9. Performance decisions

- Paginated administration endpoints and lists limit data growth.
- Meal response enrichment batches user/category retrieval instead of N+1
  lookups.
- Active face queries filter inactive/deleted people in SQL.
- Camera, barcode, timers, listeners, and animation controllers are disposed.
- No speculative caching layer is included; correctness and simple refresh
  behavior are preferred for this project size.

## 10. Testing strategy

- Backend API tests use isolated SQLite sessions and dependency overrides.
- Security regression tests cover one-use grants, replay, kiosk authentication,
  validation redaction, throttling, and admin continuity.
- Settings tests cover the public allowlist, range validation, and protected
  kiosk delivery contract.
- Flutter widget smoke tests validate application construction.
- Analyzer, formatter, Android debug/release compile, migration head, package
  integrity, and a live Uvicorn/OpenAPI socket check complement the suites.
- Physical-device acceptance remains required for camera/ML Kit, secure
  storage, QR, printing, permissions, and real network behavior.

## 11. Architectural constraints

- The stub face engine is not a biometric security feature and cannot run in
  production.
- Process-local throttling is appropriate for a single internship demo process,
  not a horizontally scaled service.
- Synchronous SQLAlchemy is retained to avoid an unjustified rewrite; blocking
  biometric work should move to an executor when a real engine is integrated.
- The Android tablet is the supported V1 runtime. Other generated Flutter
  platforms are not acceptance targets.
