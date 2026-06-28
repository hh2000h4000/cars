import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../theme.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapCtrl;

  static const _defaultCenter = LatLng(24.7136, 46.6753);

  LatLng? _picked;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
    _picked = widget.initial;
  }

  // ─── Map tap ───────────────────────────────────────────────────────────────

  void _onMapTap(LatLng ll) {
    setState(() => _picked = ll);
  }

  // ─── GPS ───────────────────────────────────────────────────────────────────

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

  // ─── Zoom ──────────────────────────────────────────────────────────────────

  void _zoom(double delta) {
    _mapCtrl.move(
      _mapCtrl.camera.center,
      (_mapCtrl.camera.zoom + delta).clamp(3.0, 19.0),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')),
      backgroundColor: AppColors.dark,
    ));
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final center = _picked ?? widget.initial ?? _defaultCenter;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: const Text('تحديد موقع المتجر',
            style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _picked != null ? 15 : 12,
              onTap: (_, ll) => _onMapTap(ll),
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
                        Icon(Icons.location_pin,
                            color: AppColors.goldText, size: 42),
                        SizedBox(height: 2),
                      ],
                    ),
                  ),
                ]),
            ],
          ),

          // ── Instruction banner ────────────────────────────────────────────
          if (_picked == null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.dark.withOpacity(.88),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(children: [
                  Icon(Icons.touch_app_rounded, color: AppColors.goldLight, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'اضغط على الخريطة أو زر موقعي لتحديد موقع المتجر',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),

          // ── Zoom buttons ─────────────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: 140,
            child: Column(
              children: [
                _ZoomButton(icon: Icons.add, onTap: () => _zoom(1)),
                const SizedBox(height: 6),
                _ZoomButton(icon: Icons.remove, onTap: () => _zoom(-1)),
              ],
            ),
          ),

          // ── GPS button ───────────────────────────────────────────────────
          Positioned(
            left: 12,
            bottom: 140,
            child: FloatingActionButton.small(
              heroTag: 'loc',
              backgroundColor: Colors.white,
              elevation: 3,
              onPressed: _locating ? null : _goToMyLocation,
              child: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.dark))
                  : const Icon(Icons.my_location_rounded,
                      color: AppColors.dark, size: 20),
            ),
          ),

          // ── Confirm button ───────────────────────────────────────────────
          if (_picked != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, _picked),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 8)
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.goldLight, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_picked!.latitude.toStringAsFixed(5)}, ${_picked!.longitude.toStringAsFixed(5)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.goldLight),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('تأكيد',
                          style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 6)],
        ),
        child: Icon(icon, color: AppColors.dark, size: 20),
      ),
    );
  }
}
