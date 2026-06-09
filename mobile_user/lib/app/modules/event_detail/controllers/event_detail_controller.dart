import 'package:get/get.dart';

import '../../../data/models/event_model.dart';
import '../../../core/api/event_api.dart';

class EventDetailController extends GetxController {
  final selectedTab = 0.obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final event = Rxn<EventModel>();

  @override
  void onInit() {
    super.onInit();

    final rawId = Get.arguments;
    final int eventId = rawId is int ? rawId : int.parse(rawId.toString());

    fetchEventDetail(eventId);
  }

  Future<void> fetchEventDetail(int eventId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await EventApi.getEventDetail(eventId);
      event.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
