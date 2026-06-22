import '../models/service_request.dart';
import 'api_client.dart';

class RequestService {
  static Future<List<ServiceRequest>> getMyRequests() async {
    final res = await ApiClient.dio.get('/api/requests');
    final list = res.data as List<dynamic>;
    return list.map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<ServiceRequest> getRequest(String id) async {
    final res = await ApiClient.dio.get('/api/requests/$id');
    return ServiceRequest.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<ServiceRequest> createRequest({
    required String vehicleId,
    required String description,
    String? notes,
  }) async {
    final res = await ApiClient.dio.post('/api/requests', data: {
      'vehicleId': vehicleId,
      'description': description,
      if (notes != null) 'notes': notes,
    });
    return ServiceRequest.fromJson(res.data as Map<String, dynamic>);
  }
}
