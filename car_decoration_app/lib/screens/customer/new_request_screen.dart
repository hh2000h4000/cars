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
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _descCtrl.dispose();
    _notesCtrl.dispose();
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
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AppProvider>().addRequestFromApi(
        vehicleId: _selectedVehicleId!,
        description: _descCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false);
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      setState(() { _error = msg as String? ?? 'حدث خطأ، يرجى المحاولة مجدداً'; });
    } catch (_) {
      setState(() { _error = 'حدث خطأ، يرجى المحاولة مجدداً'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = context.watch<AppProvider>().vehicles;

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
