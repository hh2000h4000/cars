import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../services/location_service.dart';
import '../../services/nominatim_location_service.dart';
import '../../theme.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapCtrl;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final LocationServiceProvider _svc = NominatimLocationService();

  static const _defaultCenter = LatLng(24.7136, 46.6753);

  LatLng? _picked;
  bool _locating = false;
  List<LocationSearchResult> _results = [];
  bool _searching = false;
  bool _showResults = false;
  Timer? _searchTimer;

  String? _address;
  bool _reverseLoading = false;
  Timer? _reverseTimer;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
    _picked = widget.initial;
    if (widget.initial != null) {
      _reverseGeocode(widget.initial!);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _searchTimer?.cancel();
    _reverseTimer?.cancel();
    super.dispose();
  }

  // ─── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String q) {
    _searchTimer?.cancel();
    if (q.trim().length < 2) {
      setState(() { _results = []; _showResults = false; });
      return;
    }
    _searchTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() => _searching = true);
      final r = await _svc.searchAddress(q.trim());
      if (!mounted) return;
      setState(() { _results = r; _searching = false; _showResults = true; });
    });
  }

  void _selectResult(LocationSearchResult r) {
    _searchCtrl.text = r.shortName;
    _searchFocus.unfocus();
    setState(() {
      _picked = r.position;
      _address = r.shortName;
      _showResults = false;
      _results = [];
    });
    _mapCtrl.move(r.position, 16);
  }

  // ─── Reverse geocode ───────────────────────────────────────────────────────

  void _reverseGeocode(LatLng ll) {
    _reverseTimer?.cancel();
    setState(() { _reverseLoading = true; _address = null; });
    _reverseTimer = Timer(const Duration(milliseconds: 700), () async {
      final addr = await _svc.reverseGeocode(ll);
      if (!mounted) return;
      setState(() { _address = addr; _reverseLoading = false; });
    });
  }

  // ─── Map events ────────────────────────────────────────────────────────────

  void _onMapTap(LatLng ll) {
    _searchFocus.unfocus();
    setState(() { _picked = ll; _showResults = false; });
    _reverseGeocode(ll);
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
      if (mounted) {
        setState(() => _picked = ll);
        _reverseGeocode(ll);
      }
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

          // ── Search bar + results ──────────────────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SearchBar(
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  searching: _searching,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchCtrl.clear();
                    setState(() { _results = []; _showResults = false; });
                  },
                ),
                if (_showResults && _results.isNotEmpty)
                  _SearchResults(results: _results, onSelect: _selectResult),
                if (!_showResults && _picked == null)
                  const _InstructionBanner(),
              ],
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
              child: _ConfirmButton(
                address: _address,
                loading: _reverseLoading,
                position: _picked!,
                onConfirm: () => Navigator.pop(context, _picked),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool searching;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.searching,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 8)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: AppColors.dark, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                  fontFamily: 'Tajawal', fontSize: 14, color: AppColors.dark),
              decoration: const InputDecoration(
                hintText: 'ابحث عن عنوان...',
                hintStyle: TextStyle(
                    fontFamily: 'Tajawal', fontSize: 14, color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (searching)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.dark)),
            )
          else if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.close_rounded, size: 18, color: Colors.grey),
              ),
            )
          else
            const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<LocationSearchResult> results;
  final ValueChanged<LocationSearchResult> onSelect;

  const _SearchResults({required this.results, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: results.map((r) {
            return InkWell(
              onTap: () => onSelect(r),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.goldText),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r.shortName.isNotEmpty ? r.shortName : r.displayName,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            color: AppColors.dark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _InstructionBanner extends StatelessWidget {
  const _InstructionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
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
            'ابحث عن عنوان أو اضغط على الخريطة لتحديد موقع المتجر',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
        ),
      ]),
    );
  }
}

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

class _ConfirmButton extends StatelessWidget {
  final String? address;
  final bool loading;
  final LatLng position;
  final VoidCallback onConfirm;

  const _ConfirmButton({
    required this.address,
    required this.loading,
    required this.position,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onConfirm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 8)],
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.goldLight, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: loading
                  ? const SizedBox(
                      height: 16,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white24,
                        color: AppColors.goldLight,
                      ),
                    )
                  : Text(
                      address ??
                          '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldLight),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
    );
  }
}
