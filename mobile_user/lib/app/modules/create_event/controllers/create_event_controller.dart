import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/api/event_api.dart';
import '../../../core/api/cloudinary_api.dart';

class CreateEventController extends GetxController {
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

  final isLoading = false.obs;

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
      Get.snackbar('Error', 'Gagal mengakses galeri', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickDate({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
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
  }

  Future<void> pickTime({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      // ignore: use_build_context_synchronously
      controller.text = picked.format(context);
    }
  }

  bool _validateDateTime() {
    if (startDateController.text.isEmpty || endDateController.text.isEmpty || startTimeController.text.isEmpty || endTimeController.text.isEmpty) {
      Get.snackbar("Error", "Tanggal dan waktu harus diisi lengkap", backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    try {
      final startDate = DateTime.parse(startDateController.text);
      final endDate = DateTime.parse(endDateController.text);
      final now = DateTime.now();

      final startTimeParts = startTimeController.text.split(RegExp(r'[: ]'));
      int startHour = int.parse(startTimeParts[0]);
      int startMin = int.parse(startTimeParts[1]);
      if (startTimeController.text.toLowerCase().contains("pm") && startHour < 12) startHour += 12;
      if (startTimeController.text.toLowerCase().contains("am") && startHour == 12) startHour = 0;

      final endTimeParts = endTimeController.text.split(RegExp(r'[: ]'));
      int endHour = int.parse(endTimeParts[0]);
      int endMin = int.parse(endTimeParts[1]);
      if (endTimeController.text.toLowerCase().contains("pm") && endHour < 12) endHour += 12;
      if (endTimeController.text.toLowerCase().contains("am") && endHour == 12) endHour = 0;

      if (startDate.year == now.year && startDate.month == now.month && startDate.day == now.day) {
        final currentMinutes = now.hour * 60 + now.minute;
        final startMinutes = startHour * 60 + startMin;
        if (startMinutes < currentMinutes) {
          Get.snackbar("Waktu Tidak Valid", "Waktu mulai tidak boleh kurang dari jam saat ini.", backgroundColor: Colors.red, colorText: Colors.white);
          return false;
        }
      }

      if (startDate.year == endDate.year && startDate.month == endDate.month && startDate.day == endDate.day) {
        final startTotalMinutes = startHour * 60 + startMin;
        final endTotalMinutes = endHour * 60 + endMin;
        if (startTotalMinutes >= endTotalMinutes) {
          Get.defaultDialog(
            title: "Peringatan Waktu",
            titleStyle: const TextStyle(fontWeight: FontWeight.bold),
            middleText: "Waktu mulai tidak boleh sama dengan atau lebih besar dari waktu selesai di hari yang sama.",
            textConfirm: "Oke, Paham",
            confirmTextColor: Colors.white,
            buttonColor: const Color(0xFF0B5D51),
            onConfirm: () => Get.back(),
          );
          return false;
        }
      }
      return true;
    } catch (e) {
      Get.snackbar("Error", "Format waktu/tanggal salah", backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  Future<void> createEvent() async {
    if (!_validateDateTime()) return;
    if (coverImagePath.value.isEmpty) {
      Get.snackbar('Error', 'Silakan pilih cover image terlebih dahulu', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      String? imageUrlFromCloudinary = await CloudinaryApi.uploadImage(coverImagePath.value);
      if (imageUrlFromCloudinary == null) {
        Get.snackbar('Gagal', 'Upload gambar ke server gagal', backgroundColor: Colors.red, colorText: Colors.white);
        isLoading.value = false;
        return;
      }

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

      await EventApi.createEvent(body: body);

      Get.back();
      Get.snackbar("Success", "Event successfully created", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Gagal membuat event: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose(); locationController.dispose(); specificAddressController.dispose(); addressLinkController.dispose();
    startDateController.dispose(); endDateController.dispose(); startTimeController.dispose(); endTimeController.dispose();
    maxParticipantController.dispose(); descriptionController.dispose(); termsController.dispose(); minAgeController.dispose();
    maxAgeController.dispose(); groupLinkController.dispose();
    super.onClose();
  }
}