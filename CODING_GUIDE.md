# 📚 Coding Guide - Clean Architecture Implementation

This guide demonstrates how to implement a complete feature following Clean Architecture principles in this boilerplate.

---

## 🚀 Quick Feature Flow (TL;DR)

Khi code **một feature mới**, luôn đi theo flow này:

1. **Phân tích API / requirement**
   - Xác định request, response, pagination, filter, error format (thường bọc trong `ApiResponse<T>` và/hoặc `PaginatedData<T>`).
2. **Tạo DTO ở `data/models/`**
   - Dùng `@freezed` + `*.g.dart`, map đúng JSON từ backend.
3. **Tạo DataSource ở `data/datasources/`**
   - Gọi API / local storage, trả về DTO, không chứa business logic.
4. **Tạo Entity + Repository interface + UseCase ở `domain/`**
   - Entity: pure Dart.
   - Repository interface: định nghĩa “làm gì”.
   - UseCase: chứa **toàn bộ business logic + validation** cho feature.
5. **Implement Repository ở `data/repositories/`**
   - Gọi DataSource + map DTO → Entity, **tuyệt đối không viết business logic**.
6. **Đăng ký DI ở `providers/`**
   - Nối DataSource → Repository → UseCase bằng Riverpod providers.
7. **Tạo State + Controller ở `presentation/<feature>/controllers/`**
   - State dùng `@freezed`.
   - Controller (AutoDisposeNotifier) chỉ gọi UseCase + update state, không biết Data layer.
8. **Tạo UI ở `presentation/<feature>/screens/` + `widgets/`**
   - Screen watch controller state, render UI, handle refresh/pagination/search.
9. **Chạy codegen + test**
   - `dart run build_runner build --delete-conflicting-outputs`
   - `flutter run` và test đầy đủ các flow của feature.

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Project Structure](#-project-structure)
- [Feature Example: Product Management](#-feature-example-product-management)
- [Step-by-Step Implementation](#-step-by-step-implementation)
- [Best Practices](#-best-practices)
- [Common Patterns](#-common-patterns)

---

## 🏗️ Architecture Overview

### Three Layers

```
📱 Presentation Layer (UI)
    ↓ calls
🎯 Domain Layer (Business Logic)
    ↑ implements
💾 Data Layer (Data Sources)
```

### Key Principles

1. **Domain Layer** is independent (pure Dart, no Flutter/Firebase imports)
2. **Data Layer** implements contracts from Domain
3. **Presentation Layer** only depends on Domain (UseCases)
4. **Use Either<Failure, T>** for functional error handling
5. **One UseCase = One Business Action**
6. **Repository has ZERO business logic** - chỉ call datasources và map DTO → Entity
7. **UseCase chứa ALL business logic** - validation, orchestration, rules

---

## 📁 Project Structure

```
lib/
├── assets/                     # Asset paths constants
│   ├── assets.dart
│   └── image_paths.dart
├── core/                       # Core utilities & base classes
│   ├── base/                   # Base classes for controllers
│   │   ├── base_async_notifier.dart
│   │   └── base_pagination_notifier.dart
│   ├── constants/              # App-wide constants
│   ├── exceptions/             # Custom exceptions
│   ├── mixins/                 # Reusable mixins
│   ├── theme/                  # App theme
│   └── utils/                  # Utilities (either, formatters, validators)
├── data/                       # 💾 DATA LAYER
│   ├── datasources/            # Data sources (API, local storage)
│   │   ├── local/              # Local data (SecureStorage, SQLite)
│   │   └── remote/             # Remote data (API calls)
│   ├── models/                 # DTOs (Data Transfer Objects)
│   │   ├── auth/
│   │   ├── base/
│   │   └── users/
│   ├── repositories/           # Repository implementations
│   └── services/               # External services (API, Firebase)
├── domain/                     # 🎯 DOMAIN LAYER (Pure Dart)
│   ├── entities/               # Business models
│   ├── failures/               # Failure types
│   ├── repositories/           # Repository interfaces (contracts)
│   └── usecases/               # Business logic
├── presentation/               # 📱 PRESENTATION LAYER
│   ├── auth/
│   │   ├── controllers/        # State management (Notifiers)
│   │   ├── screens/            # Pages
│   │   └── widgets/            # Feature-specific widgets
│   └── main/
│       ├── screens/
│       └── widgets/
├── providers/                  # Riverpod providers (DI)
│   ├── datasources_provider.dart
│   ├── repositories_provider.dart
│   └── usecases_provider.dart
├── routers/                    # App routing
│   ├── app_router.dart
│   ├── auth_routes.dart
│   └── home_routes.dart
├── shared/                     # Shared widgets & helpers
│   ├── components.dart
│   ├── helpers/
│   ├── layouts/
│   └── widgets/
├── firebase_options.dart
└── main.dart
```

### Layer Dependencies

```
Presentation → Domain
Data → Domain
Presentation ✗ Data (NEVER import Data in Presentation)
Domain ✗ Data (Domain knows nothing about implementations)
Domain ✗ Presentation (Domain is pure Dart)
```

---

## 🎯 Feature Example: Authentication (Email/Password + Refresh Token)

Ví dụ này bám sát kiến trúc của boilerplate và tận dụng `ApiResponse<T>`/`PaginatedData<T>` khi cần. Yêu cầu:

- ✅ Login bằng email/password
- ✅ Lưu access/refresh token, tự refresh khi hết hạn
- ✅ Lấy profile người dùng
- ✅ Logout (xóa token + state)
- ✅ Xử lý lỗi tập trung qua `Failure`

---

## 📝 Step-by-Step Implementation (Auth)

> **Flow thực tế:** Có API → tạo DTO → DataSource → Domain (Entity/Repo interface/UseCase) → Repo impl → Providers → Controller → UI → Test.

### Step 1: Phân tích API & Tạo DTOs (Data Layer)

**Giả định API**
- `POST /auth/login` body: `{ "email": "...", "password": "..." }`
- Response:
```json
{
  "error": false,
  "code": 200,
  "message": "Success",
  "data": {
    "access_token": "...",
    "refresh_token": "...",
    "user": {
      "id": "u1",
      "email": "a@b.com",
      "name": "Alice",
      "avatar": "https://...",
      "roles": ["user"]
    }
  }
}
```
- `POST /auth/refresh` body: `{ "refresh_token": "..." }`
- `GET /auth/profile` trả về `ApiResponse<User>`
- `POST /auth/logout` (tùy backend)

**DTOs**

`lib/data/models/auth/token_pair_dto.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_pair_dto.freezed.dart';
part 'token_pair_dto.g.dart';

@freezed
class TokenPairDto with _$TokenPairDto {
  const factory TokenPairDto({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _TokenPairDto;

  factory TokenPairDto.fromJson(Map<String, dynamic> json) =>
      _$TokenPairDtoFromJson(json);
}
```

`lib/data/models/auth/user_dto.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/user.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String email,
    required String name,
    String? avatar,
    @Default(<String>[]) List<String> roles,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

extension UserDtoX on UserDto {
  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        avatar: avatar,
        roles: roles,
      );
}
```

`lib/data/models/auth/auth_response_dto.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jt291_flutter_mobile/data/models/auth/token_pair_dto.dart';
import 'package:jt291_flutter_mobile/data/models/auth/user_dto.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/auth_response.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/token_pair.dart';

part 'auth_response_dto.freezed.dart';
part 'auth_response_dto.g.dart';

@freezed
class AuthResponseDto with _$AuthResponseDto {
  const factory AuthResponseDto({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    required UserDto user,
  }) = _AuthResponseDto;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);
}

extension AuthResponseDtoX on AuthResponseDto {
  AuthResponse toEntity() => AuthResponse(
        tokens: TokenPair(
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
        user: user.toEntity(),
      );
}
```

**🔨 Generate code**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 2: Remote DataSource (API)

`lib/data/datasources/remote/auth_remote_datasource.dart`
```dart
import 'package:jt291_flutter_mobile/data/models/auth/auth_response_dto.dart';
import 'package:jt291_flutter_mobile/data/models/auth/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  });

  Future<AuthResponseDto> refresh({
    required String refreshToken,
  });

  Future<UserDto> getProfile();

  Future<void> logout();
}
```

`lib/data/datasources/remote/auth_remote_datasource_impl.dart`
```dart
import 'package:dio/dio.dart';
import 'package:jt291_flutter_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:jt291_flutter_mobile/data/models/auth/auth_response_dto.dart';
import 'package:jt291_flutter_mobile/data/models/auth/user_dto.dart';
import 'package:jt291_flutter_mobile/data/models/base/api_response.dart';
import 'package:jt291_flutter_mobile/data/services/api_service.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final res = await apiService.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final parsed = ApiResponse<AuthResponseDto>.fromJson(
      res.data,
      (data) => AuthResponseDto.fromJson(data as Map<String, dynamic>),
    );
    return parsed.data!;
  }

  @override
  Future<AuthResponseDto> refresh({required String refreshToken}) async {
    final res = await apiService.dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    final parsed = ApiResponse<AuthResponseDto>.fromJson(
      res.data,
      (data) => AuthResponseDto.fromJson(data as Map<String, dynamic>),
    );
    return parsed.data!;
  }

  @override
  Future<UserDto> getProfile() async {
    final res = await apiService.dio.get('/auth/profile');
    final parsed = ApiResponse<UserDto>.fromJson(
      res.data,
      (data) => UserDto.fromJson(data as Map<String, dynamic>),
    );
    return parsed.data!;
  }

  @override
  Future<void> logout() async {
    await apiService.dio.post('/auth/logout');
  }
}
```

### Step 3: Domain Layer

**Entities** (`lib/domain/entities/auth/`)
```dart
class TokenPair {
  final String accessToken;
  final String refreshToken;
  const TokenPair({required this.accessToken, required this.refreshToken});
}

class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final List<String> roles;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.roles = const [],
  });
}

class AuthResponse {
  final TokenPair tokens;
  final User user;
  const AuthResponse({required this.tokens, required this.user});
}
```

**Repository interface** (`lib/domain/repositories/auth_repository.dart`)
```dart
import 'package:jt291_flutter_mobile/core/utils/either.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/auth_response.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/user.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/token_pair.dart';
import 'package:jt291_flutter_mobile/domain/failures/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken);

  Future<Either<Failure, User>> getProfile();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> saveTokens(TokenPair tokens);
  Future<Either<Failure, TokenPair?>> loadTokens();
  Future<Either<Failure, void>> clearTokens();
}
```

**UseCases** (`lib/domain/usecases/auth/`)

`login_usecase.dart`
```dart
class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure(message: 'Email/password is required'));
    }
    final result = await repository.login(email: email, password: password);
    return result.fold(
      (f) => Left(f),
      (auth) async {
        await repository.saveTokens(auth.tokens);
        return Right(auth);
      },
    );
  }
}
```

`refresh_token_usecase.dart`
```dart
class RefreshTokenUseCase {
  final AuthRepository repository;
  RefreshTokenUseCase(this.repository);

  Future<Either<Failure, TokenPair>> call() async {
    final loaded = await repository.loadTokens();
    return loaded.fold(
      (f) => Left(f),
      (tokens) async {
        if (tokens == null) {
          return const Left(AuthFailure(message: 'No refresh token'));
        }
        final refreshed = await repository.refreshToken(tokens.refreshToken);
        return refreshed.fold(
          (f) => Left(f),
          (auth) async {
            await repository.saveTokens(auth.tokens);
            return Right(auth.tokens);
          },
        );
      },
    );
  }
}
```

`get_profile_usecase.dart`
```dart
class GetProfileUseCase {
  final AuthRepository repository;
  GetProfileUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    return repository.getProfile();
  }
}
```

`logout_usecase.dart`
```dart
class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    await repository.logout(); // optional best-effort
    return repository.clearTokens();
  }
}
```

### Step 4: Implement Repository (Data Layer)

`lib/data/repositories/auth_repository_impl.dart`
```dart
import 'package:jt291_flutter_mobile/core/utils/either.dart';
import 'package:jt291_flutter_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/auth_response.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/user.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/token_pair.dart';
import 'package:jt291_flutter_mobile/domain/failures/failures.dart';
import 'package:jt291_flutter_mobile/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final SecureStorageService storage; // giả định đã có service lưu token

  AuthRepositoryImpl({
    required this.remote,
    required this.storage,
  });

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await remote.login(email: email, password: password);
      return Right(dto.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken) async {
    try {
      final dto = await remote.refresh(refreshToken: refreshToken);
      return Right(dto.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final dto = await remote.getProfile();
      return Right(dto.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remote.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveTokens(TokenPair tokens) async {
    try {
      await storage.writeTokens(tokens);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TokenPair?>> loadTokens() async {
    try {
      final tokens = await storage.readTokens();
      return Right(tokens);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearTokens() async {
    try {
      await storage.clearTokens();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
```

### Step 5: Setup Providers (DI)

`lib/providers/datasources_provider.dart`
```dart
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthRemoteDataSourceImpl(apiService);
});
```

`lib/providers/repositories_provider.dart`
```dart
import 'package:jt291_flutter_mobile/data/repositories/auth_repository_impl.dart';
import 'package:jt291_flutter_mobile/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final storage = ref.watch(secureStorageServiceProvider); // giả định đã có
  return AuthRepositoryImpl(remote: remote, storage: storage);
});
```

`lib/providers/usecases_provider.dart`
```dart
import 'package:jt291_flutter_mobile/domain/usecases/auth/login_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/get_profile_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/logout_usecase.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUseCase(repo);
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return RefreshTokenUseCase(repo);
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return GetProfileUseCase(repo);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repo);
});
```

### Step 6: Controller (Presentation)

`lib/presentation/auth/controllers/auth_state.dart`
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    User? user,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isRefreshing,
  }) = _AuthState;
}
```

`lib/presentation/auth/controllers/auth_controller.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/login_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/get_profile_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/logout_usecase.dart';
import 'package:jt291_flutter_mobile/presentation/auth/controllers/auth_state.dart';
import 'package:jt291_flutter_mobile/providers/usecases_provider.dart';

final authControllerProvider =
    AutoDisposeNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends AutoDisposeNotifier<AuthState> {
  late final LoginUseCase _login;
  late final RefreshTokenUseCase _refresh;
  late final GetProfileUseCase _getProfile;
  late final LogoutUseCase _logout;

  @override
  AuthState build() {
    _login = ref.read(loginUseCaseProvider);
    _refresh = ref.read(refreshTokenUseCaseProvider);
    _getProfile = ref.read(getProfileUseCaseProvider);
    _logout = ref.read(logoutUseCaseProvider);
    return const AuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _login(email: email, password: password);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (auth) => state = state.copyWith(
        isLoading: false,
        user: auth.user,
      ),
    );
  }

  Future<void> loadProfile() async {
    final result = await _getProfile();
    result.fold(
      (f) => state = state.copyWith(error: f.message),
      (user) => state = state.copyWith(user: user),
    );
  }

  Future<void> refreshToken() async {
    state = state.copyWith(isRefreshing: true);
    final result = await _refresh();
    result.fold(
      (f) => state = state.copyWith(isRefreshing: false, error: f.message),
      (_) => state = state.copyWith(isRefreshing: false),
    );
  }

  Future<void> logout() async {
    await _logout();
    state = const AuthState();
  }
}
```

### Step 7: UI (rút gọn)

`lib/presentation/auth/screens/login_screen.dart`
```dart
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            if (state.isLoading) const CircularProgressIndicator(),
            if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () => ref.read(authControllerProvider.notifier).login(
                        _emailCtrl.text,
                        _passCtrl.text,
                      ),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 8: Run & Test

```bash
# 1. Generate code (Freezed/json)
dart run build_runner build --delete-conflicting-outputs

# 2. Run app
flutter run

# 3. Test auth flows
# - Login sai → hiển thị lỗi
# - Login đúng → nhận token, user, state cập nhật
# - Refresh token (giả lập hết hạn)
# - Load profile sau login
# - Logout → clear token + state
```

---

## 🔄 Development Flow Summary

```
1. 📋 Analyze API Response (Postman/Swagger)
   ↓
2. 📦 Create DTOs with @freezed
   ├─ product_dto.dart
   ├─ product_list_dto.dart
   └─ Run: dart run build_runner build
   ↓
3. 🌐 Create Remote DataSource
   ├─ Interface (abstract class)
   ├─ Implementation (ApiService)
   └─ Test API calls (optional)
   ↓
4. 🎯 Create Domain Layer
   ├─ Entities (pure Dart)
   ├─ Repository Interface
   └─ UseCases (ALL business logic here)
   ↓
5. 🔗 Implement Repository
   └─ ZERO business logic - just call datasource + map DTO → Entity
   ↓
6. 🔌 Setup Providers
   ├─ DataSources (in datasources_provider.dart)
   ├─ Repositories (in repositories_provider.dart)
   └─ UseCases (in usecases_provider.dart)
   ↓
7. 🎮 Create Controller (AutoDisposeNotifier)
   ├─ State model (@freezed)
   ├─ Provider declaration
   └─ Controller: ONLY call UseCases + update state
   ↓
8. 🎨 Create UI Layer
   ├─ Screen (watch controller state)
   └─ Widgets
   ↓
9. ✅ Test & Debug
```

---

## ✅ Best Practices

### 1. Naming Conventions

```dart
// Entities (domain)
Product, User, Order

// DTOs (data)
ProductDto, UserDto, OrderDto

// UseCases (domain)
GetProductsUseCase, LoginUseCase

// Repositories (domain interface)
ProductRepository, AuthRepository

// Repository Implementations (data)
ProductRepositoryImpl, AuthRepositoryImpl

// DataSources (data)
ProductRemoteDataSource, AuthLocalDataSource

// Controllers (presentation)
ProductListController, AuthController

// States (presentation)
ProductListState, AuthState

// Providers (providers)
productListControllerProvider, authControllerProvider
```

### 2. Error Handling

```dart
// Always use Either<Failure, T>
Future<Either<Failure, Product>> getProduct(String id) async {
  try {
    final dto = await remoteDataSource.getProductById(id);
    return Right(dto.toEntity());
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}

// Handle in Controller
result.fold(
  (failure) => state = state.copyWith(error: failure.message),
  (product) => state = state.copyWith(product: product),
);

// Handle in UI
if (state.error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.error!)),
  );
}
```

### 3. Dependency Injection

```dart
// Use Riverpod providers in providers/ folder
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remote = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource: remote);
});

// Inject in Controller
@override
ProductListState build() {
  _getProductsUseCase = ref.read(getProductsUseCaseProvider);
  _loadProducts();
  return const ProductListState();
}
```

### 4. State Management

```dart
// Use AutoDisposeNotifier for stateful controllers
class ProductListController extends AutoDisposeNotifier<ProductListState> {
  @override
  ProductListState build() {
    // Initialize and return initial state
    return const ProductListState();
  }

  // Methods to update state
  void updateProducts(List<Product> products) {
    state = state.copyWith(products: products);
  }
}

// Provider declaration
final productListControllerProvider = 
    AutoDisposeNotifierProvider<ProductListController, ProductListState>(
  ProductListController.new,
);
```

---

## 🎯 Common Patterns

### Pattern 1: Pagination

```dart
// In Controller
Future<void> loadMore() async {
  if (!state.hasMore || state.isLoadingMore) return;

  state = state.copyWith(isLoadingMore: true);

  final result = await _getProductsUseCase.loadMore(
    currentPage: state.currentPage,
  );

  result.fold(
    (failure) => state = state.copyWith(isLoadingMore: false, error: failure.message),
    (productList) => state = state.copyWith(
      isLoadingMore: false,
      products: [...state.products, ...productList.products],
      currentPage: productList.currentPage,
      hasMore: productList.hasMore,
    ),
  );
}
```

### Pattern 2: Search with Debounce

```dart
// Use core/mixins/search_with_debounce_mixin.dart
import 'dart:async';

mixin SearchWithDebounceMixin {
  Timer? _debounce;

  void onSearchChanged(String query, Function callback) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      callback(query);
    });
  }

  void dispose() {
    _debounce?.cancel();
  }
}
```

### Pattern 3: Pull to Refresh

```dart
// In Screen
RefreshIndicator(
  onRefresh: () async {
    await ref.read(productListControllerProvider.notifier).refresh();
  },
  child: ListView(...),
)

// In Controller
Future<void> refresh() async {
  state = state.copyWith(currentPage: 1, products: []);
  await _loadProducts();
}
```

---

## 📝 Summary

### Implementation Checklist (Practical Order)

- [ ] **Step 1:** Analyze API response & create DTOs in `data/models/`
- [ ] **Step 2:** Create Remote DataSource interface & implementation in `data/datasources/remote/`
- [ ] **Step 3:** Create Entities in `domain/entities/`
- [ ] **Step 4:** Create Repository interface in `domain/repositories/`
- [ ] **Step 5:** Create UseCases in `domain/usecases/` (ALL business logic)
- [ ] **Step 6:** Implement Repository in `data/repositories/` (ZERO business logic)
- [ ] **Step 7:** Setup Providers in `providers/` (DataSources, Repositories, UseCases)
- [ ] **Step 8:** Create State model in `presentation/*/controllers/` (@freezed)
- [ ] **Step 9:** Create Controller (AutoDisposeNotifier) - ONLY call UseCases
- [ ] **Step 10:** Create Screens in `presentation/*/screens/`
- [ ] **Step 11:** Create Widgets in `presentation/*/widgets/`
- [ ] **Step 12:** Run code generation
- [ ] **Step 13:** Test the feature

### Quick Start Commands

```bash
# Create DTOs → Generate code
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on save)
dart run build_runner watch --delete-conflicting-outputs

# Clean + Rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

---

## 🎓 Key Takeaways

### Architecture Principles

1. **Domain Layer** - Pure business logic, no dependencies on external libs
2. **UseCase** - Chứa TOÀN BỘ business logic và validation
3. **Repository** - ZERO business logic, chỉ call datasource + map DTO → Entity
4. **Controller** - CHỈ gọi UseCase và update UI state
5. **Data Layer** - Handles API, database, external services
6. **Either<Failure, T>** - Functional error handling
7. **DTO → Entity** - Always convert at repository layer
8. **Freezed** - Immutable models with code generation

### Separation of Concerns

```
┌─────────────────────────────────────────────────┐
│  UI Layer (Presentation)                        │
│  ├─ Screen: Hiển thị UI + watch state          │
│  ├─ Controller: GỌI UseCase + Update State     │
│  └─ Provider: Manage lifecycle                  │
└────────────────┬────────────────────────────────┘
                 │ calls
                 ▼
┌─────────────────────────────────────────────────┐
│  Domain Layer (Business Logic)                  │
│  ├─ UseCase: TOÀN BỘ business logic + rules    │
│  ├─ Entity: Business models (pure Dart)         │
│  └─ Repository Interface: Contracts             │
└────────────────┬────────────────────────────────┘
                 │ implements
                 ▼
┌─────────────────────────────────────────────────┐
│  Data Layer (Data Sources)                      │
│  ├─ Repository Impl: ZERO logic, just mapping   │
│  ├─ DataSource: API/Database calls              │
│  ├─ DTO: JSON mapping (@freezed)                │
│  └─ Services: API, Firebase, etc.               │
└─────────────────────────────────────────────────┘
```

### UseCase vs Repository vs Controller Responsibilities

| Responsibility | UseCase ✅ | Repository ❌ | Controller ❌ |
|---------------|-----------|--------------|--------------|
| Business validation | ✅ Yes | ❌ No | ❌ No |
| Business rules | ✅ Yes | ❌ No | ❌ No |
| Pagination logic | ✅ Yes | ❌ No | ❌ No |
| Search logic | ✅ Yes | ❌ No | ❌ No |
| Orchestration | ✅ Yes | ❌ No | ❌ No |
| Call DataSource | ❌ No | ✅ Yes | ❌ No |
| Map DTO → Entity | ❌ No | ✅ Yes | ❌ No |
| Call UseCase | ❌ No | ❌ No | ✅ Yes |
| Update UI state | ❌ No | ❌ No | ✅ Yes |

**Golden Rules:** 
- **UseCase** = "What to do" (ALL Business Logic)
- **Repository** = "Where to get data" (NO Business Logic, just mapping)
- **Controller** = "How to show" (UI State Management, call UseCases)

### Real Example from This Boilerplate

```dart
// ✅ CORRECT: UseCase has business logic
class LoginWithProviderUseCase {
  Future<Either<Failure, AuthResponse>> call(ProviderLogin provider) async {
    // Business logic: handle different providers
    final String? idToken = await _handleProvider(provider);
    
    // Validation
    if (idToken == null) {
      return Left(AuthFailure(message: 'Sign in failed'));
    }
    
    // Orchestration: Firebase auth → Backend login → Save tokens
    final authResult = await repository.loginWithFirebase(idToken: idToken);
    
    return authResult.fold(
      (failure) => Left(failure),
      (response) async {
        await repository.saveTokens(response.tokens);
        return Right(response);
      },
    );
  }
}

// ✅ CORRECT: Repository has ZERO business logic
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, AuthResponse>> loginWithFirebase({
    required String idToken,
  }) async {
    try {
      final dto = await remoteDataSource.loginWithFirebase(idToken: idToken);
      return Right(dto.toEntity()); // Just mapping
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

// ✅ CORRECT: Controller ONLY calls UseCase
class AuthController extends AutoDisposeNotifier<User?> {
  Future<void> loginWithProvider(ProviderLogin provider) async {
    final result = await _loginWithProviderUseCase(provider);
    
    result.fold(
      (failure) => overlay.showError(failure.message),
      (authResponse) => state = authResponse.user,
    );
  }
}
```

---

**Happy Coding! 🚀**
