import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

import '../../../core/api/event_api.dart';
import '../../../data/models/manage_event_model.dart';

class ManageEventController extends GetxController {
  final isLoading = true.obs;

  final event = Rxn<ManageEventModel>();

  late int eventId;
  final isActionLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("GET ARGUMENT = ${Get.arguments}");
    eventId = Get.arguments;

    loadEvent();
  }

  Future<void> loadEvent() async {
    try {
      isLoading.value = true;

      final data = await EventApi.getCreatedEventDetail(
        eventId,
      );

      event.value = data;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openEvent() async {
    try {
      isActionLoading.value = true;

      await EventApi.openEvent(
        eventId,
      );

      Get.snackbar(
        "Success",
        "Event opened successfully",
      );

      await loadEvent();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> closeEvent() async {
    try {
      isActionLoading.value = true;

      await EventApi.closeEvent(
        eventId,
      );

      Get.snackbar(
        "Success",
        "Event closed successfully",
      );

      await loadEvent();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> cancelEvent() async {
    try {
      isActionLoading.value = true;

      await EventApi.cancelEvent(
        eventId,
      );

      Get.snackbar(
        "Success",
        "Event cancelled successfully",
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offNamed(
        Routes.YOUR_EVENT,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> approveApplicant(
    int applicantId,
  ) async {
    try {
      await EventApi.updateApplicant(
        applicantId: applicantId,
        userId: applicantId,
        action: "approve",
      );

      Get.snackbar(
        "Success",
        "Applicant approved",
      );

      await loadEvent();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  Future<void> rejectApplicant(
    int applicantId,
  ) async {
    try {
      await EventApi.updateApplicant(
        applicantId: applicantId,
        userId: applicantId,
        action: "reject",
      );

      Get.snackbar(
        "Success",
        "Applicant rejected",
      );

      await loadEvent();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  Future<void> removeParticipant(
    int userId,
  ) async {
    try {
      await EventApi.removeParticipant(
        participantId: userId,
        userId: userId,
      );

      Get.snackbar(
        "Success",
        "Participant removed",
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadEvent();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
