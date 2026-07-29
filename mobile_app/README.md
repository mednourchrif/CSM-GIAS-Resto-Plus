# CSM-GIAS Resto+ Mobile

Flutter tablet application for private meal identification/registration and
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
