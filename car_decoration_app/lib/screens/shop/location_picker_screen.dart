import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../theme.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapCtrl;
  LatLng? _picked;
  bool _locating = false;

  // Default center: Riyadh
  static const _defaultCenter = LatLng(24.7136, 46.6753);

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
    _picked = widget.initial;
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) _snack('لم يتم منح إذن الموقع');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      _mapCtrl.move(ll, 16);
      if (mounted) setState(() => _picked = ll);
    } catch (_) {
      if (mounted) _snack('تعذر الحصول على الموقع');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')),
      backgroundColor: AppColors.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final center = _picked ?? widget.initial ?? _defaultCenter;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('تحديد موقع المتجر',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_picked != null)
            TextButton(
              onPressed: () => Navigator.pop(context, _picked),
              child: const Text('تأكيد', style: TextStyle(
                fontFamily: 'Tajawal', fontWeight: FontWeight.w800,
                color: AppColors.goldLight, fontSize: 15)),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _picked != null ? 15 : 12,
              onTap: (_, ll) => setState(() => _picked = ll),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.zinacars.app',
              ),
              if (_picked != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _picked!,
                    width: 48,
                    height: 56,
                    child: const Column(
                      children: [
                        Icon(Icons.location_pin, color: AppColors.goldText, size: 42),
                        SizedBox(height: 2),
                      ],
                    ),
                  ),
                ]),
            ],
          ),

          // Instruction banner
          Positioned(
            top: 12, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.dark.withOpacity(.88),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.touch_app_rounded, color: AppColors.goldLight, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  _picked == null
                      ? 'اضغط على الخريطة لتحديد موقع المتجر'
                      : 'تم تحديد الموقع — اضغط تأكيد أو غيّر الموقع',
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5,
                      fontWeight: FontWeight.w700, color: Colors.white),
                )),
              ]),
            ),
          ),

          // My location button
          Positioned(
            bottom: 100, left: 16,
            child: FloatingActionButton.small(
              heroTag: 'loc',
              backgroundColor: Colors.white,
              onPressed: _locating ? null : _goToMyLocation,
              child: _locating
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.dark))
                  : const Icon(Icons.my_location_rounded, color: AppColors.dark),
            ),
          ),

          // Confirm button
          if (_picked != null)
            Positioned(
              bottom: 24, left: 20, right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, _picked),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.goldLight, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'تأكيد الموقع  ${_picked!.latitude.toStringAsFixed(5)}, ${_picked!.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13,
                          fontWeight: FontWeight.w800, color: AppColors.goldLight),
                    ),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
