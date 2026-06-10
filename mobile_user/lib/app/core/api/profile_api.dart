// lib/app/core/api/profile_api.dart

import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class ProfileApi {
  // Helper internal untuk mengenerate header Authorization
  static Options _authOptions(String token) {
    return Options(
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<Response> getProfile({
    required String userId,
    required String token,
  }) {
    return ApiClient.dio.get(
      '${ApiEndpoints.profile}/$userId',
      options: _authOptions(token),
    );
  }

  static Future<Response> createExperience({
    required Map<String, dynamic> data,
    required String token,
  }) {
    // Menambahkan '/' di akhir sesuai dengan endpoint aslimu
    return ApiClient.dio.post(
      '${ApiEndpoints.experience}/',
      data: data,
      options: _authOptions(token),
    );
  }

  static Future<Response> updateExperience({
    required int id,
    required Map<String, dynamic> data,
    required String token,
  }) {
    return ApiClient.dio.patch(
      '${ApiEndpoints.experience}/$id',
      data: data,
      options: _authOptions(token),
    );
  }

  static Future<Response> deleteExperience({
    required int id,
    required String token,
  }) {
    return ApiClient.dio.delete(
      '${ApiEndpoints.experience}/$id',
      options: _authOptions(token),
    );
  }

  static Future<Response> updatePassword({
    required Map<String, dynamic> data,
    required String token,
  }) {
    return ApiClient.dio.patch(
      ApiEndpoints.updatePassword,
      data: data,
      options: _authOptions(token),
    );
  }
  static Future<Response> updateProfile({
    required Map<String, dynamic> data,
    required String token,
  }) {
    return ApiClient.dio.patch(
      '${ApiEndpoints.profile}/', // Trailing slash untuk handle 307
      data: data,
      options: Options(
        followRedirects: true,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}