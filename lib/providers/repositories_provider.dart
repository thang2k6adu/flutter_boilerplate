import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jt291_flutter_mobile/data/repositories/auth_repository_impl.dart';
import 'package:jt291_flutter_mobile/data/repositories/user_repository_impl.dart';
import 'package:jt291_flutter_mobile/domain/repositories/auth_repository.dart';
import 'package:jt291_flutter_mobile/domain/repositories/user_repository.dart';
import 'package:jt291_flutter_mobile/providers/datasources_provider.dart';

// ============================================================================
// Repositories
// ============================================================================

/// Provide AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Provide UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  
  return UserRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});
