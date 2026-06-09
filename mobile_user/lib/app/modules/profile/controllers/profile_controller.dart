import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../../../core/storage/storage_keys.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  final dio = Dio();

  // ==========================================
  // REACTIVE STATE (PROFILE DATA)
  // ==========================================
  var isLoading = true.obs;

  var name = ''.obs;
  var status = ''.obs;
  var age = 0.obs;
  var city = ''.obs;
  var bio = ''.obs;
  var imageUrl = ''.obs;

  // Lists for dynamic sections
  var skills = <dynamic>[].obs;
  var experiences = <dynamic>[].obs;
  var events = <dynamic>[].obs;

  // ==========================================
  // CONTROLLERS & STATE FOR EXPERIENCE FORM
  // ==========================================
  final expTitleController = TextEditingController();
  final expHostController = TextEditingController();
  final expDateController = TextEditingController();
  final expDescController = TextEditingController();
  var expImageUrl = "https://example.com/gamagudabo.jpg".obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  // ==========================================
  // GET PROFILE FROM API
  // ==========================================
  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);
      final userId = box.read(StorageKeys.userId);

      if (userId == null) {
        Get.snackbar('Error', 'User ID tidak ditemukan. Silakan login kembali.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      final response = await dio.get(
        'http://172.23.240.1:8080/api/user/profile/$userId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data;

      if (data is Map) {
        name.value = data['name']?.toString() ?? "";
        status.value = data['status']?.toString() ?? "";
        city.value = data['city']?.toString() ?? "";
        bio.value = data['bio']?.toString() ?? "";

        // Parse Age safely
        if (data['age'] != null) {
          age.value = data['age'] is int
              ? data['age']
              : int.tryParse(data['age'].toString()) ?? 0;
        }

        if (data['image_url'] != null) {
          imageUrl.value = data['image_url'].toString();
        }

        // Parse Skills
        if (data['skills'] != null && data['skills'] is List) {
          skills.value = data['skills'];
        } else {
          skills.clear();
        }

        // Parse Experiences
        if (data['experiences'] != null && data['experiences'] is List) {
          experiences.value = data['experiences'];
        } else {
          experiences.clear();
        }

        // Parse Events
        if (data['events'] != null && data['events'] is List) {
          events.value = data['events'];
        } else {
          events.clear();
        }
      }
    } on DioException catch (e) {
      print("GET PROFILE ERROR STATUS: ${e.response?.statusCode}");
      print("GET PROFILE ERROR BODY: ${e.response?.data}");
      Get.snackbar('Gagal Memuat Profil', 'Gagal menarik data dari server',
          backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      print("ERROR FETCHING PROFILE: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // LOGIC: OPEN EXPERIENCE FORM DIALOG
  // ==========================================
  void openExperienceForm({Map<String, dynamic>? exp}) {
    if (exp != null) {
      // Setup untuk Edit Experience
      expTitleController.text = exp['title']?.toString() ?? "";

      // Mapping 'creator' dari GET ke 'host_name' untuk PATCH
      expHostController.text = exp['creator']?.toString() ?? exp['host_name']?.toString() ?? "";

      // Handle Date Format (ambil YYYY-MM-DD saja)
      String date = exp['date']?.toString() ?? "";
      if (date.length >= 10) date = date.substring(0, 10);
      expDateController.text = date;

      expDescController.text = exp['description']?.toString() ?? "";
      expImageUrl.value = exp['cover_image']?.toString() ?? "https://example.com/gamagudabo.jpg";
    } else {
      // Setup untuk Add Experience baru
      expTitleController.clear();
      expHostController.clear();
      expDateController.clear();
      expDescController.clear();
      expImageUrl.value = "https://example.com/gamagudabo.jpg"; // Default image
    }
  }

  // ==========================================
  // LOGIC: SELECT DATE FOR EXPERIENCE
  // ==========================================
  Future<void> selectExpDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF114B3A)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Format ke YYYY-MM-DD
      expDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // ==========================================
  // LOGIC: SAVE EXPERIENCE (POST / PATCH)
  // ==========================================
  Future<void> saveExperience({int? id}) async {
    try {
      isLoading.value = true;

      final token = box.read(StorageKeys.token);

      final url = id == null
          ? 'http://172.23.240.1:8080/api/user/profile/experience/'
          : 'http://172.23.240.1:8080/api/user/profile/experience/$id';

      final body = {
        "title": expTitleController.text.trim(),
        "host_name": expHostController.text.trim(),
        "date": expDateController.text.trim(),
        "description": expDescController.text.trim(),
        "cover_image": expImageUrl.value,
      };

      print("EXP URL: $url");
      print("EXP BODY: $body");

      final response = id == null
          ? await dio.post(
        url,
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      )
          : await dio.patch(
        url,
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      print("SUCCESS STATUS: ${response.statusCode}");
      print("SUCCESS BODY: ${response.data}");

      Get.back();
      await fetchProfileData();

      Get.snackbar(
        'Sukses',
        'Experience berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } on DioException catch (e) {
      print("ERROR STATUS: ${e.response?.statusCode}");
      print("ERROR DATA: ${e.response?.data}");
      print("ERROR LOCATION: ${e.response?.headers.value('location')}");

      Get.snackbar(
        'Gagal',
        e.response?.data.toString() ?? 'Gagal menyimpan experience',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> deleteExperience(int id) async {
    try {
      isLoading.value = true;

      final token = box.read(StorageKeys.token);

      final response = await dio.delete(
        'http://172.23.240.1:8080/api/user/profile/experience/$id',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      print("DELETE STATUS: ${response.statusCode}");
      print("DELETE BODY: ${response.data}");

      await fetchProfileData();

      Get.snackbar(
        'Sukses',
        'Experience berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on DioException catch (e) {
      print("DELETE STATUS: ${e.response?.statusCode}");
      print("DELETE BODY: ${e.response?.data}");

      Get.snackbar(
        'Gagal',
        'Gagal menghapus experience',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  // 1. Tambahkan controllers untuk password
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

// 2. Tambahkan method untuk update password
  Future<void> updatePassword() async {
    if (newPassController.text != confirmPassController.text) {
      Get.snackbar('Error', 'Password baru dan konfirmasi tidak sama',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);

      // 1. GANTI .post menjadi .patch
      final response = await dio.patch(
        'http://172.23.240.1:8080/api/user/profile/password',
        data: {
          "old_password": oldPassController.text.trim(),
          "new_password": newPassController.text.trim(),
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      Get.back();
      Get.snackbar('Sukses', 'Password berhasil diubah',
          backgroundColor: Colors.green, colorText: Colors.white);

      oldPassController.clear();
      newPassController.clear();
      confirmPassController.clear();

    } on DioException catch (e) {
      // 2. PERBAIKAN LOGIC ERROR HANDLING
      String errorMessage = 'Gagal mengubah password';

      // Cek apakah response data adalah Map/JSON
      if (e.response?.data != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      // Cek apakah response data adalah String (biasanya saat error 404/500 dari server)
      else if (e.response?.data is String) {
        errorMessage = e.response!.data;
      }

      Get.snackbar('Gagal', errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    expTitleController.dispose();
    expHostController.dispose();
    expDateController.dispose();
    expDescController.dispose();
    oldPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.onClose();
  }
  void showDeleteExperienceDialog(int id) {
    Get.defaultDialog(
      title: "Hapus Experience",
      middleText: "Yakin ingin menghapus experience ini?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        deleteExperience(id);
      },
    );
  }
}