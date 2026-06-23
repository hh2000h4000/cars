import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

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
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<Uint8List> _imageBytes = [];
  final _picker = ImagePicker();
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;

  @override
  void dispose() {
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    for (final xfile in picked) {
      final bytes = await xfile.readAsBytes();
      setState(() => _imageBytes.add(bytes));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      locale: const Locale('ar'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppColors.dark, onPrimary: AppColors.goldLight)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _preferredTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: AppColors.dark, onPrimary: AppColors.goldLight)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _preferredTime = picked);
  }

  String get _dateLabel {
    if (_preferredDate == null) return 'اختر التاريخ';
    final d = _preferredDate!;
    const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return '${d.day} ${months[d.month - 1]}';
  }

  String get _timeLabel {
    if (_preferredTime == null) return 'اختر الوقت';
    final h = _preferredTime!.hour;
    final m = _preferredTime!.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'م' : 'ص';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m $period';
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.pushNamed(context, '/customer/location-picker');
    if (result is String && result.isNotEmpty) {
      setState(() => _locationCtrl.text = result);
    }
  }

  void _goToShopSelect() {
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار مركبة أولاً')));
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة وصف الخدمة')));
      return;
    }
    if (_locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة موقع التنفيذ')));
      return;
    }
    Navigator.pushNamed(context, '/customer/requests/shop-select', arguments: {
      'vehicleId': _selectedVehicleId,
      'description': _descCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      'preferredDate': _preferredDate,
      'preferredTime': _preferredTime,
      'imageBytes': List<Uint8List>.from(_imageBytes),
    });
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
                          child: Row(children: [
                            const Icon(Icons.directions_car_outlined, color: AppColors.goldText),
                            const SizedBox(width: 10),
                            Text('أضف مركبة أولاً من شاشة مركباتي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                          ]),
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
                                    Row(children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(color: selected ? AppColors.dark : AppColors.surface, borderRadius: BorderRadius.circular(10)),
                                        alignment: Alignment.center,
                                        child: Text(v.mono, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w900, color: selected ? AppColors.goldLight : AppColors.textMuted)),
                                      ),
                                      const Spacer(),
                                      if (selected) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.dark, shape: BoxShape.circle)),
                                    ]),
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
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                      child: TextField(
                        controller: _descCtrl,
                        maxLines: 4,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, height: 1.6),
                        decoration: InputDecoration(
                          hintText: 'مثال: تظليل حراري كامل ٥٠٪ جوانب + ٧٠٪ أمامي...',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted, height: 1.6),
                          filled: true, fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                        ),
                      ),
                    ),

                    // ── صور توضيحية ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                      child: Text('صور توضيحية', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 90, height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.goldBg,
                                  border: Border.all(color: AppColors.goldLight, width: 1.5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.goldText, size: 28),
                              ),
                            ),
                            ..._imageBytes.asMap().entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.memory(entry.value, width: 90, height: 90, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 4, left: 4,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _imageBytes.removeAt(entry.key)),
                                      child: Container(
                                        width: 22, height: 22,
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                            if (_imageBytes.isEmpty) ...[
                              const SizedBox(width: 10),
                              _PhotoPlaceholder(),
                              const SizedBox(width: 10),
                              _PhotoPlaceholder(),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // ── التاريخ والوقت ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('التاريخ المفضّل', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _pickDate,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: _preferredDate != null ? AppColors.goldLight : AppColors.border),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(children: [
                                      Text(_dateLabel, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700,
                                        color: _preferredDate != null ? AppColors.textPrimary : AppColors.textMuted)),
                                      const Spacer(),
                                      const Icon(Icons.calendar_today_outlined, color: AppColors.goldText, size: 18),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الوقت المفضّل', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _pickTime,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: _preferredTime != null ? AppColors.goldLight : AppColors.border),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(children: [
                                      Text(_timeLabel, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700,
                                        color: _preferredTime != null ? AppColors.textPrimary : AppColors.textMuted)),
                                      const Spacer(),
                                      const Icon(Icons.access_time_outlined, color: AppColors.goldText, size: 18),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── موقع تنفيذ الخدمة ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                      child: Text('موقع تنفيذ الخدمة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                      child: GestureDetector(
                        onTap: _openLocationPicker,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _locationCtrl.text.isNotEmpty ? AppColors.goldLight : AppColors.border, width: _locationCtrl.text.isNotEmpty ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            children: [
                              Container(
                                height: 140,
                                color: const Color(0xFFF5F0E8),
                                child: Stack(children: [
                                  CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
                                  Center(child: Icon(Icons.location_on,
                                    color: _locationCtrl.text.isNotEmpty ? AppColors.dark : AppColors.goldText, size: 38)),
                                  Positioned(
                                    top: 10, right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(10)),
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        const Icon(Icons.edit_location_alt_outlined, color: AppColors.goldLight, size: 14),
                                        const SizedBox(width: 5),
                                        Text('اختر الموقع', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.goldLight)),
                                      ]),
                                    ),
                                  ),
                                ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(children: [
                                  const Icon(Icons.location_on_outlined, color: AppColors.goldText, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _locationCtrl.text.isEmpty ? 'انقر لاختيار موقعك على الخريطة' : _locationCtrl.text,
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700,
                                        color: _locationCtrl.text.isEmpty ? AppColors.textMuted : AppColors.textPrimary),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 18),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── ملاحظات إضافية ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                      child: Text('ملاحظات إضافية', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: TextField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, height: 1.6),
                        decoration: InputDecoration(
                          hintText: 'يفضّل التنفيذ في المرآب المغطى...',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted),
                          filled: true, fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                        ),
                      ),
                    ),
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
          label: 'التالي · اختيار المتاجر',
          onTap: _goToShopSelect,
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 90, height: 90,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xFFE8E3D8)),
    clipBehavior: Clip.hardEdge,
    child: CustomPaint(painter: _DiagonalStripePainter()),
  );
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
