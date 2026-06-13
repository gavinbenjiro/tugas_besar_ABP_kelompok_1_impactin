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

  // ==========================================
  // ADD EXPERIENCE (POST)
  // ==========================================
  static Future<Response> addExperience({
    required Map<String, dynamic> data,
    required String token,
  }) {
    return ApiClient.dio.post(
      '${ApiEndpoints.experience}/', // Pastikan slash-nya sesuai kebutuhan backend
      data: data, // Ini adalah JSON
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // WAJIB ada ini untuk backend Golang
        },
      ),
    );
  }

  // ==========================================
  // EDIT EXPERIENCE (PATCH)
  // ==========================================
  static Future<Response> editExperience({
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

  // ==========================================
  // DELETE EXPERIENCE (DELETE)
  // ==========================================
  static Future<Response> deleteExperience({
    required int id,
    required String token,
  }) {
    return ApiClient.dio.delete(
      '${ApiEndpoints.experience}/$id',
      options: _authOptions(token),
    );
  }

  // ==========================================
  // UPDATE PASSWORD (PATCH)
  // ==========================================
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

  // ==========================================
  // UPDATE PROFILE (PATCH)
  // ==========================================
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
