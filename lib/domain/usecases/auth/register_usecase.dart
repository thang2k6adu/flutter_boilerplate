import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:pp191225/core/utils/either.dart';
import 'package:pp191225/data/services/firebase_auth_service.dart';
import 'package:pp191225/domain/entities/auth/auth_response.dart';
import 'package:pp191225/domain/failures/failures.dart';
import 'package:pp191225/domain/repositories/auth_repository.dart';

/// Đăng ký email/password trên Firebase, sau đó đổi Firebase ID Token
/// lấy phiên đăng nhập của backend.
class RegisterUseCase {
  final AuthRepository repository;
  final FirebaseAuthService firebaseAuthService;

  RegisterUseCase({
    required this.repository,
    required this.firebaseAuthService,
  });

  Future<Either<Failure, AuthResponse>> call({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final idToken = await firebaseAuthService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );

      final authResult = await repository.loginWithFirebase(idToken: idToken);

      return authResult.fold(
        (failure) => Left(failure),
        (authResponse) async {
          await repository.saveTokens(authResponse.tokens);
          return Right(authResponse);
        },
      );
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
