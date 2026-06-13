import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../core/api/event_api.dart';
import '../../../data/models/manage_event_model.dart';

class ManageEventController extends GetxController {
  final isLoading = true.obs;
  final isActionLoading = false.obs;

  final event = Rxn<ManageEventModel>();

  late int eventId;

  @override
  void onInit() {
    super.onInit();

    print("GET ARGUMENT = ${Get.arguments}");

    eventId = Get.arguments;

    loadEvent();
  }

  String _extractErrorMessage(
    DioException e,
    String fallback,
  ) {
    return e.response?.data?["message"] ??
        e.response?.data?["error"] ??
        fallback;
  }

  Future<void> loadEvent() async {
    try {
      isLoading.value = true;

      final data = await EventApi.getCreatedEventDetail(
        eventId,
      );

      event.value = data;
    } on DioException catch (e) {
      Get.snackbar(
        "Error",
        _extractErrorMessage(
          e,
          "Failed to load event",
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
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
    } on DioException catch (e) {
      Get.snackbar(
        "Error",
        _extractErrorMessage(
          e,
          "Failed to open event",
        ),
      );
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
    } on DioException catch (e) {
      Get.snackbar(
        "Error",
        _extractErrorMessage(
          e,
          "Failed to close event",
        ),
      );
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
    } on DioException catch (e) {
      Get.snackbar(
        "Error",
        _extractErrorMessage(
          e,
          "Failed to cancel event",
        ),
        snackPosition: SnackPosition.BOTTOM,
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

  Future<void> approveApplicant(int applicantUserId) async {
    try {
      isActionLoading.value = true;

      await EventApi.updateApplicant(
        eventId: eventId,
        userId: applicantUserId,
        action: "approve",
      );

      Get.snackbar(
        "Success",
        "Applicant approved successfully",
      );

      await loadEvent();
    } on DioException catch (e) {
      Get.snackbar(
        "Error",
        _extractErrorMessage(e, "Failed to approve applicant"),
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> rejectApplicant(int applicantUserId) async {
    try {
      isActionLoading.value = true;

      await EventApi.updateApplicant(
        eventId: eventId,
        userId: applicantUserId,
        action: "reject",
      );

      Get.snackbar(
        "Success",
        "Applicant rejected successfully",
      );

      await loadEvent();
    } on DioException catch (e) {
      Get.snackbar(
        "Error",
        _extractErrorMessage(e, "Failed to reject applicant"),
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> removeParticipant(int userId) async {
    try {
      isActionLoading.value = true;

      await EventApi.removeParticipant(
        eventId: eventId,
        userId: userId,
      );

      Get.snackbar(
        "Success",
        "Participant removed successfully",
        snackPosition: SnackPosition.BOTTOM,
      );

      await loadEvent();
    } on DioException catch (e) {
      Get.snackbar(
        "Error",
        _extractErrorMessage(e, "Failed to remove participant"),
        snackPosition: SnackPosition.BOTTOM,
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
}
