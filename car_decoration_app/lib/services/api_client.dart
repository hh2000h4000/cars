import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../app_navigator.dart';
import 'app_logger.dart';

// dart:io و dio/io غير متوفران على الويب
import 'api_client_mobile.dart' if (dart.library.html) 'api_client_web.dart' as platform;

class ApiClient {
  static final String baseUrl = kIsWeb
      ? 'http://localhost:5053'
      : 'http://192.168.8.11:5053';

  static final _storage = const FlutterSecureStorage();
  static Dio? _instance;
  static bool _isRefreshing = false;

  static Dio get dio => _instance ??= _build();

  static Dio _build() {
    final d = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    if (!kIsWeb) platform.setHttpClientAdapter(d);

    d.interceptors.add(InterceptorsWrapper(
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
      onError: (error, handler) async {
        try {
          final body = error.response?.data?.toString() ?? '';
          AppLogger.error(
            'API Error: ${error.requestOptions.method} ${error.requestOptions.path} → ${error.response?.statusCode}',
            error: body.isNotEmpty ? body : error.message,
          );
        } catch (_) {}

        if (error.response?.statusCode == 401 && !_isRefreshing) {
          final path = error.requestOptions.path;
          if (!path.contains('/api/auth/')) {
            _isRefreshing = true;
            final refreshed = await _tryRefresh();
            _isRefreshing = false;

            if (refreshed) {
              try {
                final retried = await dio.fetch(error.requestOptions);
                return handler.resolve(retried);
              } catch (_) {
                // retry failed after refresh — fall through to reject
              }
            }

            await clearUserData();
            appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/auth/login',
              (route) => false,
            );
            // reject silently — screen is gone, user is on login page
            return handler.reject(error);
          }
        }
        return handler.next(error);
      },
    ));

    return d;
  }

  static Future<bool> _tryRefresh() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return false;
    try {
      final plain = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ));
      if (!kIsWeb) platform.setHttpClientAdapter(plain);

      final res = await plain.post('/api/auth/refresh', data: {'refreshToken': refreshToken});
      final data = res.data as Map<String, dynamic>;
      await _storage.write(key: 'token', value: data['token'] as String);
      await _storage.write(key: 'refreshToken', value: data['refreshToken'] as String);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveUserData({
    required String token,
    required String refreshToken,
    required String fullName,
    required String phone,
    required String email,
    required String role,
  }) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    await _storage.write(key: 'fullName', value: fullName);
    await _storage.write(key: 'phone', value: phone);
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'role', value: role);
  }

  static Future<void> clearUserData() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'fullName');
    await _storage.delete(key: 'phone');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'role');
    // Reset singleton so next login gets a fresh Dio instance
    _instance = null;
  }

  static Future<String?> getToken() => _storage.read(key: 'token');
  static Future<String?> getRole() => _storage.read(key: 'role');
  static Future<String?> getFullName() => _storage.read(key: 'fullName');
  static Future<String?> getPhone() => _storage.read(key: 'phone');
  static Future<String?> getEmail() => _storage.read(key: 'email');

  static Future<void> updateCachedProfile({required String fullName, required String phone}) async {
    await _storage.write(key: 'fullName', value: fullName);
    await _storage.write(key: 'phone', value: phone);
  }

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
