import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _tabIndex = 1;
  bool _obscure = true;
  bool _loading = false;
  bool _rememberMe = false;

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final saved = await AuthService.getRememberedCredentials();
    if (saved != null && mounted) {
      setState(() {
        _emailController.text = saved.email;
        _passwordController.text = saved.password;
        _rememberMe = true;
        _tabIndex = 1;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_tabIndex == 0) {
      if (_phoneController.text.trim().isEmpty) {
        _showError('يرجى إدخال رقم الجوال');
        return;
      }
    } else {
      if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
        _showError('يرجى إدخال البريد الإلكتروني وكلمة المرور');
        return;
      }
    }
    setState(() => _loading = true);
    try {
      if (_tabIndex == 1) {
        final data = await AuthService.login(_emailController.text.trim(), _passwordController.text);
        if (!mounted) return;
        TextInput.finishAutofillContext();
        // Save or clear remembered credentials based on checkbox
        if (_rememberMe) {
          await AuthService.saveRememberedCredentials(
            _emailController.text.trim(),
            _passwordController.text,
          );
        } else {
          await AuthService.clearRememberedCredentials();
        }
        if (!mounted) return;
        final role = data['role'] as String? ?? 'Customer';
        if (role == 'Admin') {
          Navigator.pushNamedAndRemoveUntil(context, '/admin/dashboard', (_) => false);
        } else if (role == 'Shop') {
          Navigator.pushNamedAndRemoveUntil(context, '/shop/dashboard', (_) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false);
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      TextInput.finishAutofillContext(shouldSave: false);
      final msg = e.response?.data is Map
          ? e.response?.data['message'] as String?
          : null;
      _showError(msg ?? 'تعذر الاتصال بالخادم، تأكد من تشغيل الـ API');
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      TextInput.finishAutofillContext(shouldSave: false);
      _showError('حدث خطأ غير متوقع');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── Background column (gives Stack intrinsic height) ──
          Column(
            children: [
              Container(
                height: 310,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B1A14), Color(0xFF2A2618), Color(0xFF15140F)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _GridPainter())),
                    Positioned(
                      top: -60,
                      right: -40,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [AppColors.goldLight.withOpacity(.28), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const AppLogoMark(size: 46),
                                const SizedBox(width: 11),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('تزيين', style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: const Color(0xFFF7F1E2))),
                                    Text('CAR DECORATION', style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.goldMuted, letterSpacing: 1)),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'مرحباً بعودتك',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 30, fontWeight: FontWeight.w900, color: const Color(0xFFFBF7EC), height: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'سجّل دخولك لمتابعة طلباتك والعناية بسيارتك.',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.goldMuted, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),

          // ── White card overlapping hero ──
          Positioned(
            top: 282,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 36),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ── Tab switcher ──
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.goldBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildTab('اسم المستخدم / البريد', 1),
                          _buildTab('رقم الجوال', 0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Tab content ──
                    if (_tabIndex == 0) _buildPhoneTab() else _buildEmailTab(),
                    const SizedBox(height: 22),

                    // ── Login button ──
                    _loading
                        ? Container(
                            height: 54,
                            decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(16)),
                            alignment: Alignment.center,
                            child: const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                          )
                        : DarkButton(label: 'تسجيل الدخول', onTap: _login),
                    const SizedBox(height: 22),

                    // ── Divider ──
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border, thickness: 1.2)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('أو المتابعة عبر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                        ),
                        Expanded(child: Divider(color: AppColors.border, thickness: 1.2)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Social buttons ──
                    Row(
                      children: [
                        Expanded(child: _socialBtn('Apple', const Icon(Icons.apple, size: 23, color: AppColors.dark))),
                        const SizedBox(width: 12),
                        Expanded(child: _socialBtn('Google', Container(
                          width: 22, height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: const Color(0xFF4285F4), borderRadius: BorderRadius.circular(5)),
                          child: const Text('G', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                        ))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Register link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ليس لديك حساب؟ ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/onboarding'),
                          child: Text('إنشاء حساب جديد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab button ──
  Widget _buildTab(String label, int index) {
    final active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? AppColors.dark : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ── Phone tab content ──
  Widget _buildPhoneTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('رقم الجوال'),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              // Number input on RIGHT (first in RTL)
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                    hintText: '5X XXX XXXX',
                    hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                  ),
                ),
              ),
              // Country code on LEFT (second child in RTL = left side)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇸🇦', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text('+966', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'سنرسل لك رمز تحقق (OTP) عبر رسالة نصية لتأكيد رقمك.',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.goldText, height: 1.5),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.goldText),
            ],
          ),
        ),
      ],
    );
  }

  // ── Email tab content ──
  Widget _buildEmailTab() {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('اسم المستخدم أو البريد الإلكتروني'),
          _field(
            controller: _emailController,
            hint: 'أدخل بريدك أو اسم المستخدم',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email, AutofillHints.username],
            suffixIcon: const Icon(Icons.alternate_email_rounded, size: 19, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Text('نسيت كلمة المرور؟', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldText)),
              ),
              _label('كلمة المرور', noPad: true),
            ],
          ),
          const SizedBox(height: 8),
          _field(
            controller: _passwordController,
            hint: '••••••••',
            obscure: _obscure,
            autofillHints: const [AutofillHints.password],
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19, color: AppColors.textMuted),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textMuted, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          // ── Remember me ──────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _rememberMe = !_rememberMe),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: _rememberMe ? AppColors.dark : Colors.white,
                    border: Border.all(
                      color: _rememberMe ? AppColors.dark : AppColors.border,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _rememberMe
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 9),
                Text(
                  'تذكّرني',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, {bool noPad = false}) => Padding(
    padding: EdgeInsets.only(bottom: noPad ? 0 : 7),
    child: Text(text, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    bool obscure = false,
    List<String>? autofillHints,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color c, {double w = 1.0}) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: c, width: w));
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      textAlign: textDirection == TextDirection.ltr ? TextAlign.left : TextAlign.right,
      obscureText: obscure,
      autofillHints: autofillHints,
      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: border(AppColors.border),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.dark, w: 1.5),
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: obscure ? 18 : 13.5,
          fontWeight: obscure ? FontWeight.w700 : FontWeight.w500,
          color: AppColors.textMuted,
          letterSpacing: obscure ? 3 : 0,
        ),
        prefixIcon: prefixIcon != null ? Padding(padding: const EdgeInsets.only(right: 12), child: prefixIcon) : null,
        prefixIconConstraints: prefixIcon != null ? const BoxConstraints(minWidth: 44) : null,
        suffixIcon: suffixIcon != null ? Padding(padding: const EdgeInsets.only(left: 12), child: suffixIcon) : null,
        suffixIconConstraints: suffixIcon != null ? const BoxConstraints(minWidth: 44) : null,
      ),
    );
  }

  Widget _socialBtn(String label, Widget icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 1.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldLight.withOpacity(.07)
      ..strokeWidth = 1.5;
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
