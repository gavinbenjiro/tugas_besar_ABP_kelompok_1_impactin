import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api/auth_api.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Password does not match",
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await AuthApi.register(
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      Get.snackbar(
        "Success",
        response.data["message"] ?? "Registration Success",
      );

      Get.offAllNamed(Routes.LOGIN);
    } on DioException catch (e) {
      Get.snackbar(
        "Register Failed",
        e.response?.data["error"] ?? e.message ?? "Unknown Error",
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
