import 'package:get/get.dart';

import '../controllers/search_event_controller.dart';

class SearchEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchEventController>(
      () => SearchEventController(),
    );
  }
}
