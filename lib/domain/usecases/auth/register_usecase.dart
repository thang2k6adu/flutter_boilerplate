import 'package:jt291_flutter_mobile/core/utils/either.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/auth_response.dart';
import 'package:jt291_flutter_mobile/domain/failures/failures.dart';
import 'package:jt291_flutter_mobile/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call({
    required String email,
    required String password,
    String? name,
  }) async {
    final result = await repository.register(
      email: email,
      password: password,
      name: name,
    );
    
    return result.fold(
      (failure) => Left(failure),
      (authResponse) async {
        await repository.saveTokens(authResponse.tokens);
        return Right(authResponse);
      },
    );
  }
}
