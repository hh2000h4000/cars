import 'api_client.dart';

class AuthService {
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
}
