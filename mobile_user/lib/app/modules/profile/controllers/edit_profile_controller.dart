import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/storage/storage_keys.dart';

class EditProfileController extends GetxController {
  // Text Controllers
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final statusController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  final skillController = TextEditingController();

  // Storage & Dio
  final box = GetStorage();
  final dio = Dio();

  // Reactive State
  var skills = <String>[].obs;
  var isLoading = false.obs;
  var imageUrl = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  // ==========================================
  // API: GET PROFILE (LOAD DATA ASLI)
  // ==========================================
  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);
      final userId = box.read(StorageKeys.userId);

      if (userId == null) return;

      final response = await dio.get(
        'http://192.168.60.242:8080/api/user/profile/$userId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data;
      if (data is Map) {
        nameController.text = data['name']?.toString() ?? "";
        statusController.text = data['status']?.toString() ?? "";
        locationController.text = data['city']?.toString() ?? "";
        bioController.text = data['bio']?.toString() ?? "";
        imageUrl.value = data['image_url']?.toString() ?? "";

        // Parse Skills
        if (data['skills'] is List) {
          skills.value = (data['skills'] as List).map((item) {
            return item is Map ? item['skills'].toString() : item.toString();
          }).toList();
        }

        // Parse Age to DOB
        if (data['age'] != null) {
          int age = data['age'] is int
              ? data['age']
              : int.tryParse(data['age'].toString()) ?? 0;
          int birthYear = DateTime.now().year - age;
          dobController.text = "01-01-$birthYear";
        }
      }
    } catch (e) {
      print("ERROR FETCH: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // API: PATCH PROFILE (SAVE DATA)
  // ==========================================
  Future<void> saveProfile() async {
    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);

      final requestBody = {
        "username": box.read(StorageKeys.username) ?? "gavinbenjiro",
        "name": nameController.text.trim(),
        "status": statusController.text.trim(),
        "age": _calculateAge(dobController.text.trim()),
        "city": locationController.text.trim(),
        "bio": bioController.text.trim(),
        "image_url": imageUrl.value,
        "skills": skills.toList(),
      };

      // Tambahkan trailing slash (/) untuk mengatasi status 307
      final response = await dio.patch(
        'http://192.168.60.242:8080/api/user/profile/',
        data: requestBody,
        options: Options(
          followRedirects: true, // Memaksa ikuti redirect
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      Get.snackbar('Sukses', 'Profil berhasil diperbarui',
          backgroundColor: Colors.green, colorText: Colors.white);
      fetchProfileData(); // Refresh data
    } on DioException catch (e) {
      String msg =
          e.response?.data?['error']?.toString() ?? "Gagal menyimpan profil";
      Get.snackbar('Gagal', msg,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // HELPER FUNCTIONS
  int _calculateAge(String dobStr) {
    try {
      final parts = dobStr.split('-');
      if (parts.length == 3) return DateTime.now().year - int.parse(parts[2]);
    } catch (_) {}
    return 20;
  }

  void selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1950),
        lastDate: DateTime.now());
    if (picked != null)
      dobController.text = "${picked.day}-${picked.month}-${picked.year}";
  }

  void addSkill() {
    if (skillController.text.isNotEmpty) {
      skills.add(skillController.text.trim());
      skillController.clear();
    }
  }

  void removeSkill(String skill) => skills.remove(skill);

  @override
  void onClose() {
    nameController.dispose();
    dobController.dispose();
    statusController.dispose();
    locationController.dispose();
    bioController.dispose();
    skillController.dispose();
    super.onClose();
  }
}
