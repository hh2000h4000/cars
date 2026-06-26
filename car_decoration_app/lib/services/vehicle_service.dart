import '../models/vehicle.dart';
import '../models/paged_result.dart';
import 'api_client.dart';

class VehicleService {
  static Future<PagedResult<Vehicle>> getMyVehicles({int page = 1, int pageSize = 50}) async {
    final res = await ApiClient.dio.get('/api/vehicles', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    return PagedResult.fromJson(res.data as Map<String, dynamic>, Vehicle.fromJson);
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
