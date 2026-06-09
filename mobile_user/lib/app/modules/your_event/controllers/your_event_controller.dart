import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:mobile_user/app/data/models/your_event_model.dart';

import '../../../core/api/event_api.dart';

class YourEventController extends GetxController {
  final joinedEvents = <YourEventModel>[].obs;
  final createdEvents = <YourEventModel>[].obs;

  final isLoadingJoined = false.obs;
  final isLoadingCreated = false.obs;

  final selectedJoinedStatus = 'all'.obs;
  final selectedCreatedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();

    getJoinedEvents();
    getCreatedEvents();
  }

  Future<void> getJoinedEvents() async {
    try {
      isLoadingJoined.value = true;

      final response = await EventApi.getJoinedEvents(
        selectedJoinedStatus.value,
      );

      final List data = response.data["data"] ?? [];

      joinedEvents.value = data.map((e) => YourEventModel.fromJson(e)).toList();
    } on DioException catch (e) {
      print(e.response?.data);
    } finally {
      isLoadingJoined.value = false;
    }
  }

  Future<void> getCreatedEvents() async {
    try {
      isLoadingCreated.value = true;

      final response = await EventApi.getCreatedEvents(
        selectedCreatedStatus.value,
      );

      final List data = response.data["data"] ?? [];

      createdEvents.value =
          data.map((e) => YourEventModel.fromJson(e)).toList();
    } on DioException catch (e) {
      print(e.response?.data);
    } finally {
      isLoadingCreated.value = false;
    }
  }

  void changeJoinedStatus(String status) {
    selectedJoinedStatus.value = status;
    getJoinedEvents();
  }

  void changeCreatedStatus(String status) {
    selectedCreatedStatus.value = status;
    getCreatedEvents();
  }
}
