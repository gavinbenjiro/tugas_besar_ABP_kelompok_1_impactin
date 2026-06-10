import 'package:get/get.dart';

import '../../../data/models/event_model.dart';
import '../../../core/api/event_api.dart';

class EventDetailController extends GetxController {
  final selectedTab = 0.obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final event = Rxn<EventModel>();

  bool get isHost => event.value?.isHost ?? false;
  bool get isApplicant => event.value?.isApplicant ?? false;
  bool get isParticipant => event.value?.isParticipant ?? false;

  bool get canJoin => !isHost && !isApplicant && !isParticipant;

  String get joinStatusText {
    if (isHost) return 'You are the host';
    if (isApplicant) return 'Waiting for approval';
    if (isParticipant) return 'You already joined';
    return 'Join Event';
  }

  bool get showGroupLink => isParticipant;

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

  Future<void> joinEvent() async {
    try {
      final currentEvent = event.value;

      if (currentEvent == null) return;

      final eventId = int.parse(currentEvent.id);

      await EventApi.joinEvent(eventId);

      Get.snackbar(
        'Success',
        'Application submitted successfully',
      );

      await fetchEventDetail(eventId);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
      );
    }
  }

  Future<void> reportEvent(String description) async {
    try {
      final currentEvent = event.value;

      if (currentEvent == null) return;

      await EventApi.reportEvent(
        eventId: int.parse(currentEvent.id),
        description: description,
      );

      Get.back();

      Get.snackbar(
        'Success',
        'Report submitted successfully',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
      );
    }
  }
}
