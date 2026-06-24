import '../models/vehicle.dart';
import 'api_client.dart';

class VehicleService {
  static Future<List<Vehicle>> getMyVehicles() async {
    final res = await ApiClient.dio.get('/api/vehicles');
    final list = res.data as List<dynamic>;
    return list.map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Vehicle> addVehicle({
    required String brand,
    required String model,
    required int year,
    required String color,
    String? plateNumber,
    List<String>? imageUrls,
  }) async {
    final res = await ApiClient.dio.post('/api/vehicles', data: {
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      if (plateNumber != null) 'plateNumber': plateNumber,
      if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
    });
    return Vehicle.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<Vehicle> updateVehicle({
    required String id,
    required String brand,
    required String model,
    required int year,
    required String color,
    String? plateNumber,
    List<String>? imageUrls,
  }) async {
    final res = await ApiClient.dio.put('/api/vehicles/$id', data: {
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      if (plateNumber != null) 'plateNumber': plateNumber,
      if (imageUrls != null) 'imageUrls': imageUrls,
    });
    return Vehicle.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<void> deleteVehicle(String id) async {
    await ApiClient.dio.delete('/api/vehicles/$id');
  }
}
