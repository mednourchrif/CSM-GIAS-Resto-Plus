# CSM-GIAS Resto+ Flutter

Shared Flutter application for Android meal-kiosk operation and responsive Web
restaurant administration.

## Setup

```powershell
flutter pub get
Copy-Item env.example.json env.local.json
flutter run --dart-define-from-file=env.local.json
```

Use `10.0.2.2` for a host backend from the Android emulator. On a physical
tablet, use a reachable LAN/HTTPS address. The mobile `TABLET_API_KEY` must
match the backend.

Production:

```powershell
flutter build apk --release `
  --dart-define=PRODUCTION=true `
  --dart-define=API_BASE_URL=https://api.example.org/api/v1 `
  --dart-define=TABLET_API_KEY=<real-secret>
```

The release keystore remains private and is not stored in this repository.

Build Web and Android with one command (the tablet key is passed only to the
Android build):

```powershell
$env:RESTO_TABLET_API_KEY = '<real-secret>'
.\tool\build_all.ps1 `
  -Production `
  -ApiBaseUrl https://api.example.org/api/v1
Remove-Item Env:RESTO_TABLET_API_KEY
```

See [Web and mobile builds](../docs/WEB_AND_MOBILE_BUILD.md) for local run,
deployment, CORS, output paths, and security details.

## Architecture

Feature-first modules separate presentation/Riverpod state, domain contracts,
and data/DTO integrations. Shared configuration, network, secure storage,
routing, theming, result types, and state widgets live under `lib/core` and
`lib/shared`.

## Quality

```powershell
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

See the repository [README](../README.md) and
[architecture](../docs/ARCHITECTURE.md).
