import 'package:get/get.dart';

import '../../../data/dummies/event_dummy.dart';
import '../../../data/models/event_model.dart';

class EventDetailController extends GetxController {
  late EventModel event;

  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();

    final eventId = Get.arguments;

    event = dummyEvents.firstWhere(
      (e) => e.id == eventId,
    );
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
