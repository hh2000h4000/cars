import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiClient.dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    await ApiClient.saveUserData(
      token: data['token'],
      fullName: data['fullName'],
      email: data['email'],
      role: data['role'],
    );
    return data;
  }

  static Future<Map<String, dynamic>> registerCustomer({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.dio.post('/api/auth/register', data: {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    await ApiClient.saveUserData(
      token: data['token'],
      fullName: data['fullName'],
      email: data['email'],
      role: data['role'],
    );
    return data;
  }

  static Future<Map<String, dynamic>> registerShop({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String shopName,
    required String crNumber,
    required String city,
    required String shopPhone,
  }) async {
    final res = await ApiClient.dio.post('/api/auth/shop/register', data: {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'shopName': shopName,
      'crNumber': crNumber,
      'city': city,
      'shopPhone': shopPhone,
    });
    final data = res.data as Map<String, dynamic>;
    await ApiClient.saveUserData(
      token: data['token'],
      fullName: data['fullName'],
      email: data['email'],
      role: data['role'],
    );
    return data;
  }

  static Future<void> logout() async {
    await ApiClient.clearUserData();
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiClient.getToken();
    return token != null;
  }

  static Future<String?> getRole() => ApiClient.getRole();

  // ── Remember me credentials ──────────────────────────────────
  static Future<void> saveRememberedCredentials(String email, String password) async {
    await _storage.write(key: 'saved_email', value: email);
    await _storage.write(key: 'saved_password', value: password);
    await _storage.write(key: 'remember_me', value: 'true');
  }

  static Future<void> clearRememberedCredentials() async {
    await _storage.delete(key: 'saved_email');
    await _storage.delete(key: 'saved_password');
    await _storage.delete(key: 'remember_me');
  }

  static Future<Map<String, String>?> getRememberedCredentials() async {
    final flag = await _storage.read(key: 'remember_me');
    if (flag != 'true') return null;
    final email = await _storage.read(key: 'saved_email') ?? '';
    final password = await _storage.read(key: 'saved_password') ?? '';
    if (email.isEmpty) return null;
    return {'email': email, 'password': password};
  }
}
