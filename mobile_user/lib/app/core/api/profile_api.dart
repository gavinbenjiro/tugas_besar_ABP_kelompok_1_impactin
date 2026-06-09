import 'package:dio/dio.dart';

import 'api_client.dart';

class ProfileApi {
  static Future<Response> getProfile(
    int userId,
  ) {
    return ApiClient.dio.get(
      '/user/profile/$userId',
    );
  }
}
