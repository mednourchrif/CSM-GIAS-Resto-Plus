# CSM-GIAS Resto+ — API Overview

**Base path:** `/api/v1`  
**Interactive documentation:** `/docs`  
**Response media type:** `application/json`

## 1. Response contracts

Successful single-resource operations use:

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {}
}
```

Paginated responses include `items` and pagination metadata inside `data`.
Errors use a stable, safe shape:

```json
{
  "success": false,
  "message": "Request validation failed",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": {
      "errors": []
    }
  }
}
```

Validation details never echo raw input. Production responses do not include
stack traces.

## 2. Authentication

Administration routes:

```http
Authorization: Bearer <access-token>
```

Managed kiosk routes:

```http
X-Tablet-Key: <configured-tablet-key>
```

Kiosk-protected routes also accept a valid administrator bearer token for
diagnostics. Do not put either credential in logs or query parameters.

## 3. Core kiosk flow

### QR identification

```http
POST /api/v1/identification/qr
X-Tablet-Key: …
Content-Type: application/json

{"qr_token": "<raw-token-from-camera>"}
```

### Face identification

```http
POST /api/v1/face/identify
X-Tablet-Key: …
Content-Type: application/json

{"image_base64": "data:image/jpeg;base64,…"}
```

Successful QR identification returns an opaque token and expiry, without
person PII:

```json
{
  "success": true,
  "data": {
    "identification_token": "opaque-one-use-token",
    "identification_type": "QR",
    "expires_at": "2026-07-25T12:31:30Z"
  }
}
```

Face identification uses the same token principle, with
`identification_expires_at` in its existing face-response contract.

### Categories and registration

```http
GET /api/v1/meals/categories
X-Tablet-Key: …
```

```http
POST /api/v1/meals/register
X-Tablet-Key: …
Content-Type: application/json

{
  "identification_token": "opaque-one-use-token",
  "categorie_uuid": "category-uuid"
}
```

The server consumes the token, enforces eligibility, local opening hours, and
daily uniqueness, then returns non-identifying meal confirmation data. Reusing
the grant or posting a legacy `utilisateur_uuid` payload is rejected.

## 4. Endpoint groups

| Group | Main paths | Access |
|---|---|---|
| Health | `GET /health`, `GET /ready` | Public |
| Auth | `POST /auth/login`, `GET /auth/me` | Login / bearer |
| Identification | `POST /identification/qr` | Kiosk |
| Face | enroll, verify, identify, metadata, erasure | Mixed; see below |
| Meals | categories, register, list, stats, today, history | Kiosk or admin |
| QR | generate, validate, revoke, regenerate, download, history | Admin |
| People | employees, interns, visitors, receptionists | Admin |
| Users | admin/reception account management | Admin |
| Operations | statistics, reports, settings, audit | Admin; kiosk settings are tablet-protected |

## 5. Endpoint catalogue

### Health and authentication

- `GET /health` — liveness plus database status.
- `GET /ready` — readiness information.
- `POST /auth/login` — JWT login; repeated failures are throttled.
- `GET /auth/me` — current authenticated administrator.

### Face and identification

- `POST /identification/qr` — validate QR and issue one-use grant (kiosk).
- `POST /face/identify` — identify an employee and issue grant (kiosk).
- `POST /face/verify` — face verification contract (kiosk).
- `POST /face/enroll` — enroll employee face (admin).
- `POST /face/enroll-multiple` — enroll 3–5 captures (admin).
- `GET /face/{uuid}` — embedding metadata only (admin).
- `DELETE /face/{uuid}` — permanently erase one template (admin).
- `DELETE /face/user/{user_uuid}` — erase all employee templates (admin).

Accepted face images are JPEG, PNG, or WebP, up to 5 MiB each and 20 MiB for a
multi-image request. Images are decoded and verified before processing.

### Meals

- `GET /meals/categories`
- `POST /meals/register`
- `GET /meals`
- `GET /meals/stats`
- `GET /meals/today`
- `GET /meals/history/{user_uuid}`
- `GET /meals/{uuid}`

Only categories/register are available to the managed kiosk. Remaining meal
queries are administrative.

### QR management

- `GET /qr`
- `POST /qr/generate/intern/{uuid}`
- `POST /qr/generate/visitor/{uuid}`
- `POST /qr/validate`
- `POST /qr/revoke/{uuid}`
- `POST /qr/regenerate/{uuid}`
- `GET /qr/{uuid}`
- `GET /qr/download/{uuid}`
- `GET /qr/history/{owner_uuid}`

Employees cannot receive QR codes. Intern expiry follows the stage end date;
visitor use is limited to the visit date. Issuing a replacement revokes the
previous active code.

### Administration

- `GET|POST /employees`; `GET|PUT|PATCH|DELETE /employees/{uuid}`
- `GET|POST /interns`; `GET|PUT|PATCH|DELETE /interns/{uuid}`
- `GET|POST /visitors`; `GET|PUT|PATCH|DELETE /visitors/{uuid}`
- `GET|POST /receptionists`; corresponding detail CRUD
- `GET|POST /users`; update, delete, password, and status operations
- `GET /stats/dashboard`
- `GET /reports/generate`
- `GET|PUT /settings`; reset, version, and database status
- `GET /settings/kiosk` — allowlisted, non-sensitive runtime settings (kiosk)
- `GET /audit`; filters, export, and detail

List endpoints support pagination and, where applicable, search, filters,
sorting, and order.

## 6. Status-code conventions

| Status | Meaning |
|---|---|
| `200` | Read/update/action succeeded |
| `201` | Resource created |
| `204` | Deletion/erasure succeeded without a body |
| `400` | Invalid business request |
| `401` | Missing/invalid/expired credential |
| `403` | Authenticated but unauthorized |
| `404` | Resource not found |
| `409` | Duplicate/conflicting state |
| `422` | Schema validation failed |
| `429` | Login failure limit exceeded |
| `500` | Safe internal error response |

## 7. Business rules enforced by the API

- Restaurant registrations use 12:30–14:00 in `TZ`. Requirements establish
  local time but not a country; production therefore requires an explicit,
  business-owner-approved IANA timezone. `Africa/Casablanca` is only the current
  development/test fallback, not a confirmed deployment choice.
- One meal per person per local calendar day.
- Employees identify only by face.
- Interns identify by QR only during their active stage.
- Visitors identify by QR only on their visit date.
- Inactive or deleted people are ineligible.
- Grants expire and can be consumed only once.
- Administrators cannot disable/delete themselves.
- At least one active administrator must remain.
- Deleting an employee permanently erases their biometric data.

## 8. Production notes

- Serve only behind HTTPS.
- Configure explicit CORS origins and trusted hosts.
- Rotate JWT, tablet, application, and biometric keys through a secret manager.
- Replace the development face adapter before production startup.
- Use Redis-backed throttling when running more than one worker.
- Treat `/docs` exposure as an operational choice; disable or protect it if the
  deployment policy requires.
