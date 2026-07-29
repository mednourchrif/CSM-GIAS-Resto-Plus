# Physical Tablet Acceptance Record

This is a manual test record, not evidence that physical testing has already
occurred. Fill every **Actual** field and mark exactly one result. Attach
screenshots/log references only after removing personal data, tokens, QR
payloads, and biometric material.

## Build and environment

| Field | Actual |
|---|---|
| Tester / date | ______________________________ |
| Tablet make/model | ______________________________ |
| Android version / security patch | ______________________________ |
| Screen size / resolution / density | ______________________________ |
| App version / version code | ______________________________ |
| APK SHA-256 / signing certificate SHA-256 | ______________________________ |
| Git revision / backend revision | ______________________________ |
| Alembic revision | ______________________________ |
| API environment / URL (no credentials) | ______________________________ |
| Configured IANA timezone | ______________________________ |
| Face mode (`disabled` or approved adapter) | ______________________________ |
| Network conditions | ______________________________ |

Use synthetic test users and QR codes. Unless stated otherwise, start each case
with the app freshly returned to the kiosk home screen, no pending identity,
restaurant hours open, and a healthy HTTPS backend.

## Kiosk and identity cases

### PT-01 — Fresh launch contains no previous identity

- **Preconditions:** Install or force-stop the app; a previous user completed
  or abandoned a flow.
- **Steps:** Launch the app; wait for the home screen; inspect available actions.
- **Expected:** No name, grant, selected meal, confirmation, or success from the
  previous user is visible. Identification is required before meal selection.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-02 — Valid QR identification and meal registration

- **Preconditions:** Active eligible user; valid unrevoked QR; no meal today.
- **Steps:** Choose QR; scan once; select a meal; confirm once.
- **Expected:** Identification succeeds without exposing identity details on
  the kiosk, one meal is registered, success feedback appears, then all
  transient identity state clears.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-03 — Invalid QR

- **Preconditions:** A non-system/random QR value.
- **Steps:** Scan the value.
- **Expected:** Safe, understandable error; no grant or meal; retry/cancel is
  available; no crash or secret in Logcat.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-04 — Revoked QR

- **Preconditions:** QR generated then revoked by an administrator.
- **Steps:** Scan the revoked QR.
- **Expected:** Identification is rejected; no grant or meal is created.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-05 — Expired QR

- **Preconditions:** QR whose validity ended.
- **Steps:** Scan the QR.
- **Expected:** Clear expiry/re-identification feedback; no grant or meal.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-06 — Expired identification grant

- **Preconditions:** Identify successfully, then wait beyond grant expiry before
  confirming.
- **Steps:** Select/confirm after expiry.
- **Expected:** Registration is rejected, transient state clears, and the user
  is asked to identify again.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-07 — Reused identification grant / double tap

- **Preconditions:** Valid identity and meal.
- **Steps:** Tap confirm repeatedly/rapidly; after success attempt to replay the
  captured request if test tooling is authorized.
- **Expected:** At most one registration; overlapping submission is blocked;
  replay is rejected as consumed.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-08 — Grant cannot be used for another user

- **Preconditions:** QR/grant for an intern; test also with employee/visitor.
- **Steps:** Attempt a mismatched user/category flow through authorized API test
  tooling.
- **Expected:** Backend re-resolves the grant owner and rejects ineligible
  combinations; the client cannot nominate a different user UUID.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-09 — Duplicate meal

- **Preconditions:** Eligible user already has today’s meal.
- **Steps:** Identify again and confirm another meal.
- **Expected:** Friendly duplicate message; no second record; no stale identity.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-10 — Outside restaurant hours

- **Preconditions:** Controlled server clock/config outside allowed local hours.
- **Steps:** Identify and attempt registration near both boundaries.
- **Expected:** Registration is rejected according to the configured restaurant
  IANA timezone. The grant is not consumed solely by the failed hours check.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-11 — Ineligible intern dates

- **Preconditions:** One not-yet-started and one ended internship.
- **Steps:** Scan each QR and attempt a meal.
- **Expected:** Both are rejected; no meal; failed registration does not make a
  still-valid grant appear consumed.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-12 — Visitor on wrong date

- **Preconditions:** Active visitor scheduled for another date.
- **Steps:** Scan and attempt a meal.
- **Expected:** Rejected with safe feedback; no meal and no accidental grant
  consumption.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-13 — Inactive or soft-deleted user

- **Preconditions:** Inactive test user and soft-deleted test user with old QR.
- **Steps:** Scan each QR and attempt registration.
- **Expected:** Both are rejected with no personal-data leak or meal.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-14 — Cancel confirmation

- **Preconditions:** Successful identification and visible meal choices.
- **Steps:** Select a meal; tap Cancel in the confirmation dialog.
- **Expected:** Dialog closes, no API registration occurs, and all transient
  identity/selection state clears to protect the next kiosk user.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-15 — Background, lock, and foreground

- **Preconditions:** Successful identification with a pending grant.
- **Steps:** Send app to background; lock/unlock; return to app.
- **Expected:** Pending identity and selection are cleared. User must identify
  again; no late response restores the previous identity.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-16 — Offline during identification

- **Preconditions:** Disable Wi-Fi/network before scanning.
- **Steps:** Scan a valid QR; retry after restoring network.
- **Expected:** Bounded loading, clear network error, retry/cancel path, no
  crash; successful fresh identification after restoration.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-17 — Offline during meal registration

- **Preconditions:** Identify while online; disconnect before confirmation.
- **Steps:** Confirm; restore network and start a fresh identity flow.
- **Expected:** Clear failure and no permanent loading overlay. Client clears
  the uncertain transient grant; backend has at most one meal. Operator can
  verify status before retrying.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-18 — Camera permission denied

- **Preconditions:** Remove camera permission.
- **Steps:** Open QR and face capture; deny once, then deny permanently; use
  system settings to restore.
- **Expected:** No crash or blank screen; understandable recovery/cancel path;
  restored permission works.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-19 — QR-only production mode

- **Preconditions:** Backend `FACE_ENGINE=disabled`; mobile points to it.
- **Steps:** Refresh settings/home; try QR; inspect face entry points.
- **Expected:** Face is unavailable/hidden or safely disabled; QR remains fully
  functional; no model import/startup failure.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-20 — Approved face adapter (conditional)

- **Preconditions:** Reviewed production adapter, liveness, enrollment, and
  evaluation gates completed. Do not run this as production evidence with the
  stub.
- **Steps:** Test match, non-match, no face, multiple faces, poor quality,
  spoof/replay, timeout, and fallback to QR.
- **Expected:** Results meet `FACE_ENGINE_INTEGRATION.md`; no raw image/template
  storage or logging; failures never issue a grant.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail [ ] Not applicable—QR-only

## Administration and device cases

### PT-21 — Administrator session isolation and logout

- **Preconditions:** Valid admin account; also prepare invalid/expired token.
- **Steps:** Log in; use admin screens; cause a kiosk 401; then expire the admin
  token; log out.
- **Expected:** Kiosk errors do not log out the admin. Authenticated-route 401
  clears the admin session. Logout clears secure tokens and kiosk state.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-22 — Fresh install and signed upgrade

- **Preconditions:** Approved signed previous build and candidate signed with
  the same certificate; backed-up test data.
- **Steps:** Fresh install candidate; then separately install previous build,
  create session/settings state, and upgrade in place.
- **Expected:** Both install paths launch; upgrade preserves only intended app
  state; database/API contract remains compatible; no signature/version error.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-23 — Responsive, accessibility, and keyboard

- **Preconditions:** Target orientation policy; normal and largest practical
  font/display sizes; long French data.
- **Steps:** Traverse kiosk/admin forms, lists, dialogs, charts, reports, empty,
  loading, and error states; open keyboard in every form.
- **Expected:** No overflow/clipped primary action, readable contrast, visible
  focus/error text, ≥48dp practical touch targets, predictable back behavior,
  and keyboard does not hide required fields/actions.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-24 — Reports, export, share, and storage

- **Preconditions:** Report data and an app capable of receiving a share.
- **Steps:** Filter; export PDF/Excel; open/share; deny or restrict storage where
  applicable; repeat on Android versions in support range.
- **Expected:** Correct data/timezone, safe filename, success/error feedback,
  no broad storage dependency on modern Android, and files follow retention
  policy.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-25 — Restart, reboot, and long kiosk soak

- **Preconditions:** Target tablet on charger/device management as deployed.
- **Steps:** Force-stop/restart; reboot; run repeated successful/error/cancel
  flows for at least the planned shift duration; monitor memory, battery,
  temperature, network recovery, and Logcat.
- **Expected:** No retained identity, crash, growing memory, camera lock,
  duplicated API call, stuck spinner, secret/PII log, or material thermal issue.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-26 — Camera permission accepted

- **Preconditions:** Fresh install or camera permission reset.
- **Steps:** Open QR capture; accept the runtime camera prompt; repeat for face
  capture when an approved adapter is in scope.
- **Expected:** Preview starts once, no duplicate prompt or black frame, and
  returning/cancelling releases the camera.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-27 — Camera permission denied once

- **Preconditions:** Camera permission not yet decided.
- **Steps:** Open capture; deny the prompt; return and try again.
- **Expected:** A clear explanation and safe cancel/retry path appear; the app
  does not loop prompts, crash, or retain an identity.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-28 — Camera permission permanently denied

- **Preconditions:** Camera permission configured as “do not ask again.”
- **Steps:** Open capture; follow any settings guidance; grant permission in
  system settings; return.
- **Expected:** The app distinguishes permanent denial, allows return to idle,
  and recovers after permission is restored.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-29 — Front and rear camera behavior

- **Preconditions:** Device has both cameras.
- **Steps:** Open QR and face capture; verify selected lens; test any available
  switch control; leave and reopen.
- **Expected:** QR uses a suitable rear lens and face capture a suitable front
  lens, or the product's documented fixed-lens policy is consistent. Preview
  orientation is correct and no camera remains locked.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-30 — Portrait orientation

- **Preconditions:** Device/app permits portrait.
- **Steps:** Traverse kiosk, capture, confirmation, success, login, lists, and
  forms in portrait with keyboard open.
- **Expected:** No overflow, clipped action, distorted preview, or unsafe
  restart; scanner overlay aligns with the preview.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-31 — Landscape orientation

- **Preconditions:** Device/app permits landscape.
- **Steps:** Repeat PT-30 in both landscape directions and rotate during a
  non-sensitive idle screen.
- **Expected:** Responsive layout is usable. If deployment locks orientation,
  the lock is documented and rotation does not expose stale identity.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-32 — QR scanning at different distances

- **Preconditions:** Valid printed QR and another displayed on a phone.
- **Steps:** Scan near, normal, and far distances; vary angle and print/display
  size without exposing a real credential.
- **Expected:** Normal operational distance is reliable, duplicate frames issue
  at most one request, and unusable distance can be cancelled without a hang.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-33 — Low-light and glare QR scanning

- **Preconditions:** Controllable low light and reflective phone screen.
- **Steps:** Scan under low light, glare, and moderate shadow.
- **Expected:** No false QR value or crash; user receives positioning guidance
  and can fall back/cancel. Record the reliable lighting envelope.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-34 — Face positioning (conditional)

- **Preconditions:** Approved adapter and consented synthetic/test subject; not
  the development stub.
- **Steps:** Test correct position, too near/far, off-axis, partially outside
  overlay, two faces, and no face.
- **Expected:** Guidance matches detection; only one good-quality live face may
  proceed; no-face/multiple-face cases never issue a grant.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail [ ] Not applicable—QR-only

### PT-35 — Backend unavailable

- **Preconditions:** Tablet remains connected to Wi-Fi; stop or firewall the
  test backend.
- **Steps:** Launch, identify, log in, and retry after restoring the backend.
- **Expected:** Bounded timeout and clear service-unavailable feedback, no false
  success, no permanent spinner, and clean recovery without app restart.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-36 — Slow API response

- **Preconditions:** Test proxy/backend injects controlled latency longer than
  normal but shorter than client timeout.
- **Steps:** Delay identification and registration separately; tap actions
  repeatedly; then complete and repeat with a timeout.
- **Expected:** One request per action, visible loading, actions blocked while
  pending, late response cannot restore cleared state, and timeout is
  recoverable.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-37 — Secure-storage session restoration

- **Preconditions:** Valid administrator session stored on the target Android
  version; separate expired-session case.
- **Steps:** Background/resume, force-stop/relaunch, reboot, and relaunch. Then
  test an expired token and logout.
- **Expected:** Valid admin session restores only as designed; kiosk identity
  never restores; expired/logout state is removed; no token appears in Logcat,
  backup, UI, or shared storage.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-38 — Screen timeout during kiosk flow

- **Preconditions:** Short device screen timeout and a pending identity.
- **Steps:** Allow screen to turn off before meal selection and again during a
  delayed request; unlock after grant expiry.
- **Expected:** Temporary identity clears on background/lock; late responses do
  not resurrect it; camera and UI recover to idle.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail

### PT-39 — Long strings and Arabic RTL assessment

- **Preconditions:** Largest supported text scale; long names/backend messages;
  select Arabic if the current settings expose it.
- **Steps:** Traverse kiosk and key admin screens; inspect dialogs, fields,
  navigation, charts, PDF/export, icons, and numeric/date content.
- **Expected:** No claim of translated Arabic content is made. Record hardcoded
  French text and any incorrect directionality as release defects. A future
  localized build must mirror directional layout without mirroring semantic
  media/icons and must remain usable with long strings.
- **Actual:** ________________________________________________
- **Result:** [ ] Pass [ ] Fail [ ] Known localization backlog

## Acceptance

| Role | Name / decision / date |
|---|---|
| QA tester | ______________________________ |
| Product/business owner | ______________________________ |
| Security reviewer | ______________________________ |
| Release owner | ______________________________ |

Overall decision: [ ] Pass [ ] Fail [ ] Conditional

Open defects / evidence links:

______________________________________________________________________________

______________________________________________________________________________
