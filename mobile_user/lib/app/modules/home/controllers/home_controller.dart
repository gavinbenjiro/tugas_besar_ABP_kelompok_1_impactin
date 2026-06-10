import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/api/event_api.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final recommendedEvents = <dynamic>[].obs;

  final events = <dynamic>[].obs;

  final isLoading = false.obs;

  final selectedCategory = 'All'.obs;
  final currentBannerIndex = 0.obs;
  final bannerPageController = PageController();

  @override
  void onInit() {
    super.onInit();
    getEvents();
    getRecommendationEvents();
  }

  Future<void> getEvents() async {
    try {
      isLoading.value = true;

      final response = await EventApi.getAllEvents();

      events.value = response.data["data"];

      print(response.data);
    } on DioException catch (e) {
      print(e.response?.data);
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

      events.value = response.data["data"];

      print(response.data);
    } on DioException catch (e) {
      print(e.response?.data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getRecommendationEvents() async {
    try {
      final response = await EventApi.getRecommendationEvents();

      recommendedEvents.value = response.data["data"];

      print(response.data);
    } on DioException catch (e) {
      print(e.response?.data);
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
