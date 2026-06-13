import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Username and password cannot be empty",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await AuthApi.login(
        username: username,
        password: password,
      );

      final data = response.data;

      if (data == null || data["token"] == null || data["data"] == null) {
        Get.snackbar(
          "Login Failed",
          "Invalid response from server",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      box.write(StorageKeys.token, data["token"]);
      box.write(StorageKeys.userId, data["data"]["id"]);
      box.write(StorageKeys.username, data["data"]["username"]);
      box.write(StorageKeys.email, data["data"]["email"]);

      // FCM token save - non-critical, shouldn't block login
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await AuthApi.saveFcmToken(fcmToken);
        }
      } on DioException catch (e) {
        print("SAVE FCM TOKEN ERROR: ${e.response?.data}");
      } catch (e) {
        print("SAVE FCM TOKEN ERROR: $e");
      }

      Get.snackbar(
        "Success",
        data["message"] ?? "Login successful",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(Routes.HOME);
    } on DioException catch (e) {
      print("STATUS: ${e.response?.statusCode}");
      print("BODY: ${e.response?.data}");

      String errorMessage = "Unknown error occurred";

      if (e.response?.data != null && e.response!.data is Map) {
        errorMessage = e.response!.data["error"] ??
            e.response!.data["message"] ??
            errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = "Connection timeout. Please check your internet";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Cannot connect to server. Please check your network";
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      Get.snackbar(
        "Login Failed",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print("LOGIN ERROR: $e");

      Get.snackbar(
        "Login Failed",
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
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
