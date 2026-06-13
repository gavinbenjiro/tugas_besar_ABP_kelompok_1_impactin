import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final box = GetStorage();

  void finishOnboarding() {
    box.write(
      "hasSeenOnboarding",
      true,
    );

    Get.offAllNamed(
      Routes.LOGIN,
    );
  }
}
