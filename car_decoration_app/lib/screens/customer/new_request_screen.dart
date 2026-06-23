import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import 'dart:math' as math;

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  String? _selectedVehicleId;
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final Set<String> _selectedShopIds = {};
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _descCtrl.dispose();
    _notesCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedVehicleId == null) {
      setState(() { _error = 'يرجى اختيار مركبة أولاً'; });
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      setState(() { _error = 'يرجى كتابة وصف الخدمة المطلوبة'; });
      return;
    }
    if (_locationCtrl.text.trim().isEmpty) {
      setState(() { _error = 'يرجى كتابة موقع تنفيذ الخدمة'; });
      return;
    }
    if (_selectedShopIds.isEmpty) {
      setState(() { _error = 'يرجى اختيار متجر واحد على الأقل'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AppProvider>().addRequestFromApi(
        vehicleId: _selectedVehicleId!,
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        shopIds: _selectedShopIds.toList(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false);
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map) {
          msg = errors.entries.map((e) => '${e.key}: ${e.value}').join('\n');
        } else {
          msg = data['message']?.toString() ?? data['title']?.toString() ?? data.toString();
        }
      } else {
        msg = 'خطأ ${e.response?.statusCode ?? ''}: ${e.message}';
      }
      setState(() { _error = msg; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final vehicles = provider.vehicles;
    final shops = provider.shops;

    if (_selectedVehicleId == null && vehicles.isNotEmpty) {
      final main = vehicles.where((v) => v.isMain).toList();
      _selectedVehicleId = main.isNotEmpty ? main.first.id : vehicles.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              child: Row(
                children: [
                  Text('طلب خدمة جديد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const Spacer(),
                  const AppBackButton(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── اختر المركبة ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                      child: Text('اختر المركبة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    if (vehicles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.goldLight)),
                          child: Row(
                            children: [
                              const Icon(Icons.directions_car_outlined, color: AppColors.goldText),
                              const SizedBox(width: 10),
                              Text('أضف مركبة أولاً من شاشة مركباتي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 108,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                          itemCount: vehicles.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final v = vehicles[i];
                            final selected = v.id == _selectedVehicleId;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedVehicleId = v.id),
                              child: Container(
                                width: 130,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: selected ? AppColors.dark : AppColors.border, width: selected ? 2 : 1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 36, height: 36,
                                          decoration: BoxDecoration(color: selected ? AppColors.dark : AppColors.surface, borderRadius: BorderRadius.circular(10)),
                                          alignment: Alignment.center,
                                          child: Text(v.mono, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w900, color: selected ? AppColors.goldLight : AppColors.textMuted)),
                                        ),
                                        const Spacer(),
                                        if (selected) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.dark, shape: BoxShape.circle)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('${v.brand} ${v.model}', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(v.year.toString(), style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 22),

                    // ── وصف الخدمة ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                      child: Text('وصف الخدمة المطلوبة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: TextField(
                        controller: _descCtrl,
                        maxLines: 4,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, height: 1.6),
                        decoration: InputDecoration(
                          hintText: 'مثال: تظليل حراري كامل ٥٠٪ جوانب + ٧٠٪ أمامي...',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted, height: 1.6),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── الموقع ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                      child: Text('موقع تنفيذ الخدمة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                      child: TextField(
                        controller: _locationCtrl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'مثال: حي الياسمين، الرياض',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(14),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.goldText, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                        ),
                      ),
                    ),

                    // ── اختيار المتاجر ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                      child: Text('اختر المتاجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    if (shops.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                        child: Text('لا توجد متاجر متاحة حالياً', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted)),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: shops.map((shop) {
                            final selected = _selectedShopIds.contains(shop.id);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (selected) _selectedShopIds.remove(shop.id);
                                else _selectedShopIds.add(shop.id);
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected ? AppColors.dark : Colors.white,
                                  border: Border.all(color: selected ? AppColors.dark : AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (selected) ...[
                                      const Icon(Icons.check, color: AppColors.goldLight, size: 14),
                                      const SizedBox(width: 5),
                                    ],
                                    Text(shop.name,
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700,
                                        color: selected ? AppColors.goldLight : AppColors.textPrimary)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    // ── ملاحظات إضافية ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                      child: Text('ملاحظات إضافية (اختياري)', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: TextField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, height: 1.6),
                        decoration: InputDecoration(
                          hintText: 'مثال: يفضّل التنفيذ في المرآب المغطى...',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                        ),
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFCDD2))),
                          child: Text(_error!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).padding.bottom + 14),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
        child: DarkButton(
          label: _loading ? 'جارٍ إرسال الطلب...' : 'إرسال الطلب',
          onTap: _loading ? null : _submit,
        ),
      ),
    );
  }
}

class _DiagonalStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD4CFC4)..strokeWidth = 8;
    for (double i = -size.height; i < size.width + size.height; i += 16) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(_DiagonalStripePainter old) => false;
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFDDD8CC)..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(_MapGridPainter old) => false;
}

// ignore: unused_element
class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 90, height: 90,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xFFE8E3D8)),
    clipBehavior: Clip.hardEdge,
    child: CustomPaint(painter: _DiagonalStripePainter()),
  );
}
