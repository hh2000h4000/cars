import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/auth_service.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.registerCustomer(
        fullName: _fullNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false);
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
                    Text('إنشاء حساب عميل', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Spacer(),
                    const AppBackButton(),
                  ],
                ),
              ),
              Text(
                'أنشئ حسابك في دقيقة — يتم تفعيل حساب العميل فوراً ويمكنك طلب الخدمات مباشرة.',
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.6),
              ),
              const SizedBox(height: 22),

              _FieldLabel('الاسم الكامل'),
              _inputField(controller: _fullNameCtrl, hint: 'عبدالله الحربي'),
              const SizedBox(height: 16),

              _FieldLabel('رقم الجوال'),
              _phoneField(),
              const SizedBox(height: 16),

              _FieldLabel('البريد الإلكتروني'),
              _inputField(controller: _emailCtrl, hint: 'example@email.com', ltr: true, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              _FieldLabel('كلمة المرور'),
              _passwordField(),
              const SizedBox(height: 24),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFCDD2))),
                  child: Text(_error!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),
              ],

              DarkButton(
                label: _loading ? 'جارٍ إنشاء الحساب...' : 'إنشاء الحساب',
                onTap: _loading ? null : _submit,
              ),
              const SizedBox(height: 16),
              const GreenInfoBanner(text: 'حساب العميل يُفعّل فوراً دون انتظار'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool ltr = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
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
    );
  }

  Widget _phoneField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: '5X XXX XXXX',
                hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.border))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇸🇦', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text('+966', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
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
