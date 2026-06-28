import 'api_client.dart';

class ShopProfile {
  final String id;
  final String name;
  final String city;
  final String street;
  final String district;
  final String postalCode;
  final String? buildingNumber;
  final String? additionalNumber;
  final double? latitude;
  final double? longitude;
  final String phone;
  final String? logoUrl;
  final String status;
  final String crNumber;
  final String? idNumber;
  final double rating;
  final int totalJobs;
  final String? rejectionReason;

  ShopProfile({
    required this.id,
    required this.name,
    required this.city,
    required this.street,
    required this.district,
    required this.postalCode,
    this.buildingNumber,
    this.additionalNumber,
    this.latitude,
    this.longitude,
    required this.phone,
    this.logoUrl,
    required this.status,
    required this.crNumber,
    this.idNumber,
    required this.rating,
    required this.totalJobs,
    this.rejectionReason,
  });

  factory ShopProfile.fromJson(Map<String, dynamic> j) => ShopProfile(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        city: j['city'] as String? ?? '',
        street: j['street'] as String? ?? '',
        district: j['district'] as String? ?? '',
        postalCode: j['postalCode'] as String? ?? '',
        buildingNumber: j['buildingNumber'] as String?,
        additionalNumber: j['additionalNumber'] as String?,
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        phone: j['phone'] as String? ?? '',
        logoUrl: j['logoUrl'] as String?,
        status: j['status'] as String? ?? '',
        crNumber: j['crNumber'] as String? ?? '',
        idNumber: j['idNumber'] as String?,
        rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
        totalJobs: j['totalJobs'] as int? ?? 0,
        rejectionReason: j['rejectionReason'] as String?,
      );
}

class ShopProfileService {
  static Future<ShopProfile> getMyShop() async {
    final res = await ApiClient.dio.get('/api/shops/my');
    return ShopProfile.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<ShopProfile> updateMyShop({
    required String name,
    required String phone,
    required String city,
    required String street,
    required String district,
    required String postalCode,
    String? buildingNumber,
    String? additionalNumber,
    double? latitude,
    double? longitude,
    String? logoUrl,
  }) async {
    final res = await ApiClient.dio.put('/api/shops/my', data: {
      'name': name,
      'phone': phone,
      'city': city,
      'street': street,
      'district': district,
      'postalCode': postalCode,
      if (buildingNumber != null) 'buildingNumber': buildingNumber,
      if (additionalNumber != null) 'additionalNumber': additionalNumber,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (logoUrl != null) 'logoUrl': logoUrl,
    });
    return ShopProfile.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<ShopProfile> resubmitMyShop({
    required String name,
    required String phone,
    required String city,
    required String street,
    required String district,
    required String postalCode,
    String? buildingNumber,
    String? additionalNumber,
    double? latitude,
    double? longitude,
    required String crNumber,
    String? idNumber,
    String? logoUrl,
    String? crDocumentUrl,
    String? idDocumentUrl,
  }) async {
    final res = await ApiClient.dio.put('/api/shops/my/resubmit', data: {
      'name': name,
      'phone': phone,
      'city': city,
      'street': street,
      'district': district,
      'postalCode': postalCode,
      if (buildingNumber != null) 'buildingNumber': buildingNumber,
      if (additionalNumber != null) 'additionalNumber': additionalNumber,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'crNumber': crNumber,
      if (idNumber != null) 'idNumber': idNumber,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (crDocumentUrl != null) 'crDocumentUrl': crDocumentUrl,
      if (idDocumentUrl != null) 'idDocumentUrl': idDocumentUrl,
    });
    return ShopProfile.fromJson(res.data as Map<String, dynamic>);
  }
}
