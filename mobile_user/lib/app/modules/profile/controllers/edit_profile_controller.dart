import 'dart:io'; // Untuk handling File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/api/profile_api.dart';
import '../../../core/api/cloudinary_api.dart';
import '../controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  // Text Controllers
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final statusController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  final skillController = TextEditingController();
  final usernameController = TextEditingController();

  // Storage & Image Picker
  final box = GetStorage();
  final ImagePicker _picker = ImagePicker();

  // Reactive State
  var skills = <String>[].obs;
  var isLoading = false.obs;
  var imageUrl = "".obs; // URL dari API/Network
  var localImagePath = "".obs; // Path file lokal jika user memilih gambar baru

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  String _extractErrorMessage(
    DioException e,
    String fallback,
  ) {
    if (e.response?.data is Map) {
      return e.response?.data?['error']?.toString() ??
          e.response?.data?['message']?.toString() ??
          fallback;
    }
    return fallback;
  }

  // ==========================================
  // IMAGE PICKER FUNCTIONS
  // ==========================================
  void showImagePicker(BuildContext context) {
    try {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Ubah Foto Profil',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    pickImage(ImageSource.gallery);
                    Get.back(); // Tutup bottom sheet
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () {
                    pickImage(ImageSource.camera);
                    Get.back();
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("SHOW IMAGE PICKER ERROR: $e");
      Get.snackbar('Error', 'Gagal membuka pilihan gambar',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Kompresi ringan agar upload tidak berat
      );

      if (pickedFile != null) {
        // Simpan path lokal untuk ditampilkan di UI
        localImagePath.value = pickedFile.path;
      }
    } on PlatformException catch (e) {
      print("PICK IMAGE PLATFORM ERROR: ${e.message}");
      Get.snackbar('Error', 'Tidak dapat mengakses kamera/galeri',
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("PICK IMAGE ERROR: $e");
      Get.snackbar('Error', 'Gagal mengakses gambar',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ==========================================
  // GET PROFILE (LOAD DATA ASLI)
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

        if (data['skills'] is List) {
          try {
            skills.value = (data['skills'] as List).map((item) {
              return item is Map ? item['skills'].toString() : item.toString();
            }).toList();
          } catch (e) {
            print("PARSE SKILLS ERROR: $e");
            skills.value = [];
          }
        }

        if (data['age'] != null) {
          ageController.text = data['age'].toString();
        }
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
      print("FETCH PROFILE ERROR: $e");
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
  // PATCH PROFILE (SAVE DATA)
  // ==========================================
  Future<void> saveProfile() async {
    try {
      isLoading.value = true;
      final token = box.read(StorageKeys.token);

      if (token == null) {
        Get.snackbar('Error', 'Sesi tidak valid',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Basic validation
      if (nameController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Nama tidak boleh kosong',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      if (usernameController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Username tidak boleh kosong',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      // 1. Siapkan variabel untuk menyimpan URL gambar akhir
      String finalImageUrl = imageUrl.value; // Default pakai URL lama

      // 2. Jika user memilih gambar baru dari HP, upload ke Cloudinary dulu!
      if (localImagePath.value.isNotEmpty) {
        try {
          final uploadedUrl =
              await CloudinaryApi.uploadImage(localImagePath.value);

          if (uploadedUrl != null) {
            finalImageUrl =
                uploadedUrl; // Timpa dengan URL baru dari Cloudinary
          } else {
            Get.snackbar('Gagal', 'Gagal mengunggah gambar ke Cloudinary',
                backgroundColor: Colors.red, colorText: Colors.white);
            return; // Hentikan proses jika gagal upload gambar
          }
        } on DioException catch (e) {
          print("UPLOAD IMAGE ERROR: ${e.response?.data}");
          Get.snackbar(
            'Gagal',
            'Gagal mengunggah gambar: ${_extractErrorMessage(e, "kesalahan jaringan")}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        } catch (e) {
          print("UPLOAD IMAGE ERROR: $e");
          Get.snackbar('Gagal', 'Gagal mengunggah gambar',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }

      // 3. Susun JSON Request untuk dikirim ke Backend Impactin
      final requestBody = {
        "username": usernameController.text.trim(),
        "name": nameController.text.trim(),
        "status": statusController.text.trim(),
        "age": int.tryParse(ageController.text.trim()) ?? 0,
        "city": locationController.text.trim(),
        "bio": bioController.text.trim(),
        "image_url": finalImageUrl,
        "skills": skills.toList(),
      };

      // 4. Panggil API Update Profile
      await ProfileApi.updateProfile(
        data: requestBody,
        token: token,
      );

      // 5. Refresh data di halaman Profile
      try {
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfileData();
        }
      } catch (e) {
        print("REFRESH PROFILE CONTROLLER ERROR: $e");
        // Non-critical, profile page will refresh on next visit anyway
      }

      Get.back(closeOverlays: true);

      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      print("SAVE PROFILE ERROR: ${e.response?.data}");
      String msg = _extractErrorMessage(e, "Gagal menyimpan profil");
      Get.snackbar('Gagal', msg,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("SAVE PROFILE ERROR: $e");
      Get.snackbar('Gagal', 'Terjadi kesalahan saat menyimpan profil',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void addSkill() {
    try {
      if (skillController.text.trim().isNotEmpty) {
        skills.add(skillController.text.trim());
        skillController.clear();
      }
    } catch (e) {
      print("ADD SKILL ERROR: $e");
    }
  }

  void removeSkill(String skill) {
    try {
      skills.remove(skill);
    } catch (e) {
      print("REMOVE SKILL ERROR: $e");
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    nameController.dispose();
    statusController.dispose();
    locationController.dispose();
    bioController.dispose();
    skillController.dispose();
    ageController.dispose();
    super.onClose();
  }
}
