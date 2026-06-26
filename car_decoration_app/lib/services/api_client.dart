import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../app_navigator.dart';
import 'app_logger.dart';

// dart:io و dio/io غير متوفران على الويب
import 'api_client_mobile.dart' if (dart.library.html) 'api_client_web.dart' as platform;

class ApiClient {
  // static const String baseUrl = 'https://10.0.2.2:7209'; // Android emulator
  static final String baseUrl = kIsWeb
      ? 'http://localhost:5053'        // Chrome على نفس الجهاز
      : 'http://192.168.8.11:5053';   // جهاز حقيقي

  static final _storage = const FlutterSecureStorage();

  static Dio get dio {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // تجاوز شهادة HTTPS على موبايل/ديسكتوب فقط
    if (!kIsWeb) platform.setHttpClientAdapter(dio);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.info('→ ${options.method} ${options.path}');
        } catch (_) {}
        handler.next(options);
      },
      onResponse: (response, handler) {
        try {
          AppLogger.apiCall(
            response.requestOptions.method,
            response.requestOptions.path,
            response.statusCode,
          );
        } catch (_) {}
        handler.next(response);
      },
      onError: (error, handler) {
        try {
          final body = error.response?.data?.toString() ?? '';
          AppLogger.error(
            'API Error: ${error.requestOptions.method} ${error.requestOptions.path} → ${error.response?.statusCode}',
            error: body.isNotEmpty ? body : error.message,
          );
        } catch (_) {}
        // Redirect to login on 401 (except for auth endpoints)
        if (error.response?.statusCode == 401) {
          final path = error.requestOptions.path;
          if (!path.contains('/api/auth/')) {
            clearUserData().then((_) {
              appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/auth/login',
                (route) => false,
              );
            });
          }
        }
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
    // Delete session keys only — saved_email/saved_password/remember_me are preserved
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'fullName');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'role');
  }

  static Future<String?> getToken() => _storage.read(key: 'token');
  static Future<String?> getRole() => _storage.read(key: 'role');
  static Future<String?> getFullName() => _storage.read(key: 'fullName');
  static Future<String?> getEmail() => _storage.read(key: 'email');

  static Future<void> writeData(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<String?> readData(String key) => _storage.read(key: key);

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
