import 'package:dio/dio.dart';
import 'api_endpoints.dart'; // Import file ApiEndpoints

class CloudinaryApi {
  static final Dio _dio = Dio();

  static Future<String?> uploadImage(String filePath) async {
    try {
      String fileName = filePath.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
        "upload_preset": ApiEndpoints.cloudinaryUploadPreset, // Pakai variabel dari endpoint
      });

      Response response = await _dio.post(
        ApiEndpoints.cloudinaryUploadUrl, // Pakai variabel dari endpoint
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['secure_url'];
      }
      return null;
    } catch (e) {
      print("Error upload Cloudinary: $e");
      return null;
    }
  }
}