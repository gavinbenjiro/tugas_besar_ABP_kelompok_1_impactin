import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobile_user/app/core/api/auth_api.dart';
import 'package:mobile_user/app/routes/app_pages.dart';
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
  var isYou = true.obs;
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
    } on PlatformException catch (e) {
      print("PICK IMAGE PLATFORM ERROR: ${e.message}");
      Get.snackbar('Error', 'Tidak dapat mengakses galeri',
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("PICK IMAGE ERROR: $e");
      Get.snackbar('Error', 'Gagal mengakses galeri',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ==========================================
  // GET PROFILE FROM API
  // ==========================================
  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);

      final argUserId = Get.arguments;
      final userId = argUserId != null
          ? argUserId.toString()
          : box.read(StorageKeys.userId)?.toString();

      if (userId == null || token == null) {
        Get.snackbar('Error', 'Sesi tidak valid. Silakan login kembali.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      final response =
          await ProfileApi.getProfile(userId: userId, token: token);
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
        experiences.value =
            (data['experiences'] is List) ? data['experiences'] : [];
        events.value = (data['events'] is List) ? data['events'] : [];
        isYou.value = data['is_you'] ?? true;
      }
    } on DioException catch (e) {
      print("FETCH PROFILE ERROR: ${e.response?.data}");
      Get.snackbar(
        'Gagal Memuat Profil',
        _extractErrorMessage(e, 'Gagal menarik data dari server'),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print("ERROR FETCHING PROFILE: $e");
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat profil',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // LOGIC: OPEN EXPERIENCE FORM DIALOG
  // ==========================================
  var existingImageUrl = "".obs;
  void openExperienceForm({Map<String, dynamic>? exp}) {
    try {
      expImagePath.value = "";

      if (exp != null) {
        // Mode Edit
        existingImageUrl.value = exp['cover_image'] ?? "";
        expTitleController.text = exp['title'] ?? '';

        // --- PERBAIKAN DI SINI ---
        // Kita cek 'host_name' dulu, jika null, ambil 'creator'
        expHostController.text = exp['host_name'] ?? exp['creator'] ?? '';

        expDescController.text = exp['description'] ?? '';

        // Sanitasi tanggal
        String rawDate = exp['date']?.toString() ?? '';
        if (rawDate.contains('T')) {
          expDateController.text = rawDate.split('T')[0];
        } else {
          expDateController.text = rawDate;
          existingImageUrl.value = "";
        }
      } else {
        expTitleController.clear();
        expHostController.clear();
        expDescController.clear();
        expDateController.clear();
        existingImageUrl.value = "";
      }
    } catch (e) {
      print("OPEN EXPERIENCE FORM ERROR: $e");
      Get.snackbar('Error', 'Gagal membuka form experience',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ==========================================
  // LOGIC: SELECT DATE FOR EXPERIENCE
  // ==========================================
  Future<void> selectExpDate(BuildContext context) async {
    try {
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
        expDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      }
    } catch (e) {
      print("SELECT DATE ERROR: $e");
      Get.snackbar('Error', 'Gagal memilih tanggal',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ==========================================
  // LOGIC: SAVE EXPERIENCE (POST / PATCH)
  // ==========================================
  Future<void> saveExperience({int? id}) async {
    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);

      if (token == null) {
        Get.snackbar('Error', 'Sesi tidak valid. Silakan login kembali.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      // Basic validation
      if (expTitleController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Judul experience tidak boleh kosong',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      if (expDateController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Tanggal tidak boleh kosong',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      // 1. Tentukan gambar mana yang akan dikirim
      String? imageUrlToSend;

      if (expImagePath.value.isNotEmpty) {
        // Jika ada file baru, upload ke Cloudinary
        try {
          imageUrlToSend = await CloudinaryApi.uploadImage(expImagePath.value);

          if (imageUrlToSend == null) {
            Get.snackbar('Gagal', 'Upload gambar gagal',
                backgroundColor: Colors.red, colorText: Colors.white);
            return;
          }
        } on DioException catch (e) {
          print("UPLOAD EXPERIENCE IMAGE ERROR: ${e.response?.data}");
          Get.snackbar(
            'Gagal',
            'Gagal mengunggah gambar: ${_extractErrorMessage(e, "kesalahan jaringan")}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        } catch (e) {
          print("UPLOAD EXPERIENCE IMAGE ERROR: $e");
          Get.snackbar('Gagal', 'Gagal mengunggah gambar',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      } else {
        // Jika TIDAK ada file baru, gunakan link gambar lama (existing)
        // Jika sebelumnya tidak ada gambar, maka hasilnya tetap null
        imageUrlToSend =
            existingImageUrl.value.isNotEmpty ? existingImageUrl.value : null;
      }

      // 2. Siapkan data body
      String cleanDate = expDateController.text.trim();
      if (cleanDate.contains('T')) {
        cleanDate = cleanDate.split('T')[0];
      }

      final Map<String, dynamic> requestBody = {
        "title": expTitleController.text.trim(),
        "host_name": expHostController.text.trim(),
        "date": cleanDate,
        "description": expDescController.text.trim(),
        "cover_image": imageUrlToSend, // Kirim URL (baru atau lama)
      };

      // 3. Panggil API
      if (id == null) {
        await ProfileApi.addExperience(data: requestBody, token: token);
      } else {
        await ProfileApi.editExperience(
            id: id, data: requestBody, token: token);
      }

      await fetchProfileData();
      Get.back();
      Get.snackbar('Sukses', 'Experience berhasil disimpan',
          backgroundColor: Colors.green, colorText: Colors.white);
    } on DioException catch (e) {
      print("SAVE EXPERIENCE ERROR: ${e.response?.data}");
      Get.snackbar(
        'Gagal',
        _extractErrorMessage(e, 'Gagal menyimpan experience'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("ERROR DETAIL: $e");
      Get.snackbar('Gagal', 'Terjadi kesalahan saat menyimpan experience',
          backgroundColor: Colors.red, colorText: Colors.white);
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

      if (token == null) {
        Get.snackbar('Error', 'Sesi tidak valid. Silakan login kembali.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      await ProfileApi.deleteExperience(id: id, token: token);

      await fetchProfileData();

      Get.snackbar('Sukses', 'Experience berhasil dihapus',
          backgroundColor: Colors.green, colorText: Colors.white);
    } on DioException catch (e) {
      print("DELETE EXPERIENCE ERROR: ${e.response?.data}");
      Get.snackbar(
        'Gagal',
        _extractErrorMessage(e, 'Gagal menghapus experience'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("DELETE EXPERIENCE ERROR: $e");
      Get.snackbar('Gagal', 'Terjadi kesalahan saat menghapus experience',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // LOGIC: UPDATE PASSWORD
  // ==========================================
  Future<void> updatePassword() async {
    if (oldPassController.text.trim().isEmpty ||
        newPassController.text.trim().isEmpty ||
        confirmPassController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Semua field password harus diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (newPassController.text != confirmPassController.text) {
      Get.snackbar('Error', 'Password baru dan konfirmasi tidak sama',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);

      if (token == null) {
        Get.snackbar('Error', 'Sesi tidak valid. Silakan login kembali.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

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
      print("UPDATE PASSWORD ERROR: ${e.response?.data}");
      Get.snackbar(
        'Gagal',
        _extractErrorMessage(e, 'Gagal mengubah password'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("UPDATE PASSWORD ERROR: $e");
      Get.snackbar('Gagal', 'Terjadi kesalahan saat mengubah password',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await AuthApi.logout(fcmToken);
      }
    } catch (e) {
      print("LOGOUT ERROR: $e");
    } finally {
      box.remove(StorageKeys.token);
      box.remove(StorageKeys.userId);
      box.remove(StorageKeys.username);
      box.remove(StorageKeys.email);

      Get.offAllNamed(Routes.LOGIN);
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
