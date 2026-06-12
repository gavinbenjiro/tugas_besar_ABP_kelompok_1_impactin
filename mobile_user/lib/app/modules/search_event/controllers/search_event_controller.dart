import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mobile_user/app/data/models/nearby_event_model.dart';

import '../../../core/api/event_api.dart';
import '../../../data/models/search_event_model.dart';

class SearchEventController extends GetxController {
  final searchController = TextEditingController();

  final isLoading = false.obs;
  final searchText = ''.obs;
  final events = <SearchEventModel>[].obs;

  final selectedCategory = 'All'.obs;

  final selectedAges = <String>[].obs;
  final nearbyEvents = <NearbyEventModel>[].obs;

  final isNearbyLoading = false.obs;
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
    print("SEARCH INIT");
    fetchEvents();
    fetchNearbyEvents();
  }

  Future<void> fetchNearbyEvents() async {
    try {
      isNearbyLoading.value = true;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied");
      }

      final position = await Geolocator.getCurrentPosition();

      final result = await EventApi.getNearbyEvents(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      nearbyEvents.assignAll(result);

      print(
        "NEARBY COUNT = ${nearbyEvents.length}",
      );
    } catch (e) {
      print("NEARBY ERROR = $e");

      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isNearbyLoading.value = false;
    }
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
