import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/service_request.dart';
import '../../services/request_service.dart';
import '../../services/upload_service.dart';

class EditRequestScreen extends StatefulWidget {
  const EditRequestScreen({super.key});

  @override
  State<EditRequestScreen> createState() => _EditRequestScreenState();
}

class _EditRequestScreenState extends State<EditRequestScreen> {
  ServiceRequest? _request;
  bool _initialized = false;

  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<Uint8List> _newImageBytes = [];
  List<String> _existingUrls = [];
  final _picker = ImagePicker();
  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;
  bool _loading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ServiceRequest) {
      _request = args;
      _descCtrl.text = args.serviceType;
      _locationCtrl.text = args.location;
      _notesCtrl.text = args.notes ?? '';
      _existingUrls = List.from(args.imageUrls);
      _preferredDate = args.appointmentDate;
      if (args.appointmentDate != null) {
        _preferredTime = TimeOfDay.fromDateTime(args.appointmentDate!);
      }
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final total = _existingUrls.length + _newImageBytes.length;
    if (total >= 5) return;
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    for (final xfile in picked) {
      if (_existingUrls.length + _newImageBytes.length >= 5) break;
      final bytes = await xfile.readAsBytes();
      setState(() => _newImageBytes.add(bytes));
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

  Future<void> _openLocationPicker() async {
    final result = await Navigator.pushNamed(context, '/customer/location-picker');
    if (result is String && result.isNotEmpty) {
      setState(() => _locationCtrl.text = result);
    }
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

  Future<void> _save() async {
    if (_request == null) return;
    if (_descCtrl.text.trim().isEmpty) {
      setState(() => _error = 'يرجى كتابة وصف الخدمة');
      return;
    }
    if (_locationCtrl.text.trim().isEmpty) {
      setState(() => _error = 'يرجى تحديد موقع التنفيذ');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      List<String> newUrls = [];
      if (_newImageBytes.isNotEmpty) {
        newUrls = await UploadService.uploadImages(_newImageBytes);
      }
      final allUrls = [..._existingUrls, ...newUrls];

      final updated = await RequestService.updateRequest(
        id: _request!.id,
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        preferredDate: _preferredDate,
        preferredTime: _preferredTime,
        imageUrls: allUrls.isNotEmpty ? allUrls : null,
      );
      if (mounted) {
        context.read<AppProvider>().updateRequest(updated);
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map ? e.response?.data['message'] : null;
      setState(() => _error = msg as String? ?? 'حدث خطأ، يرجى المحاولة مجدداً');
    } catch (_) {
      setState(() => _error = 'حدث خطأ، يرجى المحاولة مجدداً');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = _request;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              child: Row(
                children: [
                  Text('تعديل الطلب', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const Spacer(),
                  const AppBackButton(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Vehicle read-only card
                    if (req != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${req.vehicleBrand} ${req.vehicleModel}',
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                                Text('${req.vehicleYear}${req.vehicleColor.isNotEmpty ? " · ${req.vehicleColor}" : ""}',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.goldMuted)),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                              child: Text('المركبة المختارة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.goldMuted)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],

                    // Description
                    _Label('وصف الخدمة المطلوبة'),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 4,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, height: 1.6),
                      decoration: InputDecoration(
                        hintText: 'مثال: تظليل حراري كامل ٥٠٪ جوانب + ٧٠٪ أمامي...',
                        hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted),
                        filled: true, fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Images
                    _Label('صور توضيحية'),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
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
                          ..._existingUrls.asMap().entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(entry.value, width: 90, height: 90, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 90, height: 90,
                                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                                      child: const Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4, left: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _existingUrls.removeAt(entry.key)),
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
                          ..._newImageBytes.asMap().entries.map((entry) => Padding(
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
                                    onTap: () => setState(() => _newImageBytes.removeAt(entry.key)),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Date & Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('التاريخ المفضّل'),
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
                              _Label('الوقت المفضّل'),
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
                    const SizedBox(height: 22),

                    // Location
                    _Label('موقع تنفيذ الخدمة'),
                    GestureDetector(
                      onTap: _openLocationPicker,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _locationCtrl.text.isNotEmpty ? AppColors.goldLight : AppColors.border,
                            width: _locationCtrl.text.isNotEmpty ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          children: [
                            Container(
                              height: 120,
                              color: const Color(0xFFF5F0E8),
                              child: Stack(children: [
                                CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
                                Center(child: Icon(Icons.location_on,
                                  color: _locationCtrl.text.isNotEmpty ? AppColors.dark : AppColors.goldText, size: 34)),
                                Positioned(
                                  top: 10, right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(10)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      const Icon(Icons.edit_location_alt_outlined, color: AppColors.goldLight, size: 14),
                                      const SizedBox(width: 5),
                                      Text('تغيير الموقع', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.goldLight)),
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
                    const SizedBox(height: 22),

                    // Notes
                    _Label('ملاحظات إضافية'),
                    TextField(
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
                    const SizedBox(height: 22),

                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: Text(_error!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8),
                    ],

                    DarkButton(
                      label: _loading ? 'جارٍ الحفظ...' : 'حفظ التعديلات',
                      onTap: _loading ? null : _save,
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  );
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
