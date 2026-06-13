import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:mobile_user/app/core/api/notification_api.dart';

import '../../../core/api/event_api.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final recommendedEvents = <dynamic>[].obs;

  final events = <dynamic>[].obs;

  final isLoading = false.obs;
  final hasUnreadNotification = false.obs;
  final selectedCategory = 'All'.obs;
  final currentBannerIndex = 0.obs;
  final bannerPageController = PageController();

  @override
  void onInit() {
    super.onInit();
    getEvents();
    getRecommendationEvents();
    getBellStatus();
  }

  @override
  void onClose() {
    bannerPageController.dispose();
    super.onClose();
  }

  String _extractErrorMessage(
    DioException e,
    String fallback,
  ) {
    return e.response?.data?["message"] ??
        e.response?.data?["error"] ??
        fallback;
  }

  Future<void> getBellStatus() async {
    try {
      final response = await NotificationApi.getBellStatus();

      hasUnreadNotification.value = response.data["has_unread"] ?? false;
    } on DioException catch (e) {
      print("GET BELL STATUS ERROR: ${e.response?.data}");
      // Silent fail - notification bell status is non-critical
    } catch (e) {
      print("GET BELL STATUS ERROR: $e");
    }
  }

  Future<void> getEvents() async {
    try {
      isLoading.value = true;

      final response = await EventApi.getAllEvents();

      events.value = response.data["data"] ?? [];

      print(response.data);
    } on DioException catch (e) {
      print("GET EVENTS ERROR: ${e.response?.data}");
      Get.snackbar(
        "Error",
        _extractErrorMessage(e, "Failed to load events"),
      );
    } catch (e) {
      print("GET EVENTS ERROR: $e");
      Get.snackbar(
        "Error",
        "Something went wrong while loading events",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getEventsByCategory(
    String category,
  ) async {
    try {
      isLoading.value = true;

      final response = await EventApi.getEventsByCategory(
        category,
      );

      events.value = response.data["data"] ?? [];

      print(response.data);
    } on DioException catch (e) {
      print("GET EVENTS BY CATEGORY ERROR: ${e.response?.data}");
      Get.snackbar(
        "Error",
        _extractErrorMessage(e, "Failed to load $category events"),
      );
    } catch (e) {
      print("GET EVENTS BY CATEGORY ERROR: $e");
      Get.snackbar(
        "Error",
        "Something went wrong while loading $category events",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getRecommendationEvents() async {
    try {
      final response = await EventApi.getRecommendationEvents();

      recommendedEvents.value = response.data["data"] ?? [];

      print(response.data);
    } on DioException catch (e) {
      print("GET RECOMMENDATION EVENTS ERROR: ${e.response?.data}");
      // Silent fail - recommendations are non-critical to main flow
    } catch (e) {
      print("GET RECOMMENDATION EVENTS ERROR: $e");
    }
  }

  void changeCategory(String category) {
    selectedCategory.value = category;

    if (category == 'All') {
      getEvents();
    } else {
      getEventsByCategory(category);
    }
  }
}
