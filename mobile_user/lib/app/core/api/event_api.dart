import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_endpoints.dart';
import '../../data/models/event_model.dart';
import '../../data/models/manage_event_model.dart';
import '../../data/models/search_event_model.dart';

class EventApi {
  static Future<Response> getAllEvents() {
    return ApiClient.dio.get(
      ApiEndpoints.getAllEvents,
    );
  }

  static Future<EventModel> getEventDetail(int eventId) async {
    try {
      final response = await ApiClient.dio.get(
        ApiEndpoints.getEventDetail(eventId),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return EventModel.fromJson(data);
      }

      throw Exception('Invalid event detail response');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load event detail',
      );
    } catch (e) {
      throw Exception('Failed to load event detail');
    }
  }

  static Future<Response> getEventsByCategory(
    String category,
  ) {
    return ApiClient.dio.get(
      ApiEndpoints.getEventsByCategory(category),
    );
  }

  static Future<Response> getRecommendationEvents() {
    return ApiClient.dio.get(
      ApiEndpoints.getRecommendationEvents,
    );
  }

  static Future<Response> getJoinedEvents(
    String status,
  ) {
    return ApiClient.dio.get(
      ApiEndpoints.getJoinedEvents(status),
    );
  }

  static Future<Response> getCreatedEvents(
    String status,
  ) {
    return ApiClient.dio.get(
      ApiEndpoints.getCreatedEvents(status),
    );
  }

  static Future<Response> createEvent({
    required Map<String, dynamic> body,
  }) {
    return ApiClient.dio.post(
      ApiEndpoints.createEvent,
      data: body,
    );
  }

  static Future<ManageEventModel> getCreatedEventDetail(
    int eventId,
  ) async {
    try {
      final response = await ApiClient.dio.get(
        ApiEndpoints.getCreatedEventDetail(
          eventId,
        ),
      );

      return ManageEventModel.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load event',
      );
    }
  }

  static Future<Response> cancelEvent(
    int eventId,
  ) {
    return ApiClient.dio.patch(
      ApiEndpoints.cancelEvent(eventId),
    );
  }

  static Future<Response> closeEvent(
    int eventId,
  ) {
    return ApiClient.dio.patch(
      ApiEndpoints.closeEvent(eventId),
    );
  }

  static Future<Response> openEvent(
    int eventId,
  ) {
    return ApiClient.dio.patch(
      ApiEndpoints.openEvent(eventId),
    );
  }

  static Future<Response> updateApplicant({
    required int applicantId,
    required int userId,
    required String action,
  }) {
    return ApiClient.dio.patch(
      ApiEndpoints.approveApplicant(applicantId),
      data: {
        "user_id": userId,
        "action": action,
      },
    );
  }

  static Future<Response> removeParticipant({
    required int participantId,
    required int userId,
  }) {
    return ApiClient.dio.delete(
      ApiEndpoints.removeParticipant(participantId),
      data: {
        "user_id": userId,
      },
    );
  }

  static Future<List<SearchEventModel>> searchEvents({
    String? category,
    String? search,
    List<String>? ages,
  }) async {
    try {
      final query = <String, dynamic>{};

      if (category != null && category.isNotEmpty && category != 'All') {
        query['category'] = category;
      }

      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }

      if (ages != null && ages.isNotEmpty) {
        query['age'] = ages;
      }

      final response = await ApiClient.dio.get(
        ApiEndpoints.getAllEvents,
        queryParameters: query,
      );

      print(response.data);

      final data = response.data['data'];

      if (data == null) {
        return [];
      }

      return (data as List)
          .map(
            (e) => SearchEventModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to load events',
      );
    }
  }

  static Future<Response> joinEvent(
    int eventId,
  ) {
    return ApiClient.dio.post(
      ApiEndpoints.joinEvent(eventId),
    );
  }

  static Future<Response> reportEvent({
    required int eventId,
    required String description,
  }) {
    return ApiClient.dio.post(
      ApiEndpoints.reportEvent(eventId),
      data: {
        "description": description,
      },
    );
  }
}
