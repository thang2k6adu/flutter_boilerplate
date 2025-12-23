import 'package:jt291_flutter_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:jt291_flutter_mobile/data/models/auth/auth_response_dto.dart';
import 'package:jt291_flutter_mobile/data/models/auth/token_dto.dart';
import 'package:jt291_flutter_mobile/data/models/base/api_response.dart';
import 'package:jt291_flutter_mobile/data/services/api_service.dart';

/// Implementation of AuthRemoteDataSource using ApiService
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<ApiResponse<AuthResponseDto>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiService.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return ApiResponse<AuthResponseDto>.fromJson(
      response,
      (data) => AuthResponseDto.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<AuthResponseDto>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await apiService.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      },
    );

    return ApiResponse<AuthResponseDto>.fromJson(
      response,
      (data) => AuthResponseDto.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<AuthResponseDto>> loginWithFirebase({
    required String idToken,
    String? deviceId,
    String? platform,
  }) async {
    final response = await apiService.post(
      '/auth/firebase/login',
      data: {
        'idToken': idToken,
        if (deviceId != null) 'deviceId': deviceId,
        if (platform != null) 'platform': platform,
      },
    );

    return ApiResponse<AuthResponseDto>.fromJson(
      response,
      (data) => AuthResponseDto.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<TokenDto>> refreshToken(String refreshToken) async {
    final response = await apiService.post(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );

    return ApiResponse<TokenDto>.fromJson(
      response,
      (data) => TokenDto.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> logout() async {
    final response = await apiService.post('/auth/logout');

    // data thường null, mapper chỉ dùng khi có data
    return ApiResponse<void>.fromJson(
      response,
      (_) => null,
    );
  }
}
