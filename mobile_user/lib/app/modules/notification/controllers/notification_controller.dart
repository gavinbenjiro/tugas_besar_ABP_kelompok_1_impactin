import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api/notification_api.dart';
import '../../../data/models/notification_model.dart';

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    fetchNotifications();
  }

  String _extractErrorMessage(
    DioException e,
    String fallback,
  ) {
    return e.response?.data?["message"] ??
        e.response?.data?["error"] ??
        fallback;
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      final response = await NotificationApi.getNotifications();

      final data = response.data["data"] as List? ?? [];

      notifications.value = data
          .map(
            (e) => NotificationModel.fromJson(e),
          )
          .toList();

      // Mark as read - non-critical, shouldn't fail the whole fetch
      try {
        await NotificationApi.markBellRead();
      } on DioException catch (e) {
        print("MARK BELL READ ERROR: ${e.response?.data}");
      } catch (e) {
        print("MARK BELL READ ERROR: $e");
      }
    } on DioException catch (e) {
      print("FETCH NOTIFICATIONS ERROR: ${e.response?.data}");
      Get.snackbar(
        "Error",
        _extractErrorMessage(e, "Failed to load notifications"),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("FETCH NOTIFICATIONS ERROR: $e");
      Get.snackbar(
        "Error",
        "Something went wrong while loading notifications",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
