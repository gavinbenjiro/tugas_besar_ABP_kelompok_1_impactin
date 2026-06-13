import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/storage/storage_keys.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final box = GetStorage();

  void startTransition(Duration animationDuration) async {
    await Future.delayed(
      animationDuration + const Duration(seconds: 3),
    );

    final hasSeenOnboarding = box.read(StorageKeys.hasSeenOnboarding) ?? false;

    final token = box.read(StorageKeys.token);
    print("ONBOARDING = $hasSeenOnboarding");
    print("TOKEN = $token");
    if (!hasSeenOnboarding) {
      Get.offAllNamed(
        Routes.ONBOARDING,
      );
      return;
    }

    if (token != null && token.toString().isNotEmpty) {
      Get.offAllNamed(
        Routes.HOME,
      );
    } else {
      Get.offAllNamed(
        Routes.LOGIN,
      );
    }
  }
}
