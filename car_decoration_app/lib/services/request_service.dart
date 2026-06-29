import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../models/paged_result.dart';
import 'api_client.dart';

class RequestService {
  static Future<PagedResult<ServiceRequest>> getMyRequests({int page = 1, int pageSize = 20}) async {
    final res = await ApiClient.dio.get('/api/requests/my', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    return PagedResult.fromJson(
      res.data as Map<String, dynamic>,
      ServiceRequest.fromJson,
    );
  }

  static Future<ServiceRequest> getRequest(String id) async {
    final res = await ApiClient.dio.get('/api/requests/$id');
    return ServiceRequest.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<ServiceRequest> createRequest({
    required String vehicleId,
    required String description,
    required String location,
    required List<String> shopIds,
    String? notes,
    DateTime? preferredDate,
    TimeOfDay? preferredTime,
    List<String>? imageUrls,
  }) async {
    String? preferredDateTime;
    if (preferredDate != null) {
      final h = preferredTime?.hour ?? 12;
      final m = preferredTime?.minute ?? 0;
      final dt = DateTime(preferredDate.year, preferredDate.month, preferredDate.day, h, m);
      preferredDateTime = dt.toIso8601String();
    }
    final res = await ApiClient.dio.post('/api/requests', data: {
      'vehicleId': vehicleId,
      'description': description,
      'location': location,
      'shopIds': shopIds,
      if (notes != null) 'notes': notes,
      if (preferredDateTime != null) 'preferredDate': preferredDateTime,
      if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
    });
    return ServiceRequest.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<void> cancelRequest(String id) async {
    await ApiClient.dio.put('/api/requests/$id/cancel');
  }

  static Future<ServiceRequest> updateRequest({
    required String id,
    required String description,
    required String location,
    String? notes,
    DateTime? preferredDate,
    TimeOfDay? preferredTime,
    List<String>? imageUrls,
  }) async {
    String? preferredDateTime;
    if (preferredDate != null) {
      final h = preferredTime?.hour ?? 12;
      final m = preferredTime?.minute ?? 0;
      final dt = DateTime(preferredDate.year, preferredDate.month, preferredDate.day, h, m);
      preferredDateTime = dt.toIso8601String();
    }
    final res = await ApiClient.dio.put('/api/requests/$id', data: {
      'description': description,
      'location': location,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (preferredDateTime != null) 'preferredDate': preferredDateTime,
      if (imageUrls != null) 'imageUrls': imageUrls,
    });
    return ServiceRequest.fromJson(res.data as Map<String, dynamic>);
  }
}
