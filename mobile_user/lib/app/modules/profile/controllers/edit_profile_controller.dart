import 'dart:io'; // Untuk handling File
import 'package:flutter/material.dart';
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

  // ==========================================
  // IMAGE PICKER FUNCTIONS
  // ==========================================
  void showImagePicker(BuildContext context) {
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
                child: Text('Ubah Foto Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengakses gambar', backgroundColor: Colors.red, colorText: Colors.white);
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

      if (userId == null || token == null) return;

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
          skills.value = (data['skills'] as List).map((item) {
            return item is Map ? item['skills'].toString() : item.toString();
          }).toList();
        }

        if (data['age'] != null) {
          ageController.text = data['age'].toString();
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

      // 1. Siapkan variabel untuk menyimpan URL gambar akhir
      String finalImageUrl = imageUrl.value; // Default pakai URL lama

      // 2. Jika user memilih gambar baru dari HP, upload ke Cloudinary dulu!
      if (localImagePath.value.isNotEmpty) {
        final uploadedUrl = await CloudinaryApi.uploadImage(localImagePath.value);

        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl; // Timpa dengan URL baru dari Cloudinary
        } else {
          Get.snackbar('Gagal', 'Gagal mengunggah gambar ke Cloudinary', backgroundColor: Colors.red, colorText: Colors.white);
          isLoading.value = false;
          return; // Hentikan proses jika gagal upload gambar
        }
      }

      // 3. Susun JSON Request untuk dikirim ke Backend Impactin
      // (Sekarang murni JSON biasa, tidak pakai FormData lagi)
      final requestBody = {
        "username": usernameController.text.trim(),
        "name": nameController.text.trim(),
        "status": statusController.text.trim(),
        "age": int.tryParse(ageController.text.trim()) ?? 0,
        "city": locationController.text.trim(),
        "bio": bioController.text.trim(),
        "image_url": finalImageUrl, // <-- Masukkan URL (Bisa URL lama atau URL baru dari Cloudinary)
        "skills": skills.toList(),
      };

      // 4. Panggil API Update Profile
      await ProfileApi.updateProfile(
        data: requestBody,
        token: token,
      );

      // 5. Refresh data di halaman Profile
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfileData();
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
      String msg =
          e.response?.data?['error']?.toString() ?? "Gagal menyimpan profil";
      Get.snackbar('Gagal', msg,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
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
    statusController.dispose();
    locationController.dispose();
    bioController.dispose();
    skillController.dispose();
    ageController.dispose();
    super.onClose();
  }
}
