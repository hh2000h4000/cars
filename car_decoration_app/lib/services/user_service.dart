import 'api_client.dart';

class UserProfileData {
  final String fullName;
  final String phone;
  final String email;
  final int vehicleCount;
  final int activeRequestCount;
  final int reviewCount;

  const UserProfileData({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.vehicleCount,
    required this.activeRequestCount,
    required this.reviewCount,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) => UserProfileData(
    fullName: json['fullName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    vehicleCount: json['vehicleCount'] as int? ?? 0,
    activeRequestCount: json['activeRequestCount'] as int? ?? 0,
    reviewCount: json['reviewCount'] as int? ?? 0,
  );
}

class UserService {
  static Future<UserProfileData> getProfile() async {
    final res = await ApiClient.dio.get('/api/users/profile');
    return UserProfileData.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<UserProfileData> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final res = await ApiClient.dio.put('/api/users/profile', data: {
      'fullName': fullName,
      'phone': phone,
    });
    final data = UserProfileData.fromJson(res.data as Map<String, dynamic>);
    await ApiClient.updateCachedProfile(fullName: data.fullName, phone: data.phone);
    return data;
  }
}
