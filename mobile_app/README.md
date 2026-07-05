# CSM-GIAS Resto+

Restaurant Management System - Flutter Application

## Architecture

This project follows **Clean Architecture** with a **Feature-First** approach.

### Folder Structure

```
lib/
├── core/
│   ├── config/          # Environment & app configuration
│   ├── constants/       # App-wide constants
│   ├── errors/          # Failure & exception classes
│   ├── network/         # Dio client & interceptors
│   ├── router/          # GoRouter configuration
│   ├── storage/         # Secure storage service
│   ├── theme/           # Material 3 light/dark themes
│   └── utils/           # Validators, extensions, helpers
├── shared/
│   ├── models/          # Shared domain models
│   └── widgets/         # Shared reusable widgets
├── features/            # Feature modules (to be added)
├── providers.dart       # Global Riverpod providers
└── main.dart            # App entry point
```

### Tech Stack

- **State Management**: flutter_riverpod
- **Routing**: go_router
- **Networking**: dio
- **Storage**: flutter_secure_storage
- **Serialization**: freezed + json_serializable
- **Logging**: logger
- **UI**: Material 3

### Running

```bash
# Development
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1

# Build
flutter build apk
flutter build web
```
