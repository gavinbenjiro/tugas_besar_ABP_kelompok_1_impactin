import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api/event_api.dart';
import '../../../data/models/search_event_model.dart';

class SearchEventController extends GetxController {
  final searchController = TextEditingController();

  final isLoading = false.obs;
  final searchText = ''.obs;
  final events = <SearchEventModel>[].obs;

  final selectedCategory = 'All'.obs;

  final selectedAges = <String>[].obs;

  final categories = [
    'All',
    'Environment',
    'Education',
    'Health',
    'Community',
  ];

  final ageRanges = [
    '<16',
    '16-20',
    '21-30',
    '31-45',
    '>45',
  ];

  @override
  void onInit() {
    super.onInit();

    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading.value = true;

      final result = await EventApi.searchEvents(
        category: selectedCategory.value,
        search: searchController.text,
        ages: selectedAges,
      );

      events.assignAll(result);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    selectedCategory.value = 'All';
    selectedAges.clear();
    searchController.clear();

    fetchEvents();
  }
}
