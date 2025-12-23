import 'package:jt291_flutter_mobile/core/utils/either.dart';
import 'package:jt291_flutter_mobile/domain/entities/users/user.dart';
import 'package:jt291_flutter_mobile/domain/failures/failures.dart';

/// User repository interface
/// Defines the contract for user operations
/// This is implemented in the data layer
abstract class UserRepository {
  /// Get current user profile
  Future<Either<Failure, User>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? avatar,
  });

  /// Get user by ID
  Future<Either<Failure, User>> getUserById(String userId);
}
