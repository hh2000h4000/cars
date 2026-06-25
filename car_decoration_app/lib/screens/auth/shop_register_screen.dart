import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/auth_service.dart';

class ShopRegisterScreen extends StatefulWidget {
  const ShopRegisterScreen({super.key});

  @override
  State<ShopRegisterScreen> createState() => _ShopRegisterScreenState();
}

class _ShopRegisterScreenState extends State<ShopRegisterScreen> {
  final _shopNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _crNumberCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _shopPhoneCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _crNumberCtrl.dispose();
    _cityCtrl.dispose();
    _shopPhoneCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_shopNameCtrl.text.trim().isEmpty) return 'يرجى إدخال اسم المتجر';
    if (_crNumberCtrl.text.trim().isEmpty) return 'يرجى إدخال رقم السجل التجاري';
    if (_ownerNameCtrl.text.trim().isEmpty) return 'يرجى إدخال اسم المالك';
    if (_phoneCtrl.text.trim().isEmpty) return 'يرجى إدخال رقم الجوال';
    if (_shopPhoneCtrl.text.trim().isEmpty) return 'يرجى إدخال رقم جوال المتجر';
    if (_emailCtrl.text.trim().isEmpty) return 'يرجى إدخال البريد الإلكتروني';
    if (_cityCtrl.text.trim().isEmpty) return 'يرجى إدخال المدينة';
    if (_passwordCtrl.text.isEmpty) return 'يرجى إدخال كلمة المرور';
    if (_passwordCtrl.text.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    return null;
  }

  Future<void> _submit() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.registerShop(
        fullName: _ownerNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        shopName: _shopNameCtrl.text.trim(),
        crNumber: _crNumberCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        shopPhone: _shopPhoneCtrl.text.trim(),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text('تسجيل متجر / مركز', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Spacer(),
                    const AppBackButton(),
                  ],
                ),
              ),

              // Shop name section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderStrong, width: 2),
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFFFBF6EA),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: AppColors.goldText, size: 22),
                        const SizedBox(height: 5),
                        Text('شعار المتجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                      ],
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
                          Text('اسم المتجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _shopNameCtrl,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'مركز اللمسة الذهبية',
                              hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: AppColors.textMuted),
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildField(label: 'رقم السجل التجاري', controller: _crNumberCtrl, hint: '1010 567 893', ltr: true),
              _buildField(label: 'اسم المالك', controller: _ownerNameCtrl, hint: 'عبدالعزيز الشهري'),
              _buildField(label: 'رقم الجوال (للحساب)', controller: _phoneCtrl, hint: '5X XXX XXXX', ltr: true, keyboardType: TextInputType.phone),
              _buildField(label: 'رقم جوال المتجر', controller: _shopPhoneCtrl, hint: '011 XXX XXXX', ltr: true, keyboardType: TextInputType.phone),
              _buildField(label: 'البريد الإلكتروني', controller: _emailCtrl, hint: 'info@shop.sa', ltr: true, keyboardType: TextInputType.emailAddress),
              _buildField(label: 'المدينة', controller: _cityCtrl, hint: 'الرياض'),

              // Password
              _FieldLabel('كلمة المرور'),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 18, color: AppColors.textMuted, letterSpacing: 3),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textMuted, size: 20),
                    onPressed: () => setState(() { _obscurePassword = !_obscurePassword; }),
                  ),
                ),
              ),
              const SizedBox(height: 13),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFCDD2))),
                  child: Text(_error!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),
              ],

              DarkButton(
                label: _loading ? 'جارٍ إرسال الطلب...' : 'إرسال طلب التسجيل',
                onTap: _loading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool ltr = false,
    TextInputType? keyboardType,
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
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.goldText, width: 1.5)),
            ),
          ),
        ],
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
