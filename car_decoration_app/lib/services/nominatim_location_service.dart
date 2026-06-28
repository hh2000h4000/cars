import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'location_service.dart';

/// Nominatim (OpenStreetMap) implementation of [LocationServiceProvider].
/// Free, no API key required. Rate-limit: 1 req/sec — callers must debounce.
class NominatimLocationService implements LocationServiceProvider {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {'User-Agent': 'ZinaCars/1.0 (contact@zinacars.sa)'},
  ));

  @override
  Future<List<LocationSearchResult>> searchAddress(String query) async {
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 6,
          'accept-language': 'ar',
          'countrycodes': 'sa',
          'addressdetails': 1,
        },
      );
      return (res.data as List<dynamic>).map((raw) {
        final m = raw as Map<String, dynamic>;
        return LocationSearchResult(
          displayName: m['display_name'] as String? ?? '',
          shortName: _shortName(m),
          position: LatLng(
            double.parse(m['lat'] as String),
            double.parse(m['lon'] as String),
          ),
        );
      }).toList();
    } catch (e) {
      debugPrint('[Nominatim] searchAddress error: $e');
      return [];
    }
  }

  @override
  Future<String?> reverseGeocode(LatLng position) async {
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': position.latitude,
          'lon': position.longitude,
          'format': 'json',
          'accept-language': 'ar',
          'addressdetails': 1,
        },
      );
      final data = res.data as Map<String, dynamic>?;
      if (data == null || data['error'] != null) return null;
      return _shortName(data);
    } catch (e) {
      debugPrint('[Nominatim] reverseGeocode error: $e');
      return null;
    }
  }

  /// Extracts a concise label: "شارع الملك فهد، الرياض" instead of the full display_name.
  static String _shortName(Map<String, dynamic> item) {
    final addr = item['address'] as Map<String, dynamic>?;
    if (addr == null) return item['display_name'] as String? ?? '';

    final road = addr['road']
        ?? addr['pedestrian']
        ?? addr['footway']
        ?? addr['neighbourhood']
        ?? addr['suburb'];

    final city = addr['city']
        ?? addr['town']
        ?? addr['village']
        ?? addr['county'];

    final parts = [road, city].whereType<String>().toList();
    return parts.isNotEmpty ? parts.join('، ') : (item['display_name'] as String? ?? '');
  }
}
