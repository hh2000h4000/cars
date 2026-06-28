import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:latlong2/latlong.dart';

import '../../theme.dart';
import '../../services/shop_profile_service.dart';
import '../../services/upload_service.dart';
import '../../services/api_client.dart';
import 'location_picker_screen.dart';

class ShopResubmitScreen extends StatefulWidget {
  final ShopProfile shop;
  const ShopResubmitScreen({super.key, required this.shop});

  @override
  State<ShopResubmitScreen> createState() => _ShopResubmitScreenState();
}

class _ShopResubmitScreenState extends State<ShopResubmitScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _postalCodeCtrl;
  late final TextEditingController _buildingNumberCtrl;
  late final TextEditingController _additionalNumCtrl;
  late final TextEditingController _crNumberCtrl;
  late final TextEditingController _idNumberCtrl;

  // ── Location ──────────────────────────────────────────────────────────────
  LatLng? _location;

  // ── Logo ─────────────────────────────────────────────────────────────────
  Uint8List? _logoBytes;
  String?    _logoUrl;
  bool       _logoUploading = false;

  // ── CR document ──────────────────────────────────────────────────────────
  String?    _crDocName;
  String?    _crDocUrl;
  bool       _crDocUploading = false;

  // ── ID document ──────────────────────────────────────────────────────────
  String?    _idDocName;
  String?    _idDocUrl;
  bool       _idDocUploading = false;

  // ── Form state ───────────────────────────────────────────────────────────
  bool    _loading = false;
  String? _error;

  static final _phoneRe = RegExp(r'^0[15]\d{8}$');
  static final _crRe    = RegExp(r'^\d{10}$');
  static final _idRe    = RegExp(r'^\d{10}$');

  @override
  void initState() {
    super.initState();
    final s = widget.shop;
    _nameCtrl          = TextEditingController(text: s.name);
    _phoneCtrl         = TextEditingController(text: s.phone);
    _cityCtrl          = TextEditingController(text: s.city);
    _streetCtrl        = TextEditingController(text: s.street);
    _districtCtrl      = TextEditingController(text: s.district);
    _postalCodeCtrl    = TextEditingController(text: s.postalCode);
    _buildingNumberCtrl = TextEditingController(text: s.buildingNumber ?? '');
    _additionalNumCtrl = TextEditingController(text: s.additionalNumber ?? '');
    _crNumberCtrl      = TextEditingController(text: s.crNumber);
    _idNumberCtrl      = TextEditingController(text: s.idNumber ?? '');
    _logoUrl           = s.logoUrl;
    if (s.latitude != null && s.longitude != null) {
      _location = LatLng(s.latitude!, s.longitude!);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _streetCtrl.dispose();
    _districtCtrl.dispose();
    _postalCodeCtrl.dispose();
    _buildingNumberCtrl.dispose();
    _additionalNumCtrl.dispose();
    _crNumberCtrl.dispose();
    _idNumberCtrl.dispose();
    super.dispose();
  }

  // ── Validation ───────────────────────────────────────────────────────────

  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty)        return 'يرجى إدخال اسم المتجر';
    if (_crNumberCtrl.text.trim().isEmpty)    return 'يرجى إدخال رقم السجل التجاري';
    if (!_crRe.hasMatch(_crNumberCtrl.text.trim())) return 'رقم السجل التجاري يجب أن يكون 10 أرقام إنجليزية';
    if (_crDocUrl == null)                    return 'يرجى رفع صورة أو ملف السجل التجاري';
    if (_idNumberCtrl.text.trim().isEmpty)    return 'يرجى إدخال رقم الهوية الوطنية';
    if (!_idRe.hasMatch(_idNumberCtrl.text.trim())) return 'رقم الهوية يجب أن يكون 10 أرقام';
    if (_idDocUrl == null)                    return 'يرجى رفع صورة أو ملف الهوية';
    if (_phoneCtrl.text.trim().isEmpty)       return 'يرجى إدخال رقم جوال المتجر';
    if (!_phoneRe.hasMatch(_phoneCtrl.text.trim())) return 'رقم الجوال يجب أن يبدأ بـ 05 أو 01 ويكون 10 أرقام';
    if (_cityCtrl.text.trim().isEmpty)        return 'يرجى إدخال المدينة';
    if (_streetCtrl.text.trim().isEmpty)      return 'يرجى إدخال اسم الشارع';
    if (_districtCtrl.text.trim().isEmpty)    return 'يرجى إدخال اسم الحي';
    if (_postalCodeCtrl.text.trim().isEmpty)  return 'يرجى إدخال الرمز البريدي';
    if (_location == null)                    return 'يرجى تحديد موقع المتجر على الخريطة';
    return null;
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => LocationPickerScreen(initial: _location)),
    );
    if (result != null && mounted) setState(() => _location = result);
  }

  // ── Logo picker ───────────────────────────────────────────────────────────

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() { _logoBytes = bytes; _logoUploading = true; _error = null; });
    try {
      final url = await UploadService.uploadDocument(bytes, 'logo.jpg');
      if (mounted) setState(() { _logoUrl = url; _logoUploading = false; });
    } catch (e) {
      if (mounted) setState(() { _logoUploading = false; _error = ApiClient.extractError(e); });
    }
  }

  // ── Document pickers ──────────────────────────────────────────────────────

  Future<void> _pickCrDoc() async {
    const typeGroup = XTypeGroup(
      label: 'documents',
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() { _crDocName = file.name; _crDocUploading = true; _error = null; });
    try {
      final url = await UploadService.uploadDocument(bytes, file.name);
      if (mounted) setState(() { _crDocUrl = url; _crDocUploading = false; });
    } catch (e) {
      if (mounted) setState(() { _crDocUploading = false; _error = ApiClient.extractError(e); });
    }
  }

  Future<void> _pickIdDoc() async {
    const typeGroup = XTypeGroup(
      label: 'documents',
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() { _idDocName = file.name; _idDocUploading = true; _error = null; });
    try {
      final url = await UploadService.uploadDocument(bytes, file.name);
      if (mounted) setState(() { _idDocUrl = url; _idDocUploading = false; });
    } catch (e) {
      if (mounted) setState(() { _idDocUploading = false; _error = ApiClient.extractError(e); });
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) { setState(() => _error = err); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final updated = await ShopProfileService.resubmitMyShop(
        name:             _nameCtrl.text.trim(),
        phone:            _phoneCtrl.text.trim(),
        city:             _cityCtrl.text.trim(),
        street:           _streetCtrl.text.trim(),
        district:         _districtCtrl.text.trim(),
        postalCode:       _postalCodeCtrl.text.trim(),
        buildingNumber:   _buildingNumberCtrl.text.trim().isEmpty ? null : _buildingNumberCtrl.text.trim(),
        additionalNumber: _additionalNumCtrl.text.trim().isEmpty ? null : _additionalNumCtrl.text.trim(),
        latitude:         _location?.latitude,
        longitude:        _location?.longitude,
        crNumber:         _crNumberCtrl.text.trim(),
        idNumber:         _idNumberCtrl.text.trim().isEmpty ? null : _idNumberCtrl.text.trim(),
        logoUrl:          _logoUrl,
        crDocumentUrl:    _crDocUrl,
        idDocumentUrl:    _idDocUrl,
      );
      if (mounted) Navigator.pop(context, updated);
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = ApiClient.extractError(e); });
    }
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Row(children: [
      Container(width: 3, height: 16,
        decoration: BoxDecoration(color: AppColors.goldText, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(
        fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
    ]),
  );

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool ltr = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            style: TextStyle(
              fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600,
              color: readOnly ? AppColors.textMuted : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textMuted),
              helperText: helperText,
              helperStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: AppColors.textMuted),
              filled: true,
              fillColor: readOnly ? AppColors.surface : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: readOnly ? AppColors.border : AppColors.goldText,
                  width: 1.5,
                ),
              ),
              suffixIcon: readOnly
                  ? const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textMuted)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _docPicker({
    required String label,
    required String? docName,
    required String? docUrl,
    required bool uploading,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label),
          GestureDetector(
            onTap: uploading ? null : onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: docUrl != null ? const Color(0xFFF0FDF4) : Colors.white,
                border: Border.all(
                  color: docUrl != null ? AppColors.green.withOpacity(.5) : AppColors.border,
                  width: docUrl != null ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: uploading
                  ? const Row(children: [
                      SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText)),
                      SizedBox(width: 12),
                      Text('جارٍ الرفع...', style: TextStyle(
                        fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textMuted)),
                    ])
                  : docUrl != null
                      ? Row(children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(
                            docName ?? 'تم الرفع بنجاح',
                            style: const TextStyle(
                              fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700,
                              color: AppColors.green),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          )),
                          GestureDetector(
                            onTap: onTap,
                            child: const Text('تغيير', style: TextStyle(
                              fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700,
                              color: AppColors.goldText)),
                          ),
                        ])
                      : const Row(children: [
                          Icon(Icons.upload_file_outlined, color: AppColors.goldText, size: 20),
                          SizedBox(width: 10),
                          Expanded(child: Text('اختر ملف (PDF، JPG، PNG)', style: TextStyle(
                            fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.textMuted))),
                          Icon(Icons.chevron_left, color: AppColors.textMuted, size: 18),
                        ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mono = _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : 'م';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        elevation: 0,
        title: const Text('تصحيح وإعادة التقديم',
          style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner إعلامي ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.goldBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldText.withOpacity(.3)),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, color: AppColors.goldText, size: 18),
                SizedBox(width: 10),
                Expanded(child: Text(
                  'صحّح البيانات أو الوثائق التي طُلب منك تعديلها ثم أرسل الطلب للمراجعة.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5,
                    fontWeight: FontWeight.w600, color: AppColors.goldText, height: 1.5),
                )),
              ]),
            ),

            const SizedBox(height: 20),

            // ── شعار المتجر + اسمه ───────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _logoUploading ? null : _pickLogo,
                  child: Container(
                    width: 84, height: 84,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _logoUrl != null ? AppColors.goldText : AppColors.borderStrong,
                        width: _logoUrl != null ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFFFBF6EA),
                      image: _logoUrl != null && _logoBytes == null
                          ? DecorationImage(image: NetworkImage(_logoUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _logoUploading
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText))
                        : _logoBytes != null
                            ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                            : _logoUrl == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, color: AppColors.goldText, size: 24),
                                      SizedBox(height: 4),
                                      Text('شعار المتجر', style: TextStyle(
                                        fontFamily: 'Tajawal', fontSize: 9.5, fontWeight: FontWeight.w700,
                                        color: AppColors.goldText)),
                                      Text('(اختياري)', style: TextStyle(
                                        fontFamily: 'Tajawal', fontSize: 9, color: AppColors.textMuted)),
                                    ],
                                  )
                                : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('اسم المتجر *', style: TextStyle(
                          fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'مركز اللمسة الذهبية',
                            hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted),
                            filled: true, fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── بيانات السجل التجاري ──────────────────────────────────
            _sectionHeader('بيانات السجل التجاري'),

            _field(
              label: 'رقم السجل التجاري *',
              controller: _crNumberCtrl,
              hint: '1010567893',
              ltr: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              helperText: '10 أرقام إنجليزية فقط',
            ),

            _docPicker(
              label: 'صورة / ملف السجل التجاري *',
              docName: _crDocName,
              docUrl: _crDocUrl,
              uploading: _crDocUploading,
              onTap: _pickCrDoc,
            ),

            // ── بيانات الهوية ─────────────────────────────────────────
            _sectionHeader('بيانات الهوية'),

            _field(
              label: 'رقم الهوية الوطنية *',
              controller: _idNumberCtrl,
              hint: '1XXXXXXXXX',
              ltr: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              helperText: '10 أرقام — الهوية الوطنية أو الإقامة',
            ),

            _docPicker(
              label: 'صورة / ملف الهوية *',
              docName: _idDocName,
              docUrl: _idDocUrl,
              uploading: _idDocUploading,
              onTap: _pickIdDoc,
            ),

            // ── بيانات تواصل المتجر ───────────────────────────────────
            _sectionHeader('بيانات تواصل المتجر'),

            _field(
              label: 'رقم جوال المتجر *',
              controller: _phoneCtrl,
              hint: '05XXXXXXXX',
              ltr: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              helperText: '10 أرقام — يبدأ بـ 05 أو 01',
            ),

            _field(
              label: 'المدينة *',
              controller: _cityCtrl,
              hint: 'الرياض',
            ),

            // ── العنوان الوطني ────────────────────────────────────────
            _sectionHeader('العنوان الوطني'),

            _field(
              label: 'الشارع *',
              controller: _streetCtrl,
              hint: 'شارع الملك فهد',
            ),

            _field(
              label: 'الحي *',
              controller: _districtCtrl,
              hint: 'حي العليا',
            ),

            _field(
              label: 'الرمز البريدي *',
              controller: _postalCodeCtrl,
              hint: '12345',
              ltr: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
            ),

            Row(children: [
              Expanded(child: _field(
                label: 'رقم المبنى',
                controller: _buildingNumberCtrl,
                hint: '1234',
                ltr: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              )),
              const SizedBox(width: 12),
              Expanded(child: _field(
                label: 'الرقم الإضافي',
                controller: _additionalNumCtrl,
                hint: '5678',
                ltr: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              )),
            ]),

            // ── موقع المتجر ───────────────────────────────────────────
            _sectionHeader('موقع المتجر على الخريطة'),

            Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: GestureDetector(
                onTap: _pickLocation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _location != null ? const Color(0xFFF0FDF4) : Colors.white,
                    border: Border.all(
                      color: _location != null ? AppColors.green.withOpacity(.5) : AppColors.border,
                      width: _location != null ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: _location != null
                      ? Row(children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.green, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(
                            '${_location!.latitude.toStringAsFixed(5)}, ${_location!.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13,
                              fontWeight: FontWeight.w700, color: AppColors.green),
                          )),
                          const Text('تغيير', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11,
                            fontWeight: FontWeight.w700, color: AppColors.goldText)),
                        ])
                      : const Row(children: [
                          Icon(Icons.add_location_alt_outlined, color: AppColors.goldText, size: 20),
                          SizedBox(width: 10),
                          Expanded(child: Text('حدد موقع المتجر على الخريطة *',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 13,
                              fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                          Icon(Icons.chevron_left, color: AppColors.textMuted, size: 18),
                        ]),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ── Error banner ──────────────────────────────────────────
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13,
                      color: Color(0xFFD32F2F), fontWeight: FontWeight.w600))),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            // ── Submit button ─────────────────────────────────────────
            GestureDetector(
              onTap: (_loading || _logoUploading || _crDocUploading || _idDocUploading) ? null : _submit,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: (_loading || _logoUploading || _crDocUploading || _idDocUploading)
                      ? AppColors.border
                      : AppColors.dark,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldLight))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.send_rounded, color: AppColors.goldLight, size: 17),
                        SizedBox(width: 8),
                        Text('إرسال الطلب للمراجعة', style: TextStyle(
                          fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800,
                          color: AppColors.goldLight)),
                      ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: const TextStyle(
      fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800,
      color: AppColors.textPrimary)),
  );
}
