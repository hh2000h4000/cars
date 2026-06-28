import 'package:latlong2/latlong.dart';

class LocationSearchResult {
  final String displayName;
  final String shortName;
  final LatLng position;

  const LocationSearchResult({
    required this.displayName,
    required this.shortName,
    required this.position,
  });
}

/// Abstract location service — swap the implementation without touching any screen.
abstract class LocationServiceProvider {
  /// Search by free-text address query. Returns up to ~6 results ordered by relevance.
  Future<List<LocationSearchResult>> searchAddress(String query);

  /// Reverse-geocode a coordinate into a human-readable address string.
  Future<String?> reverseGeocode(LatLng position);
}
