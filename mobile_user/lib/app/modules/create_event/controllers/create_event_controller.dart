import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_user/app/core/api/event_api.dart';
import '../../../routes/app_pages.dart';

class CreateEventController extends GetxController {
  // =========================
  // FORM CONTROLLERS
  // =========================

  final titleController = TextEditingController();

  final locationController = TextEditingController();

  final specificAddressController = TextEditingController();

  final addressLinkController = TextEditingController();

  final startDateController = TextEditingController();

  final endDateController = TextEditingController();

  final startTimeController = TextEditingController();

  final endTimeController = TextEditingController();

  final maxParticipantController = TextEditingController();

  final coverImageController = TextEditingController();

  final descriptionController = TextEditingController();

  final termsController = TextEditingController();

  final minAgeController = TextEditingController();

  final maxAgeController = TextEditingController();

  final groupLinkController = TextEditingController();

  // =========================
  // STATE
  // =========================

  final isLoading = false.obs;

  final selectedCategory = ''.obs;
  final RxnDouble latitude = RxnDouble();
  final RxnDouble longitude = RxnDouble();
  final categories = [
    'Environment',
    'Health',
    'Education',
    'Community',
  ];

  // =========================
  // CREATE EVENT
  // =========================

  Future<void> createEvent() async {
    try {
      isLoading.value = true;

      final body = {
        "title": titleController.text.trim(),
        "category": selectedCategory.value,
        "location": locationController.text.trim(),
        "specific_address": specificAddressController.text.trim(),
        "address_link": addressLinkController.text.trim(),
        "start_date": startDateController.text.trim(),
        "end_date": endDateController.text.trim(),
        "start_time": startTimeController.text.trim(),
        "end_time": endTimeController.text.trim(),
        "max_participant": int.tryParse(
              maxParticipantController.text,
            ) ??
            0,
        "cover_image": coverImageController.text.trim(),
        "description": descriptionController.text.trim(),
        "terms": termsController.text.trim(),
        "min_age": int.tryParse(
              minAgeController.text,
            ) ??
            0,
        "max_age": int.tryParse(
              maxAgeController.text,
            ) ??
            0,
        "group_link": groupLinkController.text.trim(),
        "latitude": latitude.value,
        "longitude": longitude.value,
      };

      final response = await EventApi.createEvent(
        body: body,
      );

      Get.snackbar(
        "Success",
        "Event successfully created, waiting for approval",
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        backgroundColor: const Color(0xFF114B3A),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      Get.offAllNamed(Routes.YOUR_EVENT);
    } on DioException catch (e) {
      print("STATUS = ${e.response?.statusCode}");
      print("DATA = ${e.response?.data}");

      Get.snackbar(
        "Error",
        e.response?.data.toString() ?? "Failed to create event",
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // DATE PICKER
  // =========================

  Future<void> pickDate({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      controller.text =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
  }

  // =========================
  // TIME PICKER
  // =========================

  Future<void> pickTime({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      controller.text =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void onClose() {
    titleController.dispose();
    locationController.dispose();
    specificAddressController.dispose();
    addressLinkController.dispose();

    startDateController.dispose();
    endDateController.dispose();

    startTimeController.dispose();
    endTimeController.dispose();

    maxParticipantController.dispose();

    coverImageController.dispose();

    descriptionController.dispose();
    termsController.dispose();

    minAgeController.dispose();
    maxAgeController.dispose();

    groupLinkController.dispose();

    super.onClose();
  }
}
