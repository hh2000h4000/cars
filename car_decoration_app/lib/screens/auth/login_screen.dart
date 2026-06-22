import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showError('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }
    setState(() => _loading = true);
    // سيتم ربطه بالـ API لاحقاً
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text('تسجيل الدخول',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 19,
                        fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Spacer(),
                    const AppBackButton(),
                  ],
                ),
              ),
              Text(
                'أدخل بياناتك للدخول إلى حسابك.',
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5,
                  fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.6),
              ),
              const SizedBox(height: 28),

              // ── البريد الإلكتروني ──
              _FieldLabel('البريد الإلكتروني'),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5,
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'example@email.com',
                    hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 14,
                      fontWeight: FontWeight.w500, color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── كلمة المرور ──
              _FieldLabel('كلمة المرور'),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5,
                          fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '••••••••',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 18,
                            fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 3),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textMuted, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── زر الدخول ──
              _loading
                ? Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  )
                : DarkButton(label: 'دخول', onTap: _login),

              const SizedBox(height: 20),

              // ── إنشاء حساب ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ليس لديك حساب؟ ',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 13,
                      fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                    child: Text('إنشاء حساب',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13,
                        fontWeight: FontWeight.w800, color: AppColors.goldText)),
                  ),
                ],
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
    child: Text(text,
      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13,
        fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  );
}
