import 'package:jt291_flutter_mobile/domain/entities/auth/token.dart';
import 'package:jt291_flutter_mobile/domain/entities/users/user.dart';

/// Auth response entity - Represents authentication response in domain layer
/// Used for login/register operations
class AuthResponse {
  final User user;
  final Token tokens;

  const AuthResponse({
    required this.user,
    required this.tokens,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthResponse &&
        other.user == user &&
        other.tokens == tokens;
  }

  @override
  int get hashCode => user.hashCode ^ tokens.hashCode;

  AuthResponse copyWith({
    User? user,
    Token? tokens,
  }) {
    return AuthResponse(
      user: user ?? this.user,
      tokens: tokens ?? this.tokens,
    );
  }

  @override
  String toString() {
    return 'AuthResponse(user: $user, tokens: $tokens)';
  }
}
