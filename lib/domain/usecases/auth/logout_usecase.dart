import 'package:jt291_flutter_mobile/core/utils/either.dart';
import 'package:jt291_flutter_mobile/domain/failures/failures.dart';
import 'package:jt291_flutter_mobile/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      await repository.logout();
      
      final clearResult = await repository.clearTokens();
      
      return clearResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      await repository.clearTokens();
      return const Right(null);
    }
  }
}
