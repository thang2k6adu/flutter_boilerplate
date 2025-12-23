import 'package:jt291_flutter_mobile/core/utils/either.dart';
import 'package:jt291_flutter_mobile/domain/entities/users/user.dart';
import 'package:jt291_flutter_mobile/domain/failures/failures.dart';
import 'package:jt291_flutter_mobile/domain/repositories/user_repository.dart';

/// Update user profile use case
class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, User>> call({
    String? name,
    String? avatar,
  }) {
    return repository.updateProfile(name: name, avatar: avatar);
  }
}
