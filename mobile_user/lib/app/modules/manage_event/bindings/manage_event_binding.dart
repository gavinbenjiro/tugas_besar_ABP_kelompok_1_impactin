import 'package:get/get.dart';

import '../controllers/manage_event_controller.dart';

class ManageEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageEventController>(
      () => ManageEventController(),
    );
  }
}
