import 'package:jt291_flutter_mobile/core/utils/either.dart';
import 'package:jt291_flutter_mobile/data/services/firebase_auth_service.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/auth_response.dart';
import 'package:jt291_flutter_mobile/domain/failures/failures.dart';
import 'package:jt291_flutter_mobile/domain/repositories/auth_repository.dart';

class LoginWithPasswordUseCase {
  final AuthRepository repository;
  final FirebaseAuthService firebaseAuthService;

  LoginWithPasswordUseCase({
    required this.repository,
    required this.firebaseAuthService,
  });

  Future<Either<Failure, AuthResponse>> call({
    required String username,
    required String password,
  }) async {
    try {
      final idToken = await firebaseAuthService.signInWithEmailAndPassword(
        username: username,
        password: password,
      );

      if (idToken.isEmpty) {
        return const Left(AuthFailure(message: 'Firebase sign in failed'));
      }

      final authResult = await repository.loginWithFirebase(idToken: idToken);

      return authResult.fold(
        (failure) => Left(failure),
        (authResponse) async {
          await repository.saveTokens(authResponse.tokens);
          return Right(authResponse);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
