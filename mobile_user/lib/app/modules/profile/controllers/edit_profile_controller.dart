import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/api/profile_api.dart'; // Import Profile API
import '../controllers/profile_controller.dart'; // Import ProfileController untuk refresh data setelah update

class EditProfileController extends GetxController {
  // Text Controllers
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final statusController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  final skillController = TextEditingController();
  final usernameController = TextEditingController();

  // Storage
  final box = GetStorage();

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
  // GET PROFILE (LOAD DATA ASLI)
  // ==========================================
  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);
      final userId = box.read(StorageKeys.userId);

      if (userId == null || token == null) return;

      // Panggil dari ProfileApi
      final response = await ProfileApi.getProfile(
        userId: userId.toString(),
        token: token,
      );

      final data = response.data;
      if (data is Map) {
        usernameController.text = data['username']?.toString() ?? "";
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
  // PATCH PROFILE (SAVE DATA)
  // ==========================================
  Future<void> saveProfile() async {
    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);

      if (token == null) {
        Get.snackbar('Error', 'Sesi tidak valid', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final requestBody = {
        "username": usernameController.text.trim(),
        "name": nameController.text.trim(),
        "status": statusController.text.trim(),
        "age": _calculateAge(dobController.text.trim()),
        "city": locationController.text.trim(),
        "bio": bioController.text.trim(),
        "image_url": imageUrl.value,
        "skills": skills.toList(),
      };

      // 1. Panggil API Update Profile
      await ProfileApi.updateProfile(
        data: requestBody,
        token: token,
      );

      // 2. Refresh data di ProfileController utama (halaman sebelumnya)
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfileData();
      }

      // 3. KEMBALI DULU KE PROFILE PAGE (Tutup halaman Edit)
      // closeOverlays: true memastikan jika ada dialog/snackbar yang nyangkut ikut tertutup
      Get.back(closeOverlays: true); 

      // 4. BARU TAMPILKAN SNACKBAR SAKSES
      // Snackbar ini sekarang akan muncul dengan rapi di atas halaman Profile Page
      Get.snackbar(
        'Sukses', 
        'Profil berhasil diperbarui', 
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, // Opsional: biar rapi di bawah
      );

    } on DioException catch (e) {
      String msg =
          e.response?.data?['error']?.toString() ?? "Gagal menyimpan profil";
      Get.snackbar('Gagal', msg,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // HELPER FUNCTIONS
  // ==========================================
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
        lastDate: DateTime.now()
    );
    if (picked != null) dobController.text = "${picked.day}-${picked.month}-${picked.year}";
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
    usernameController.dispose();
    nameController.dispose();
    dobController.dispose();
    statusController.dispose();
    locationController.dispose();
    bioController.dispose();
    skillController.dispose();
    super.onClose();
  }
}
