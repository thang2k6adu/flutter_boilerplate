import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jt291_flutter_mobile/domain/entities/users/user.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// User Data Transfer Object
/// Used for JSON serialization/deserialization
@freezed
abstract class UserDto with _$UserDto {
  const UserDto._();

  const factory UserDto({
    required String id,
    required String email,
    required String name,
    String? avatar,
    @Default('user') String role,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, Object?> json) =>
      _$UserDtoFromJson(json);

  /// Convert DTO to Domain Entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      avatar: avatar,
      role: role,
    );
  }
}

/// Extension to convert Domain Entity to DTO
extension UserToDto on User {
  UserDto toDto() {
    return UserDto(
      id: id,
      email: email,
      name: name,
      avatar: avatar,
      role: role,
    );
  }
}
