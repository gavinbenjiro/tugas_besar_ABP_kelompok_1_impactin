import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../core/api/notification_api.dart';
import '../../../data/models/notification_model.dart';

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      final response = await NotificationApi.getNotifications();

      final data = response.data["data"] as List;

      notifications.value = data
          .map(
            (e) => NotificationModel.fromJson(e),
          )
          .toList();

      await NotificationApi.markBellRead();
    } on DioException catch (e) {
      print(e.response?.data);
    } finally {
      isLoading.value = false;
    }
  }
}
