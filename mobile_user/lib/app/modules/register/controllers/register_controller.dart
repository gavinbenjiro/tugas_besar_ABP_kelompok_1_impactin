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

  String _extractErrorMessage(
    DioException e,
    String fallback,
  ) {
    if (e.response?.data is Map) {
      return e.response?.data?['error']?.toString() ??
          e.response?.data?['message']?.toString() ??
          fallback;
    } else if (e.response?.data is String) {
      return e.response!.data;
    }
    return fallback;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // ==========================================
    // VALIDATION
    // ==========================================
    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields must be filled",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (!_isValidEmail(email)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (username.length < 3) {
      Get.snackbar(
        "Error",
        "Username must be at least 3 characters",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        "Error",
        "Password must be at least 6 characters",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        "Error",
        "Password does not match",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await AuthApi.register(
        email: email,
        username: username,
        password: password,
      );

      Get.snackbar(
        "Success",
        response.data?["message"] ?? "Registration Success",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(Routes.LOGIN);
    } on DioException catch (e) {
      print("REGISTER ERROR STATUS: ${e.response?.statusCode}");
      print("REGISTER ERROR BODY: ${e.response?.data}");

      String errorMessage;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = "Connection timeout. Please check your internet";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Cannot connect to server. Please check your network";
      } else {
        errorMessage = _extractErrorMessage(e, "Registration failed");
      }

      Get.snackbar(
        "Register Failed",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("REGISTER ERROR: $e");

      Get.snackbar(
        "Register Failed",
        "Something went wrong. Please try again",
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
