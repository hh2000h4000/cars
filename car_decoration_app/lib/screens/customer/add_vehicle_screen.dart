import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  static const _brands = ['تويوتا', 'لكزس', 'مرسيدس', 'BMW', 'نيسان', 'هوندا', 'كيا', 'هيونداي'];
  static const _models = ['لاند كروزر', 'كامري', 'كورولا', 'برادو', 'يارس', 'هايلكس'];
  static const _years = ['2024', '2023', '2022', '2021', '2020', '2019', '2018', '2017'];
  static const _colors = [
    ('أبيض لؤلؤي', Color(0xFFF5F0E8)),
    ('أسود', Color(0xFF1A1A1A)),
    ('رمادي', Color(0xFF9E9E9E)),
    ('أزرق', Color(0xFF1565C0)),
    ('أحمر', Color(0xFFC62828)),
    ('فضي', Color(0xFFBDBDBD)),
    ('ذهبي', Color(0xFFD4A017)),
    ('بيج', Color(0xFFD7C9A7)),
  ];

  String _brand = 'تويوتا';
  String _model = 'لاند كروزر';
  String _year = '2023';
  int _colorIndex = 0;
  bool _loading = false;
  String? _error;
  final _plateCtrl = TextEditingController();
  final List<Uint8List> _imageBytes = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    for (final xfile in picked) {
      final bytes = await xfile.readAsBytes();
      if (_imageBytes.length < 5) setState(() => _imageBytes.add(bytes));
    }
  }

  Future<void> _save() async {
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AppProvider>().addVehicleFromApi(
        brand: _brand,
        model: _model,
        year: int.parse(_year),
        color: _colors[_colorIndex].$1,
        plateNumber: _plateCtrl.text.trim().isEmpty ? null : _plateCtrl.text.trim(),
        imageBytes: _imageBytes.isNotEmpty ? _imageBytes : null,
      );
      if (mounted) Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              child: Row(
                children: [
                  Text('إضافة مركبة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const Spacer(),
                  const AppBackButton(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── الماركة + الموديل ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('الماركة'),
                              _DropdownField(
                                value: _brand,
                                items: _brands,
                                onChanged: (v) => setState(() => _brand = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('الموديل'),
                              _DropdownField(
                                value: _model,
                                items: _models,
                                onChanged: (v) => setState(() => _model = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── سنة الصنع + اللون ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('سنة الصنع'),
                              _DropdownField(
                                value: _year,
                                items: _years,
                                onChanged: (v) => setState(() => _year = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label('اللون'),
                              GestureDetector(
                                onTap: () => _showColorPicker(context),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      Text(_colors[_colorIndex].$1,
                                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                      const Spacer(),
                                      Container(
                                        width: 20, height: 20,
                                        decoration: BoxDecoration(
                                          color: _colors[_colorIndex].$2,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.border),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── رقم اللوحة ──
                    _Label('رقم اللوحة (اختياري)'),
                    TextField(
                      controller: _plateCtrl,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'ر ب ح ٤٨٢١',
                        hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textMuted),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── صور المركبة ──
                    _Label('صور المركبة (اختياري)'),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                color: AppColors.goldBg,
                                border: Border.all(color: AppColors.goldLight, width: 1.5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, color: AppColors.goldText, size: 28),
                                  SizedBox(height: 4),
                                  Text('إضافة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                                ],
                              ),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (_error != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFCDD2))),
                        child: Text(_error!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8),
                    ],
                    DarkButton(
                      label: _loading ? 'جارٍ الحفظ...' : 'حفظ المركبة',
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

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اختر اللون', style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: List.generate(_colors.length, (i) {
                final (name, color) = _colors[i];
                return GestureDetector(
                  onTap: () {
                    setState(() => _colorIndex = i);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _colorIndex == i ? AppColors.goldBg : AppColors.surface,
                      border: Border.all(color: _colorIndex == i ? AppColors.goldLight : AppColors.border),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: AppColors.border))),
                        const SizedBox(width: 7),
                        Text(name, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
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
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  );
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 20),
        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1916)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, textAlign: TextAlign.right))).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

