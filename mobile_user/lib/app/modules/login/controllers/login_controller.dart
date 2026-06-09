import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/storage/storage_keys.dart';
import '../../../core/api/auth_api.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final box = GetStorage();
  final isLoading = false.obs;

  Future<void> login() async {
    try {
      isLoading.value = true;

      final requestBody = {
        "username": usernameController.text.trim(),
        "password": passwordController.text.trim(),
      };

      print(requestBody);

      final response = await AuthApi.login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      final data = response.data;

      box.write(
        StorageKeys.token,
        data["token"],
      );

      box.write(
        StorageKeys.userId,
        data["data"]["id"],
      );

      box.write(
        StorageKeys.username,
        data["data"]["username"],
      );

      box.write(
        StorageKeys.email,
        data["data"]["email"],
      );

      Get.snackbar(
        "Success",
        data["message"],
      );

      print(box.read(StorageKeys.token));

      Get.offAllNamed(
        Routes.HOME,
      );
    } on DioException catch (e) {
      print("STATUS: ${e.response?.statusCode}");
      print("BODY: ${e.response?.data}");

      Get.snackbar(
        "Login Failed",
        e.response?.data["error"] ?? e.message ?? "Unknown Error",
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
