import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/login_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/login_with_provider_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/login_with_password_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/logout_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/auth/register_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/user/get_current_user_usecase.dart';
import 'package:jt291_flutter_mobile/domain/usecases/user/update_user_profile_usecase.dart';
import 'package:jt291_flutter_mobile/providers/repositories_provider.dart';
import 'package:jt291_flutter_mobile/providers/datasources_provider.dart';

// ============================================================================
// Auth UseCases
// ============================================================================

/// Provide LoginUseCase (for backward compatibility - direct backend login)
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Provide RegisterUseCase
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});


/// Provide LogoutUseCase (calls Repository only)
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final loginWithProviderUseCaseProvider = Provider<LoginWithProviderUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
  return LoginWithProviderUseCase(
    repository: repository,
    firebaseAuthService: firebaseAuthService,
  );
});

final loginWithPasswordUseCaseProvider = Provider<LoginWithPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
  return LoginWithPasswordUseCase(
    repository: repository,
    firebaseAuthService: firebaseAuthService,
  );
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

/// Provide UpdateUserProfileUseCase
final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUserProfileUseCase(repository);
});
