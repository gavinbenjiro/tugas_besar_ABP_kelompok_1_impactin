import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {

  void startTransition(Duration animationDuration) async {
    await Future.delayed(animationDuration + const Duration(seconds: 3));
    Get.offAllNamed(Routes.ONBOARDING);
  }
}