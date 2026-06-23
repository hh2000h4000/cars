import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

import '../../theme.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _mapController = MapController();
  final _searchCtrl = TextEditingController();
  final _dio = Dio();

  LatLng _selectedPoint = const LatLng(24.7136, 46.6753); // الرياض
  String _address = '';
  bool _loadingAddress = false;
  bool _loadingLocation = false;
  List<_SearchResult> _searchResults = [];
  bool _showResults = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() { _loadingAddress = true; });
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {'lat': point.latitude, 'lon': point.longitude, 'format': 'json'},
        options: Options(headers: {'Accept-Language': 'ar'}),
      );
      final display = res.data['display_name'] as String? ?? '';
      final parts = display.split(',');
      setState(() { _address = parts.take(3).join('،'); });
    } catch (_) {
      setState(() { _address = '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}'; });
    } finally {
      if (mounted) setState(() { _loadingAddress = false; });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() { _loadingLocation = true; });
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تفعيل صلاحية الموقع من الإعدادات')));
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final point = LatLng(pos.latitude, pos.longitude);
      setState(() { _selectedPoint = point; });
      _mapController.move(point, 15);
      await _reverseGeocode(point);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر تحديد الموقع')));
    } finally {
      if (mounted) setState(() { _loadingLocation = false; });
    }
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    if (query.length < 3) { setState(() { _showResults = false; _searchResults = []; }); return; }
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final res = await _dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {'q': query, 'format': 'json', 'limit': '5', 'countrycodes': 'sa'},
          options: Options(headers: {'Accept-Language': 'ar'}),
        );
        final list = res.data as List<dynamic>;
        if (mounted) setState(() {
          _searchResults = list.map((e) => _SearchResult(
            display: e['display_name'] as String,
            lat: double.parse(e['lat'] as String),
            lon: double.parse(e['lon'] as String),
          )).toList();
          _showResults = true;
        });
      } catch (_) {}
    });
  }

  void _selectResult(_SearchResult r) {
    final point = LatLng(r.lat, r.lon);
    setState(() {
      _selectedPoint = point;
      _address = r.display.split(',').take(3).join('،');
      _showResults = false;
      _searchCtrl.text = _address;
    });
    _mapController.move(point, 14);
  }

  void _onTap(TapPosition _, LatLng point) {
    setState(() { _selectedPoint = point; _showResults = false; });
    _reverseGeocode(point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPoint,
                initialZoom: 12,
                onTap: _onTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.car_decoration_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPoint,
                      width: 48, height: 56,
                      child: Column(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: AppColors.dark, shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.3), blurRadius: 8, offset: const Offset(0, 4))]),
                            child: const Icon(Icons.location_on, color: AppColors.goldLight, size: 22),
                          ),
                          Container(width: 2, height: 14, color: AppColors.dark),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Header + Search
            Positioned(
              top: 0, left: 0, right: 0,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.1), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            textAlign: TextAlign.right,
                            onChanged: _onSearch,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w600),
                            decoration: const InputDecoration(
                              hintText: 'ابحث عن موقع...',
                              hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textMuted),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  if (_showResults && _searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.1), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (_, i) {
                          final r = _searchResults[i];
                          final parts = r.display.split(',');
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on_outlined, color: AppColors.goldText, size: 20),
                            title: Text(parts.first, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700)),
                            subtitle: Text(parts.skip(1).take(2).join('،'), style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () => _selectResult(r),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Current location button
            Positioned(
              bottom: 160, left: 16,
              child: GestureDetector(
                onTap: _loadingLocation ? null : _getCurrentLocation,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: _loadingLocation
                      ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText))
                      : const Icon(Icons.my_location_rounded, color: AppColors.goldText, size: 22),
                ),
              ),
            ),

            // Confirm card
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.1), blurRadius: 20, offset: const Offset(0, -4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.location_on, color: AppColors.goldText, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _loadingAddress
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText))
                            : Text(
                                _address.isEmpty ? 'انقر على الخريطة لاختيار موقعك' : _address,
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700,
                                  color: _address.isEmpty ? AppColors.textMuted : AppColors.textPrimary),
                                maxLines: 2,
                              ),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _address.isEmpty ? null : () => Navigator.pop(context, _address),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dark,
                          disabledBackgroundColor: AppColors.border,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('تأكيد الموقع', style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.goldLight)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResult {
  final String display;
  final double lat;
  final double lon;
  const _SearchResult({required this.display, required this.lat, required this.lon});
}
