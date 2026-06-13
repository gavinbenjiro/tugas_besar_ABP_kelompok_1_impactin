import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  String _extractErrorMessage(
    DioException e,
    String fallback,
  ) {
    if (e.response?.data is Map) {
      return e.response?.data?['message']?.toString() ??
          e.response?.data?['error']?.toString() ??
          fallback;
    } else if (e.response?.data is String) {
      return e.response!.data;
    }
    return fallback;
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
      print("GET JOINED EVENTS ERROR: ${e.response?.data}");
      Get.snackbar(
        "Error",
        _extractErrorMessage(e, "Failed to load joined events"),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("GET JOINED EVENTS ERROR: $e");
      Get.snackbar(
        "Error",
        "Something went wrong while loading joined events",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      print("GET CREATED EVENTS ERROR: ${e.response?.data}");
      Get.snackbar(
        "Error",
        _extractErrorMessage(e, "Failed to load created events"),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("GET CREATED EVENTS ERROR: $e");
      Get.snackbar(
        "Error",
        "Something went wrong while loading created events",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCreated.value = false;
    }
  }

  void changeJoinedStatus(String status) {
    try {
      selectedJoinedStatus.value = status;
      getJoinedEvents();
    } catch (e) {
      print("CHANGE JOINED STATUS ERROR: $e");
    }
  }

  void changeCreatedStatus(String status) {
    try {
      selectedCreatedStatus.value = status;
      getCreatedEvents();
    } catch (e) {
      print("CHANGE CREATED STATUS ERROR: $e");
    }
  }
}
