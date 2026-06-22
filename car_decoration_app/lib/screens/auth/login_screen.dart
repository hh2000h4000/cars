import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _tabIndex = 0;
  bool _obscure = true;
  bool _loading = false;

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithPhone() async {
    if (_phoneController.text.trim().isEmpty) {
      _showError('يرجى إدخال رقم الجوال');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false);
  }

  Future<void> _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await AuthService.login(email, password);
      if (!mounted) return;
      final role = data['role'] as String? ?? 'Customer';
      if (role == 'Admin') {
        Navigator.pushNamedAndRemoveUntil(context, '/admin/dashboard', (_) => false);
      } else if (role == 'Shop') {
        Navigator.pushNamedAndRemoveUntil(context, '/shop/dashboard', (_) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('البريد الإلكتروني أو كلمة المرور غير صحيحة');
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
          // ── Dark hero ──
          Container(
            height: 300,
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Top bar: back button LEFT, logo RIGHT
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.10),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('تزيين', style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: const Color(0xFFF7F1E2))),
                                Text('CAR DECORATION', style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.goldMuted, letterSpacing: 1)),
                              ],
                            ),
                            const SizedBox(width: 10),
                            const AppLogoMark(size: 46),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'مرحباً بعودتك',
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFFFBF7EC), height: 1.2),
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

          // ── White card overlapping hero ──
          Positioned(
            top: 272,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Tab switcher ──
                    _TabSwitcher(
                      selected: _tabIndex,
                      onChanged: (i) => setState(() => _tabIndex = i),
                    ),
                    const SizedBox(height: 24),

                    // ── Tab content ──
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _tabIndex == 0
                          ? _PhoneTab(controller: _phoneController, key: const ValueKey(0))
                          : _EmailTab(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              obscure: _obscure,
                              onToggleObscure: () => setState(() => _obscure = !_obscure),
                              key: const ValueKey(1),
                            ),
                    ),
                    const SizedBox(height: 22),

                    // ── Login button ──
                    _loading
                        ? Container(
                            height: 54,
                            decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(16)),
                            alignment: Alignment.center,
                            child: const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                          )
                        : DarkButton(label: 'تسجيل الدخول', onTap: _tabIndex == 0 ? _loginWithPhone : _loginWithEmail),

                    const SizedBox(height: 22),

                    // ── Or divider ──
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
                        Expanded(
                          child: _SocialButton(
                            label: 'Apple',
                            child: const Icon(Icons.apple, size: 23, color: AppColors.dark),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SocialButton(
                            label: 'Google',
                            child: Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: const Color(0xFF4285F4), borderRadius: BorderRadius.circular(5)),
                              child: const Text('G', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                            ),
                          ),
                        ),
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
}

// ─────────────────────────────────────────────
// Tab Switcher
// ─────────────────────────────────────────────
class _TabSwitcher extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _TabSwitcher({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _TabItem(label: 'اسم المستخدم / البريد', active: selected == 1, onTap: () => onChanged(1)),
          _TabItem(label: 'رقم الجوال', active: selected == 0, onTap: () => onChanged(0)),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabItem({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
}

// ─────────────────────────────────────────────
// Phone Tab
// ─────────────────────────────────────────────
class _PhoneTab extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneTab({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const _FieldLabel('رقم الجوال'),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              // Phone input fills the right side (first child in RTL)
              Expanded(
                child: TextField(
                  controller: controller,
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
              // Country code on the LEFT (second child in RTL row = left side)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇸🇦', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 5),
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
}

// ─────────────────────────────────────────────
// Email / Username Tab
// ─────────────────────────────────────────────
class _EmailTab extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final VoidCallback onToggleObscure;
  const _EmailTab({
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.onToggleObscure,
    super.key,
  });

  static OutlineInputBorder _border(Color color, {double width = 1.0}) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: color, width: width));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Email field ──
        const _FieldLabel('اسم المستخدم أو البريد الإلكتروني'),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.dark, width: 1.5),
            // suffixIcon = LEFT side in RTL
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Icon(Icons.alternate_email_rounded, size: 19, color: AppColors.textMuted),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 46),
            hintText: 'أدخل بريدك أو اسم المستخدم',
            hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 16),

        // ── Password label row ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text('نسيت كلمة المرور؟', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldText)),
            ),
            const _FieldLabel('كلمة المرور'),
          ],
        ),
        const SizedBox(height: 7),

        // ── Password field ──
        TextField(
          controller: passwordController,
          obscureText: obscure,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.dark, width: 1.5),
            // prefixIcon = RIGHT side in RTL (lock icon)
            prefixIcon: const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.lock_outline_rounded, size: 19, color: AppColors.textMuted),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 46),
            // suffixIcon = LEFT side in RTL (eye icon)
            suffixIcon: GestureDetector(
              onTap: onToggleObscure,
              child: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Icon(
                  obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 46),
            hintText: '••••••••',
            hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 3),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Shared field label
// ─────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  );
}

// ─────────────────────────────────────────────
// Social button
// ─────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final Widget child;
  const _SocialButton({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
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
            child,
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Grid painter
// ─────────────────────────────────────────────
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
