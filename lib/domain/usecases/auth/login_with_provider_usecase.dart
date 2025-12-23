import 'package:jt291_flutter_mobile/core/utils/either.dart';
import 'package:jt291_flutter_mobile/data/services/firebase_auth_service.dart';
import 'package:jt291_flutter_mobile/domain/entities/auth/auth_response.dart';
import 'package:jt291_flutter_mobile/domain/failures/failures.dart';
import 'package:jt291_flutter_mobile/domain/repositories/auth_repository.dart';

enum ProviderLogin { google, facebook, apple }

class LoginWithProviderUseCase {
  final AuthRepository repository;
  final FirebaseAuthService firebaseAuthService;

  LoginWithProviderUseCase({
    required this.repository,
    required this.firebaseAuthService,
  });

  Future<Either<Failure, AuthResponse>> call(ProviderLogin provider) async {
    try {
      final String? idToken;

      switch (provider) {
        case ProviderLogin.google:
          idToken = await firebaseAuthService.signInWithGoogle();
          break;
        case ProviderLogin.facebook:
          return const Left(ServerFailure(message: 'Facebook login not implemented yet'));
        case ProviderLogin.apple:
          return const Left(ServerFailure(message: 'Apple login not implemented yet'));
      }

      if (idToken == null || idToken.isEmpty) {
        return const Left(AuthFailure(message: 'Provider sign in failed'));
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
