import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://10.0.2.2:7209'; // Android emulator
  // static const String baseUrl = 'https://localhost:7209'; // iOS simulator
  // static const String baseUrl = 'https://192.168.1.x:7209'; // جهاز حقيقي

  static final _storage = const FlutterSecureStorage();

  static Dio get dio {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // تجاوز شهادة HTTPS أثناء التطوير
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    // إضافة التوكن تلقائياً لكل الطلبات
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));

    return dio;
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<void> saveUserData({
    required String token,
    required String fullName,
    required String email,
    required String role,
  }) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'fullName', value: fullName);
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'role', value: role);
  }

  static Future<void> clearUserData() async {
    await _storage.deleteAll();
  }

  static Future<String?> getToken() => _storage.read(key: 'token');
  static Future<String?> getRole() => _storage.read(key: 'role');
  static Future<String?> getFullName() => _storage.read(key: 'fullName');
  static Future<String?> getEmail() => _storage.read(key: 'email');

  static Future<String?> getUserId() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(decoded) as Map<String, dynamic>;
      return map['sub'] as String? ?? map['nameid'] as String?;
    } catch (_) {
      return null;
    }
  }
}
