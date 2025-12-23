import 'package:jt291_flutter_mobile/core/utils/either.dart';
import 'package:jt291_flutter_mobile/domain/entities/users/user.dart';
import 'package:jt291_flutter_mobile/domain/failures/failures.dart';
import 'package:jt291_flutter_mobile/domain/repositories/user_repository.dart';

/// Get current user profile use case
class GetCurrentUserUseCase {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.getCurrentUser();
  }
}
