import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_endpoints.dart';

class NotificationApi {
  static Future<Response> getNotifications() {
    return ApiClient.dio.get(
      ApiEndpoints.getNotifications,
    );
  }

  static Future<Response> getBellStatus() {
    return ApiClient.dio.get(
      ApiEndpoints.bellStatus,
    );
  }

  static Future<Response> markBellRead() {
    return ApiClient.dio.patch(
      ApiEndpoints.markBellRead,
    );
  }
}
