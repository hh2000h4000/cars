import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_client.dart';

class UploadService {
  static Future<List<String>> uploadImages(List<Uint8List> imageBytes) async {
    if (imageBytes.isEmpty) return [];

    final formData = FormData();
    for (int i = 0; i < imageBytes.length; i++) {
      formData.files.add(MapEntry(
        'files',
        MultipartFile.fromBytes(imageBytes[i], filename: 'image_$i.jpg'),
      ));
    }

    final res = await ApiClient.dio.post('/api/upload/multiple', data: formData);
    return (res.data['urls'] as List<dynamic>).cast<String>();
  }

  /// رفع وثيقة (صورة أو PDF) بدون مصادقة — للتسجيل قبل إنشاء الحساب
  static Future<String> uploadDocument(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await ApiClient.dio.post(
      '/api/upload/document',
      data: formData,
      options: Options(receiveTimeout: const Duration(seconds: 30)),
    );
    return res.data['url'] as String;
  }
}
