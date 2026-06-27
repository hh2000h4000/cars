import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/auth_service.dart';
import '../../services/upload_service.dart';
import '../../services/api_client.dart';

class ShopRegisterScreen extends StatefulWidget {
  const ShopRegisterScreen({super.key});

  @override
  State<ShopRegisterScreen> createState() => _ShopRegisterScreenState();
}

class _ShopRegisterScreenState extends State<ShopRegisterScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _shopNameCtrl    = TextEditingController();
  final _crNumberCtrl    = TextEditingController();
  final _ownerNameCtrl   = TextEditingController();
  final _idNumberCtrl    = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _shopPhoneCtrl   = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _cityCtrl        = TextEditingController();
  final _passwordCtrl    = TextEditingController();

  // ── Logo ─────────────────────────────────────────────────────────────────
  Uint8List? _logoBytes;
  String?    _logoUrl;
  bool       _logoUploading = false;

  // ── CR document ──────────────────────────────────────────────────────────
  String?    _crDocName;
  Uint8List? _crDocBytes;
  String?    _crDocUrl;
  bool       _crDocUploading = false;

  // ── ID document ──────────────────────────────────────────────────────────
  String?    _idDocName;
  Uint8List? _idDocBytes;
  String?    _idDocUrl;
  bool       _idDocUploading = false;

  // ── Form state ───────────────────────────────────────────────────────────
  bool    _obscurePassword = true;
  bool    _loading = false;
  String? _error;

  static final _phoneRe = RegExp(r'^0[15]\d{8}$');
  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _crRe    = RegExp(r'^\d{10}$');
  static final _digitsOnly = RegExp(r'^\d+$');

  @override
  void dispose() {
    _shopNameCtrl.dispose(); _crNumberCtrl.dispose();
    _ownerNameCtrl.dispose(); _idNumberCtrl.dispose();
    _phoneCtrl.dispose(); _shopPhoneCtrl.dispose();
    _emailCtrl.dispose(); _cityCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Validation ───────────────────────────────────────────────────────────

  String? _validate() {
    if (_shopNameCtrl.text.trim().isEmpty) return 'يرجى إدخال اسم المتجر';
    if (_crNumberCtrl.text.trim().isEmpty) return 'يرجى إدخال رقم السجل التجاري';
    if (!_crRe.hasMatch(_crNumberCtrl.text.trim())) return 'رقم السجل التجاري يجب أن يكون 10 أرقام إنجليزية';
    if (_crDocUrl == null) return 'يرجى رفع صورة أو ملف السجل التجاري';
    if (_ownerNameCtrl.text.trim().isEmpty) return 'يرجى إدخال اسم المالك';
    if (_idNumberCtrl.text.trim().isEmpty) return 'يرجى إدخال رقم الهوية';
    if (_idDocUrl == null) return 'يرجى رفع صورة أو ملف الهوية';
    if (_phoneCtrl.text.trim().isEmpty) return 'يرجى إدخال رقم جوال المالك';
    if (!_phoneRe.hasMatch(_phoneCtrl.text.trim())) return 'رقم الجوال يجب أن يبدأ بـ 05 أو 01 ويكون 10 أرقام';
    if (_emailCtrl.text.trim().isEmpty) return 'يرجى إدخال البريد الإلكتروني';
    if (!_emailRe.hasMatch(_emailCtrl.text.trim())) return 'صيغة البريد الإلكتروني غير صحيحة';
    if (_passwordCtrl.text.isEmpty) return 'يرجى إدخال كلمة المرور';
    if (_passwordCtrl.text.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    if (_shopPhoneCtrl.text.trim().isEmpty) return 'يرجى إدخال رقم جوال المتجر';
    if (!_phoneRe.hasMatch(_shopPhoneCtrl.text.trim())) return 'رقم جوال المتجر يجب أن يبدأ بـ 05 أو 01 ويكون 10 أرقام';
    if (_cityCtrl.text.trim().isEmpty) return 'يرجى إدخال المدينة';
    return null;
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
      if (mounted) setState(() {
        _logoUploading = false;
        _error = ApiClient.extractError(e);
      });
    }
  }

  // ── Document pickers ──────────────────────────────────────────────────────

  Future<void> _pickCrDoc() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    setState(() { _crDocName = file.name; _crDocBytes = bytes; _crDocUploading = true; _error = null; });
    try {
      final url = await UploadService.uploadDocument(bytes, file.name);
      if (mounted) setState(() { _crDocUrl = url; _crDocUploading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _crDocUploading = false;
        _error = ApiClient.extractError(e);
      });
    }
  }

  Future<void> _pickIdDoc() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    setState(() { _idDocName = file.name; _idDocBytes = bytes; _idDocUploading = true; _error = null; });
    try {
      final url = await UploadService.uploadDocument(bytes, file.name);
      if (mounted) setState(() { _idDocUrl = url; _idDocUploading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _idDocUploading = false;
        _error = ApiClient.extractError(e);
      });
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) { setState(() => _error = err); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.registerShop(
        fullName:       _ownerNameCtrl.text.trim(),
        phone:          _phoneCtrl.text.trim(),
        email:          _emailCtrl.text.trim(),
        password:       _passwordCtrl.text,
        shopName:       _shopNameCtrl.text.trim(),
        crNumber:       _crNumberCtrl.text.trim(),
        city:           _cityCtrl.text.trim(),
        shopPhone:      _shopPhoneCtrl.text.trim(),
        idNumber:       _idNumberCtrl.text.trim(),
        crDocumentUrl:  _crDocUrl!,
        idDocumentUrl:  _idDocUrl!,
        logoUrl:        _logoUrl,
      );
      if (mounted) Navigator.pushNamed(context, '/auth/shop-pending');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String?;
      setState(() { _error = msg ?? 'حدث خطأ، يرجى المحاولة مجدداً'; });
    } catch (_) {
      setState(() { _error = 'حدث خطأ، يرجى المحاولة مجدداً'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Row(children: [
      Container(width: 3, height: 16, decoration: BoxDecoration(color: AppColors.goldText, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
    ]),
  );

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool ltr = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscure = false,
    Widget? suffix,
    String? helperText,
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
            obscureText: obscure,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textMuted),
              helperText: helperText,
              helperStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
              suffixIcon: suffix,
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
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText)),
                      SizedBox(width: 12),
                      Text('جارٍ الرفع...', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    ])
                  : docUrl != null
                      ? Row(children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(
                            docName ?? 'تم الرفع بنجاح',
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          )),
                          GestureDetector(
                            onTap: onTap,
                            child: const Text('تغيير', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                          ),
                        ])
                      : Row(children: [
                          const Icon(Icons.upload_file_outlined, color: AppColors.goldText, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(child: Text('اختر ملف (PDF، JPG، PNG)',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                          const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 18),
                        ]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(children: [
                  const Text('تسجيل متجر / مركز',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const Spacer(),
                  const AppBackButton(),
                ]),
              ),

              // ── شعار المتجر + اسمه ───────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo picker
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
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: _logoUploading
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText))
                          : _logoBytes != null
                              ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, color: AppColors.goldText, size: 24),
                                    SizedBox(height: 4),
                                    Text('شعار المتجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                                    Text('(اختياري)', style: TextStyle(fontFamily: 'Tajawal', fontSize: 9, color: AppColors.textMuted)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('اسم المتجر *', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _shopNameCtrl,
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

              // ── معلومات المتجر التجارية ───────────────────────────────────
              _sectionHeader('بيانات السجل التجاري'),

              _buildField(
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

              // ── معلومات المالك ────────────────────────────────────────────
              _sectionHeader('بيانات المالك'),

              _buildField(
                label: 'اسم المالك *',
                controller: _ownerNameCtrl,
                hint: 'عبدالعزيز الشهري',
              ),

              _buildField(
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

              _buildField(
                label: 'رقم الجوال الشخصي *',
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

              // ── بيانات الحساب ──────────────────────────────────────────────
              _sectionHeader('بيانات حساب المتجر'),

              _buildField(
                label: 'البريد الإلكتروني *',
                controller: _emailCtrl,
                hint: 'info@myshop.sa',
                ltr: true,
                keyboardType: TextInputType.emailAddress,
              ),

              // Password
              _FieldLabel('كلمة المرور *'),
              Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, color: AppColors.textMuted, letterSpacing: 3),
                    helperText: '6 أحرف على الأقل',
                    helperStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: AppColors.textMuted),
                    filled: true, fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textMuted, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ),

              // ── بيانات تواصل المتجر ───────────────────────────────────────
              _sectionHeader('بيانات تواصل المتجر'),

              _buildField(
                label: 'رقم جوال المتجر *',
                controller: _shopPhoneCtrl,
                hint: '05XXXXXXXX',
                ltr: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                helperText: '10 أرقام — يبدأ بـ 05 أو 01',
              ),

              _buildField(
                label: 'المدينة *',
                controller: _cityCtrl,
                hint: 'الرياض',
              ),

              const SizedBox(height: 6),

              // ── Error banner ──────────────────────────────────────────────
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
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600))),
                  ]),
                ),
                const SizedBox(height: 16),
              ],

              DarkButton(
                label: _loading ? 'جارٍ إرسال الطلب...' : 'إرسال طلب التسجيل',
                onTap: (_loading || _logoUploading || _crDocUploading || _idDocUploading) ? null : _submit,
              ),
            ],
          ),
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
    child: Text(text, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  );
}
