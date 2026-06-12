import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/api/profile_api.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/cloudinary_api.dart';

class ProfileController extends GetxController {
  final box = GetStorage();

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

  var skills = <dynamic>[].obs;
  var experiences = <dynamic>[].obs;
  var events = <dynamic>[].obs;

  final ImagePicker _picker = ImagePicker();
  var expImagePath = "".obs;

  // ==========================================
  // CONTROLLERS & STATE FOR EXPERIENCE FORM
  // ==========================================
  final expTitleController = TextEditingController();
  final expHostController = TextEditingController();
  final expDateController = TextEditingController();
  final expDescController = TextEditingController();
  var expImageUrl = "https://example.com/gamagudabo.jpg".obs;

  // Password Controllers
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  @override
  void onInit() {
    print("ON INIT CALLED");
    super.onInit();
    fetchProfileData();
  }

  // ==========================================
  // IMAGE PICKER
  // ==========================================
  Future<void> pickExperienceImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, // Langsung buka galeri saja biar cepat
        imageQuality: 70,
      );

      if (pickedFile != null) {
        expImagePath.value = pickedFile.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengakses galeri', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ==========================================
  // GET PROFILE FROM API
  // ==========================================
  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);
      final userId = box.read(StorageKeys.userId);

      if (userId == null || token == null) {
        Get.snackbar('Error', 'Sesi tidak valid. Silakan login kembali.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      // Gunakan ProfileApi
      final response = await ProfileApi.getProfile(
        userId: userId.toString(),
        token: token,
      );

      final data = response.data;

      if (data is Map) {
        name.value = data['name']?.toString() ?? "";
        status.value = data['status']?.toString() ?? "";
        city.value = data['city']?.toString() ?? "";
        bio.value = data['bio']?.toString() ?? "";

        if (data['age'] != null) {
          age.value = data['age'] is int
              ? data['age']
              : int.tryParse(data['age'].toString()) ?? 0;
        }

        if (data['image_url'] != null) {
          imageUrl.value = data['image_url'].toString();
        }

        skills.value = (data['skills'] is List) ? data['skills'] : [];
        experiences.value = (data['experiences'] is List) ? data['experiences'] : [];
        events.value = (data['events'] is List) ? data['events'] : [];
      }
    } on DioException catch (e) {
      print("GET PROFILE ERROR STATUS: ${e.response?.statusCode}");
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
    expImagePath.value = "";

    if (exp != null) {
      // Mode Edit
      expTitleController.text = exp['title'] ?? '';
      // Gunakan 'host_name' sesuai dengan yang disimpan di database
      expHostController.text = exp['host_name'] ?? '';
      expDescController.text = exp['description'] ?? '';
      expDateController.text = exp['date']?.toString() ?? '';
    } else {
      // Mode Add
      expTitleController.clear();
      expHostController.clear();
      expDescController.clear();
      expDateController.clear();
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
      if (token == null) return;

      String? imageUrlFromCloudinary;
      if (expImagePath.value.isNotEmpty) {
        imageUrlFromCloudinary = await CloudinaryApi.uploadImage(expImagePath.value);
        if (imageUrlFromCloudinary == null) {
          Get.snackbar('Gagal', 'Upload gambar gagal', backgroundColor: Colors.red);
          isLoading.value = false;
          return;
        }
      }

      // UBAH "creator" MENJADI "host_name"
      final Map<String, dynamic> requestBody = {
        "title": expTitleController.text.trim(),
        "host_name": expHostController.text.trim(),
        "date": expDateController.text.trim(),
        "description": expDescController.text.trim(),
      };

      if (imageUrlFromCloudinary != null) {
        requestBody["cover_image"] = imageUrlFromCloudinary;
      }

      if (id == null) {
        await ProfileApi.addExperience(data: requestBody, token: token);
      } else {
        await ProfileApi.editExperience(id: id, data: requestBody, token: token);
      }

      fetchProfileData();
      Get.back();
      Get.snackbar('Sukses', 'Experience berhasil disimpan', backgroundColor: Colors.green);
    } catch (e) {
      print("ERROR DETAIL: $e");
      Get.snackbar('Gagal', 'Periksa terminal untuk detail error', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // LOGIC: DELETE EXPERIENCE
  // ==========================================
  Future<void> deleteExperience(int id) async {
    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);

      await ProfileApi.deleteExperience(id: id, token: token);

      await fetchProfileData();

      Get.snackbar('Sukses', 'Experience berhasil dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
    } on DioException catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus experience',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // LOGIC: UPDATE PASSWORD
  // ==========================================
  Future<void> updatePassword() async {
    if (newPassController.text != confirmPassController.text) {
      Get.snackbar('Error', 'Password baru dan konfirmasi tidak sama',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);

      await ProfileApi.updatePassword(
        data: {
          "old_password": oldPassController.text.trim(),
          "new_password": newPassController.text.trim(),
        },
        token: token,
      );

      Get.back();
      Get.snackbar('Sukses', 'Password berhasil diubah',
          backgroundColor: Colors.green, colorText: Colors.white);

      oldPassController.clear();
      newPassController.clear();
      confirmPassController.clear();
    } on DioException catch (e) {
      String errorMessage = 'Gagal mengubah password';
      if (e.response?.data != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      } else if (e.response?.data is String) {
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
}
