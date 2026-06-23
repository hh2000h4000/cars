import 'package:flutter/material.dart';
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
    required String location,
    required List<String> shopIds,
    String? notes,
    DateTime? preferredDate,
    TimeOfDay? preferredTime,
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
    });
    return ServiceRequest.fromJson(res.data as Map<String, dynamic>);
  }
}
