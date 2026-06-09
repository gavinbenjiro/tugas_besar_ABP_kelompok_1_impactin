what to change:

C:\Users\veiro\Documents\research\tugas_besar_ABP_kelompok_1_impactin\mobile_user\lib\app\core\api

1. event_api.dart
import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_endpoints.dart';
import '../../data/models/event_model.dart';

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
}




2. api_endpoints.dart
class ApiEndpoints {
  static const register = "/user/register";
  static const login = "/user/login";
  static const getProfile = "/user/profile";

  static const getAllEvents = "/user/events";

  static String getEventDetail(int eventId) => "$getAllEvents/$eventId";

  static String getEventsByCategory(String category) =>
      "/user/events?category=$category";

  static const getRecommendationEvents = "/user/events/recommendation";

  static String getJoinedEvents(String status) =>
      "/user/events/joined?status=$status";

  static String getCreatedEvents(String status) =>
      "/user/events/your?status=$status";
  static const createEvent = "/user/events/";
}






manage_event C:\Users\veiro\Documents\research\tugas_besar_ABP_kelompok_1_impactin\mobile_user\lib\app\modules\manage_event



1. manage_event_controller.dart
import 'package:get/get.dart';

class ManageEventController extends GetxController {
  //TODO: Implement ManageEventController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}


2. manage_event_view.dart
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/manage_event_controller.dart';

class ManageEventView extends GetView<ManageEventController> {
  const ManageEventView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ManageEventView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ManageEventView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}



lets integrate the created event detail api 

PATCH http://localhost:8080/api/user/events/cancel/1
PATCH http://localhost:8080/api/user/events/close/2
PATCH http://localhost:8080/api/user/events/open/2
PATCH http://localhost:8080/api/user/events/applicants/2


