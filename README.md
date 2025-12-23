# 🚀 Flutter Clean Architecture Boilerplate

[![Flutter Version](https://img.shields.io/badge/Flutter-3.9+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.9+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A production-ready Flutter boilerplate following **Clean Architecture** principles with **Riverpod** state management, **Firebase** integration, and **RESTful API** support.

## 📋 Table of Contents

- [Features](#-features)
- [Architecture Overview](#-architecture-overview)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Documentation](#-documentation)
- [Code Generation](#-code-generation)

---

## ✨ Features

### 🏗️ Architecture & Code Quality
- ✅ **Clean Architecture** - Domain, Data, Presentation layers with clear separation
- ✅ **SOLID Principles** - Maintainable and testable code
- ✅ **Either Monad** - Functional error handling
- ✅ **Repository Pattern** - Abstract data sources
- ✅ **UseCase Pattern** - Single responsibility business logic

### 🎯 State Management
- ✅ **Riverpod 2.6** - Modern dependency injection and state management
- ✅ **Code Generation** - Type-safe providers with `riverpod_generator`
- ✅ **Freezed** - Immutable data classes with code generation

### 🔥 Firebase Integration
- ✅ **Firebase Auth** - Email/Password + Social login
- ✅ **Firebase Analytics** - User behavior tracking
- ✅ **Firebase Crashlytics** - Error monitoring
- ✅ **Cloud Messaging** - Push notifications ready

### 🌐 API & Data
- ✅ **Dio HTTP Client** - RESTful API integration
- ✅ **Token Management** - Auto-refresh with secure storage
- ✅ **Error Handling** - Centralized error management
- ✅ **DTO Pattern** - Data Transfer Objects with JSON serialization
- ✅ **Local Storage** - Secure token storage with `flutter_secure_storage`

### 🎨 UI & UX
- ✅ **Go Router** - Type-safe navigation with deep linking
- ✅ **Custom Theme** - Light/Dark mode support
- ✅ **Responsive Design** - Adaptive layouts
- ✅ **Reusable Widgets** - Shared component library
- ✅ **Image Handling** - Picker, cropper, and caching

### 🧪 Developer Experience
- ✅ **Hot Reload Support** - Fast development cycle
- ✅ **Code Generation** - Build runner for models and providers
- ✅ **Linting** - Strict analysis options
- ✅ **Testing Ready** - Architecture supports unit/widget/integration tests

---

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with three main layers:

```
┌──────────────────────────────────────────────────────┐
│            📱 PRESENTATION LAYER                      │
│  ┌────────────────────────────────────────────────┐  │
│  │  UI (Screens, Widgets)                         │  │
│  │  Controllers (Riverpod Notifiers)              │  │
│  │  State Models                                  │  │
│  └────────────────────────────────────────────────┘  │
└───────────────────┬──────────────────────────────────┘
                    │ depends on
                    ▼
┌──────────────────────────────────────────────────────┐
│            🎯 DOMAIN LAYER (CORE LOGIC)              │
│  ┌────────────────────────────────────────────────┐  │
│  │  Entities (Business Models)                    │  │
│  │  Repository Interfaces (Contracts)             │  │
│  │  UseCases (Business Rules)                     │  │
│  │  Failures (Error Types)                        │  │
│  └────────────────────────────────────────────────┘  │
└───────────────────┬──────────────────────────────────┘
                    │ implemented by
                    ▼
┌──────────────────────────────────────────────────────┐
│            💾 DATA LAYER                              │
│  ┌────────────────────────────────────────────────┐  │
│  │  DTOs (Data Transfer Objects)                  │  │
│  │  DataSources (Remote API, Local DB)            │  │
│  │  Repository Implementations                    │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### 🔄 Data Flow Example (Login Feature)

```
User Input (LoginScreen)
    ↓
LoginController.login()
    ↓
LoginUseCase.call()
    ↓
AuthRepository.login() [Interface in Domain]
    ↓
AuthRepositoryImpl.login() [Implementation in Data]
    ↓
AuthRemoteDataSource.login() [API Call]
    ↓
AuthResponseDto → AuthResponse Entity
    ↓
Either<Failure, AuthResponse>
    ↓
Update UI State
```

### 📐 Layer Responsibilities

| Layer | Responsibilities | Dependencies |
|-------|-----------------|--------------|
| **Presentation** | UI, User Interactions, State Management | Domain Layer |
| **Domain** | Business Logic, Entities, Contracts | **None** (Pure Dart) |
| **Data** | API Calls, Local Storage, DTOs | Domain Layer |

---

## 🛠️ Tech Stack

### Core
- **Flutter SDK**: 3.9.2+
- **Dart SDK**: 3.9.2+

### State Management
- `flutter_riverpod`: ^2.6.1 - State management
- `riverpod_annotation`: ^2.6.1 - Code generation for providers

### Navigation
- `go_router`: ^17.0.0 - Type-safe routing

### Firebase
- `firebase_core`: ^4.2.0
- `firebase_auth`: ^6.1.1

### Networking & Storage
- `dio`: ^5.9.0 - HTTP client
- `flutter_secure_storage`: ^9.2.4 - Secure token storage
- `shared_preferences`: Latest - Local data persistence

### Code Generation
- `freezed`: ^3.2.3 - Immutable models
- `json_serializable`: Latest - JSON serialization
- `build_runner`: Latest - Code generation runner

### UI & Media
- `image_picker`: ^1.2.0 - Camera/Gallery access
- `image_cropper`: ^11.0.0 - Image editing
- `cached_network_image`: Latest - Image caching

### Utilities
- `device_info_plus`: ^12.1.0 - Device information
- `network_info_plus`: ^7.0.0 - Network status
- `path_provider`: ^2.1.5 - File system paths

---

## 📁 Project Structure

```
lib/
├── 📄 main.dart                          # App entry point
├── 📄 firebase_options.dart              # Firebase config
│
├── ⚙️ core/                              # Core utilities (framework-agnostic)
│   ├── base/                            # Base classes
│   │   ├── base_async_notifier.dart
│   │   └── base_pagination_notifier.dart
│   ├── constants/                       # App constants
│   │   ├── api_constants.dart
│   │   ├── app_constants.dart
│   │   └── storage_constants.dart
│   ├── exceptions/                      # Custom exceptions
│   ├── theme/                           # App theme
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── utils/                           # Helper functions
│       ├── either.dart                  # Either monad
│       ├── formatters/
│       └── validators/
│
├── 🎯 domain/                            # Business logic layer
│   ├── entities/                        # Business models (pure Dart)
│   │   ├── auth/
│   │   │   ├── auth_response.dart
│   │   │   └── token.dart
│   │   └── user/
│   │       └── user.dart
│   ├── repositories/                    # Repository contracts
│   │   ├── auth_repository.dart         # abstract class
│   │   └── user_repository.dart
│   ├── usecases/                        # Business logic
│   │   ├── auth/
│   │   │   ├── login_usecase.dart
│   │   │   ├── logout_usecase.dart
│   │   │   └── refresh_token_usecase.dart
│   │   └── user/
│   │       └── get_profile_usecase.dart
│   └── failures/                        # Error types
│       └── failures.dart
│
├── 💾 data/                              # Data layer
│   ├── datasources/                     # Data sources
│   │   ├── remote/                      # API calls
│   │   │   ├── auth_remote_datasource.dart
│   │   │   └── user_remote_datasource.dart
│   │   └── local/                       # Local storage
│   │       ├── auth_local_datasource.dart
│   │       └── user_local_datasource.dart
│   ├── models/                          # DTOs (JSON ↔ Dart)
│   │   ├── auth/
│   │   │   ├── auth_response_dto.dart
│   │   │   └── token_dto.dart
│   │   └── user/
│   │       └── user_dto.dart
│   └── repositories/                    # Repository implementations
│       ├── auth_repository_impl.dart
│       └── user_repository_impl.dart
│
├── 🎨 presentation/                      # UI layer
│   ├── auth/                            # Auth feature
│   │   ├── controllers/
│   │   │   ├── auth_controller.dart
│   │   │   └── auth_state.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── widgets/                     # Feature-specific widgets
│   │       └── login_form.dart
│   └── main/                            # Main/Home feature
│       ├── controllers/
│       ├── screens/
│       └── widgets/
│
├── 🧩 shared/                            # Shared UI components
│   ├── widgets/                         # Reusable widgets
│   │   ├── buttons/
│   │   ├── inputs/
│   │   └── common/
│   ├── layouts/                         # Layout components
│   └── helpers/                         # UI helpers
│
├── 🔌 providers/                         # Riverpod providers
│   ├── datasources_provider.dart
│   ├── repositories_provider.dart
│   └── usecases_provider.dart
│
└── 🗺️ routers/                           # Navigation
    ├── app_router.dart
    ├── auth_routes.dart
    └── main_routes.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: `>=3.9.2`
- Dart SDK: `>=3.9.2`
- Android Studio / VS Code
- Git

### Quick Start

See [QUICK_START.md](QUICK_START.md) for detailed setup instructions.

```bash
# 1. Clone the repository
git clone <repository-url>
cd flutter-boilerplate

# 2. Install dependencies
flutter pub get

# 3. Generate code
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

---

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Setup and run the project
- **[CODING_GUIDE.md](CODING_GUIDE.md)** - How to implement new features
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Firebase configuration

---

## 🔧 Code Generation

This project uses code generation for:
- **Freezed**: Immutable data classes
- **JSON Serializable**: JSON serialization
- **Riverpod Generator**: Type-safe providers

### Generate code:

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on file changes)
dart run build_runner watch --delete-conflicting-outputs
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| Android  | ✅ Supported |
| iOS      | ✅ Supported |
| Web      | 🚧 In Progress |
| Desktop  | 🚧 Planned |

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

---

## 📞 Support

For questions or support, please contact the development team.

---

**Built with ❤️ using Flutter & Clean Architecture**
