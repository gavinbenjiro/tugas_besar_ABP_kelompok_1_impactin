import 'package:get/get.dart';

import '../controllers/tes_controller.dart';

class TesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TesController>(
      () => TesController(),
    );
  }
}
