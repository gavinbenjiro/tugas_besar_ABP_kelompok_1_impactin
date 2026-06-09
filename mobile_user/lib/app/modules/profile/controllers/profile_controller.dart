import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/api/profile_api.dart';
import '../../../core/storage/storage_keys.dart';

class ProfileController extends GetxController {
  ProfileController() {
    print("CONSTRUCTOR CALLED");
  }
  final profile = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;

  @override
  void onInit() {
    print("ON INIT CALLED");
    super.onInit();
    getProfile();
  }

  Future<void> getProfile() async {
    print("GET PROFILE CALLED");

    try {
      isLoading.value = true;

      final userId = GetStorage().read(
        StorageKeys.userId,
      );

      print("USER ID = $userId");

      final response = await ProfileApi.getProfile(
        userId,
      );

      print("PROFILE RESPONSE");
      print(response.data);

      profile.value = response.data;
    } on DioException catch (e) {
      print("PROFILE ERROR");
      print("STATUS: ${e.response?.statusCode}");
      print("BODY: ${e.response?.data}");
    } catch (e) {
      print("UNKNOWN ERROR");
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
