import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_endpoints.dart';

class AuthApi {
  static Future<Response> register({
    required String email,
    required String username,
    required String password,
  }) {
    return ApiClient.dio.post(
      ApiEndpoints.register,
      data: {
        "email": email,
        "username": username,
        "password": password,
      },
    );
  }

  static Future<Response> login({
    required String username,
    required String password,
  }) {
    return ApiClient.dio.post(
      ApiEndpoints.login,
      data: {
        "username": username,
        "password": password,
      },
    );
  }

  static Future<Response> saveFcmToken(String token) {
    return ApiClient.dio.post(
      ApiEndpoints.saveFcmToken,
      data: {
        "token": token,
      },
    );
  }

  static Future<Response> logout(String token) {
    return ApiClient.dio.post(
      ApiEndpoints.logout,
      data: {
        "token": token,
      },
    );
  }
}
