# Android Release Checklist

## Current release facts

- Application ID / namespace: `com.csmgias.restoplus`
- Display name: `CSM-GIAS Resto+`
- Application version: `1.0.0+1` (`versionName` 1.0.0, `versionCode` 1)
- Java/Kotlin target: 17
- SDK levels in the acceptance build: compile/target 36, minimum 24. They are
  inherited from the installed Flutter SDK; verify the merged manifest again
  before every release.
- App-declared permissions: Internet, Camera, and legacy external-storage write
  only through Android 9 (API 28). The acceptance pass explicitly removes
  transitive `RECORD_AUDIO` and `READ_EXTERNAL_STORAGE`; the merged manifest
  retains plugin-required `ACCESS_NETWORK_STATE`.
- A camera is marked required; devices without a camera are intentionally
  incompatible.
- Cleartext HTTP is disabled in the main manifest. Debug/profile manifests
  allow it for local development.
- Release signing is intentionally unconfigured. The project does not contain
  a keystore or signing password.
- R8/resource shrinking and custom ProGuard rules are not enabled.
- The default release APK is a universal artifact unless split flags are used.

Acceptance compile on 2026-07-25 produced an **unsigned, non-production-config**
universal APK of 113,273,639 bytes (108.03 MiB) containing `armeabi-v7a`,
`arm64-v8a`, and `x86_64`. `apksigner` correctly reported that it does not
verify because no signature is configured. Its checksum is only diagnostic and
must not be treated as a release checksum; a final build after private
configuration and signing will differ.

This repository is **not a signed production release**. Passing a Flutter
release compile proves compilation only.

## 1. Provision configuration

Copy the structure of `mobile_app/env.example.json` to a private file outside
Git, or use CI secret variables. Required production values are:

```json
{
  "PRODUCTION": true,
  "API_BASE_URL": "https://api.example.invalid/api/v1",
  "TABLET_API_KEY": "<provisioned-per-environment-managed-tablet-key>"
}
```

Replace the placeholders with the deployment values. `API_BASE_URL` must be
HTTPS. The tablet key is operationally sensitive: restrict the APK/device,
rotate it after loss or compromise, and never commit or paste it into tickets.
Because a Dart define is compiled into the app, it is not equivalent to a
hardware-backed secret; backend rate limits, device management, TLS, rotation,
and monitoring remain required.

Verify no development URL or secret is tracked:

```powershell
git grep -n -I -E "10\.0\.2\.2|localhost:8000|TABLET_API_KEY=|BEGIN (RSA|PRIVATE)"
git status --short
```

Development fallbacks may appear only in development configuration and
documentation. They must not be used by a production-mode build.

## 2. Provision signing outside the repository

Generate or obtain the organization's upload/release key under its key
management policy. Store the keystore and passwords in the CI secret store;
do not place them under `mobile_app/android`.

Example local generation (replace all placeholders and protect the output):

```powershell
keytool -genkeypair -v `
  -keystore "<secure-path>\resto-plus-upload.jks" `
  -alias "<upload-alias>" `
  -keyalg RSA -keysize 3072 -validity 10000
```

Configure Gradle through an untracked properties file or CI environment
variables, then set the release signing config in
`android/app/build.gradle.kts`. The current `signingConfig = null` is a hard
release gate. Never fall back to debug signing.

Record:

- keystore custodian and backup location;
- alias and certificate SHA-256 (not the password);
- password rotation/recovery process;
- Play App Signing ownership if applicable;
- person who verified the final certificate.

## 3. Version and SDK review

Set the intended version in `pubspec.yaml`; increment `versionCode` for every
Android update. Confirm the SDK values from the generated release manifest:

```powershell
flutter --version
flutter doctor -v
flutter pub get
flutter build apk --release --dart-define-from-file="<private-config.json>"
Select-String `
  -Path "build\app\intermediates\merged_manifests\release\processReleaseManifest\AndroidManifest.xml" `
  -Pattern "uses-sdk|versionCode|versionName"
```

If the Flutter/Android Gradle plugin changes, retest permissions, camera,
storage/export behavior, package installation, and update compatibility.

## 4. Quality gate

From `mobile_app`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release --dart-define-from-file="<private-config.json>"
flutter build appbundle --release --dart-define-from-file="<private-config.json>"
```

The analyzer currently passes with no findings. Keep it clean before release.

From `03_Backend`, complete its test, lint, type-debt review, migration, and
live OpenAPI checks from `README.md`. The backend URL, CORS/trusted hosts,
timezone, tablet key, and QR-only/face mode must match the mobile artifact.

## 5. Artifact inspection

Use the latest installed Android build tools:

```powershell
apksigner verify --verbose --print-certs `
  "build\app\outputs\flutter-apk\app-release.apk"

apkanalyzer manifest application-id `
  "build\app\outputs\flutter-apk\app-release.apk"
apkanalyzer manifest min-sdk `
  "build\app\outputs\flutter-apk\app-release.apk"
apkanalyzer manifest target-sdk `
  "build\app\outputs\flutter-apk\app-release.apk"
apkanalyzer apk summary `
  "build\app\outputs\flutter-apk\app-release.apk"
```

Inspect ABIs in the universal APK:

```powershell
tar -tf "build\app\outputs\flutter-apk\app-release.apk" |
  Select-String "lib/.+/lib(app|flutter)\.so"
```

For direct distribution, decide deliberately between universal and split APKs:

```powershell
flutter build apk --release --split-per-abi `
  --dart-define-from-file="<private-config.json>"
```

For Play distribution, prefer the signed app bundle. Verify app size on the
target tablet and use:

```powershell
flutter build apk --release --analyze-size `
  --target-platform=android-arm64 `
  --dart-define-from-file="<private-config.json>"
```

Do not enable R8/resource shrinking immediately before release without a
regression pass over camera/ML Kit, QR scanning, secure storage, PDF/printing,
sharing, charts, and generated model serialization. If enabled, retain the size
report and all resulting keep rules.

## 6. Security and privacy gate

- Confirm the production API certificate and complete-chain validation on the
  physical tablet; no user-installed debugging CA.
- Confirm cleartext HTTP fails in release.
- Verify no tokens, passwords, image Base64, names, UUIDs, or QR values appear
  in Logcat during login, identification, errors, enrollment, or logout.
- Verify screenshots/recents policy with the deployment owner. The app does
  not currently set `FLAG_SECURE`; accept or implement that policy explicitly.
- Verify secure storage behavior after reinstall, upgrade, logout, screen lock,
  device reboot, and device removal from management.
- Confirm camera permission denial/permanent denial produces a recoverable
  path and no crash.
- Confirm generated reports and shared files follow the organization's
  retention and data-loss-prevention policy.
- Run dependency vulnerability/license review for Gradle, Dart, and native
  transitive dependencies.

## 7. Physical install and upgrade

Complete every case in `docs/PHYSICAL_TABLET_ACCEPTANCE.md` on the exact tablet
model and Android version. Test:

- fresh install after uninstall;
- upgrade from the last approved version without clearing app data;
- reboot, background/foreground, offline/online, camera denial, screen
  rotation if permitted, small/large font, and long content;
- valid, invalid, expired, revoked, reused, and wrong-user QR/grant cases;
- administration login/logout/expiry and report export/share;
- server time near restaurant opening/closing boundaries.

Record actual results, tester, date, build hash, APK SHA-256, backend revision,
database revision, environment, and device identifiers in the acceptance
record.

## 8. Release approval

Release only when all boxes are checked:

- [ ] Production timezone confirmed by the business owner and configured as an
      IANA zone.
- [ ] Backend migration tested on a disposable MySQL database and backed up for
      the real rollout.
- [ ] Approved production face adapter installed and evaluated, or
      `FACE_ENGINE=disabled` with QR-only UI confirmed.
- [ ] Production HTTPS API and explicit trusted hosts configured.
- [ ] Unique tablet key provisioned and rotation tested.
- [ ] Version increment approved.
- [ ] Release keystore/certificate verified.
- [ ] Flutter/backend automated gates pass and acknowledged debt is recorded.
- [ ] Signed APK/AAB signature and checksum verified.
- [ ] Fresh-install and upgrade cases pass on the target physical tablet.
- [ ] Rollback APK/backend/database procedure rehearsed.
- [ ] Product owner, security reviewer, QA reviewer, and release owner approve.
