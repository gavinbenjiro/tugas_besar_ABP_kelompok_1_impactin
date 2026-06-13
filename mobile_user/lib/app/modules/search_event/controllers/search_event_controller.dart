import 'package:dio/dio.dart';
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

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
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

  Future<void> fetchNearbyEvents() async {
    try {
      isNearbyLoading.value = true;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "Location Permission",
          "Enable location permission to see nearby events",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        nearbyEvents.clear();
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          "Location Disabled",
          "Please enable location services to see nearby events",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        nearbyEvents.clear();
        return;
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
    } on DioException catch (e) {
      print("NEARBY DIO ERROR = ${e.response?.data}");
      Get.snackbar(
        "Error",
        _extractErrorMessage(e, "Failed to load nearby events"),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on LocationServiceDisabledException catch (e) {
      print("LOCATION SERVICE DISABLED = $e");
      Get.snackbar(
        "Location Disabled",
        "Please enable location services to see nearby events",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print("NEARBY ERROR = $e");

      Get.snackbar(
        "Error",
        "Failed to get your location",
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
    } on DioException catch (e) {
      print("FETCH EVENTS DIO ERROR = ${e.response?.data}");
      Get.snackbar(
        'Error',
        _extractErrorMessage(e, 'Failed to load events'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("FETCH EVENTS ERROR = $e");
      Get.snackbar(
        'Error',
        'Something went wrong while loading events',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    try {
      selectedCategory.value = 'All';
      selectedAges.clear();
      searchController.clear();

      fetchEvents();
    } catch (e) {
      print("CLEAR FILTERS ERROR = $e");
    }
  }
}
