import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/event_api.dart';
import '../../../core/api/cloudinary_api.dart';

class CreateEventController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final box = GetStorage();
  final isLoading = false.obs;

  // Controllers
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final specificAddressController = TextEditingController();
  final addressLinkController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final maxParticipantController = TextEditingController();
  final descriptionController = TextEditingController();
  final termsController = TextEditingController();
  final minAgeController = TextEditingController();
  final maxAgeController = TextEditingController();
  final groupLinkController = TextEditingController();

  // =========================
  // STATE
  // =========================

  final selectedCategory = ''.obs;
  final RxnDouble latitude = RxnDouble();
  final RxnDouble longitude = RxnDouble();
  final categories = [
    "Environment",
    "Education",
    "Health",
    "Community",
  ];

  final ImagePicker _picker = ImagePicker();
  var coverImagePath = "".obs;

  // =========================
  // SNACKBAR HELPERS
  // =========================
  void _showError(String message) {
    Get.snackbar(
      "Action Failed",
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      "Success",
      message,
      backgroundColor: const Color(0xFF114B3A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  // =========================
  // METHODS
  // =========================
  Future<void> pickCoverImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        coverImagePath.value = pickedFile.path;
      }
    } catch (e) {
      _showError("Failed to access gallery: $e");
    }
  }

  Future<void> pickDate({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      }
    } catch (e) {
      _showError("Failed to open date picker.");
    }
  }

  Future<void> pickTime({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    try {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        // ignore: use_build_context_synchronously
        controller.text = picked.format(context);
      }
    } catch (e) {
      _showError("Failed to open time picker.");
    }
  }

  // Sequential Form Validation
  void _validateAllFields() {
    if (coverImagePath.value.isEmpty) throw "Please select a cover image for your event.";
    if (titleController.text.trim().isEmpty) throw "Please add the title of this event.";
    if (selectedCategory.value.isEmpty) throw "Please select an event category.";
    if (locationController.text.trim().isEmpty) throw "Please enter the location (City, Country).";
    if (specificAddressController.text.trim().isEmpty) throw "Please enter the specific address.";
    if (latitude.value == null || longitude.value == null) throw "Please pin the specific location on the map.";
    if (addressLinkController.text.trim().isEmpty) throw "Please provide an address link.";
    if (startDateController.text.trim().isEmpty) throw "Please select a start date.";
    if (endDateController.text.trim().isEmpty) throw "Please select an end date.";
    if (startTimeController.text.trim().isEmpty) throw "Please select a start time.";
    if (endTimeController.text.trim().isEmpty) throw "Please select an end time.";
    if (maxParticipantController.text.trim().isEmpty) throw "Please set the maximum number of participants.";
    if (descriptionController.text.trim().isEmpty) throw "Please provide a description for your event.";
    if (termsController.text.trim().isEmpty) throw "Please add terms & conditions for your event.";
    if (minAgeController.text.trim().isEmpty) throw "Please specify a minimum age.";
    if (maxAgeController.text.trim().isEmpty) throw "Please specify a maximum age.";

    // Custom logic check for Age
    int minAge = int.tryParse(minAgeController.text.trim()) ?? 0;
    int maxAge = int.tryParse(maxAgeController.text.trim()) ?? 0;
    if (maxAge < minAge) throw "Maximum age cannot be less than minimum age.";

    if (groupLinkController.text.trim().isEmpty) throw "Please provide a group chat link.";
  }

  void _validateDateTimeLogic() {
    try {
      final startDate = DateTime.parse(startDateController.text);
      final endDate = DateTime.parse(endDateController.text);
      final now = DateTime.now();

      final startTimeParts = startTimeController.text.split(RegExp(r'[: ]'));
      int startHour = int.parse(startTimeParts[0]);
      int startMin = int.parse(startTimeParts[1]);
      if (startTimeController.text.toLowerCase().contains("pm") &&
          startHour < 12) startHour += 12;
      if (startTimeController.text.toLowerCase().contains("am") &&
          startHour == 12) startHour = 0;

      final endTimeParts = endTimeController.text.split(RegExp(r'[: ]'));
      int endHour = int.parse(endTimeParts[0]);
      int endMin = int.parse(endTimeParts[1]);
      if (endTimeController.text.toLowerCase().contains("pm") && endHour < 12)
        endHour += 12;
      if (endTimeController.text.toLowerCase().contains("am") && endHour == 12)
        endHour = 0;

      // Validate Time if the event is today
      if (startDate.year == now.year && startDate.month == now.month && startDate.day == now.day) {
        final currentMinutes = now.hour * 60 + now.minute;
        final startMinutes = startHour * 60 + startMin;
        if (startMinutes < currentMinutes) {
          throw "Start time cannot be earlier than the current time.";
        }
      }

      // Validate End Time vs Start Time if on the same day
      if (startDate.year == endDate.year && startDate.month == endDate.month && startDate.day == endDate.day) {
        final startTotalMinutes = startHour * 60 + startMin;
        final endTotalMinutes = endHour * 60 + endMin;
        if (startTotalMinutes >= endTotalMinutes) {
          throw "Start time cannot be equal to or later than end time on the same day.";
        }
      }
    } catch (e) {
      if (e is String) rethrow;
      throw "Invalid date or time format. Please re-select.";
    }
  }

  Future<void> createEvent() async {
    try {
      isLoading.value = true;

      // 1. Validate all fields sequentially (throws exact errors)
      _validateAllFields();

      // 2. Validate deeper DateTime logic
      _validateDateTimeLogic();

      // 3. Upload Image
      String? imageUrlFromCloudinary = await CloudinaryApi.uploadImage(coverImagePath.value);
      if (imageUrlFromCloudinary == null) {
        throw "Failed to upload image to the server.";
      }

      // 4. Prepare Payload
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
        "max_participant": int.tryParse(maxParticipantController.text) ?? 0,
        "cover_image": imageUrlFromCloudinary,
        "description": descriptionController.text.trim(),
        "terms": termsController.text.trim(),
        "min_age": int.tryParse(minAgeController.text) ?? 0,
        "max_age": int.tryParse(maxAgeController.text) ?? 0,
        "group_link": groupLinkController.text.trim(),
        "latitude": latitude.value,
        "longitude": longitude.value,
      };

      // 5. API Request
      await EventApi.createEvent(body: body);

      // 6. Success Handling
      Get.back();
      _showSuccess("Event successfully created!");

    } catch (e) {
      // Any exact error message thrown above gets caught here and shown in the Snackbar
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

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
    descriptionController.dispose();
    termsController.dispose();
    minAgeController.dispose();
    maxAgeController.dispose();
    groupLinkController.dispose();
    titleController.dispose();
    locationController.dispose();
    specificAddressController.dispose();
    addressLinkController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    maxParticipantController.dispose();
    descriptionController.dispose();
    termsController.dispose();
    minAgeController.dispose();
    maxAgeController.dispose();
    groupLinkController.dispose();
    super.onClose();
  }
}
