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
  int _tabIndex = 0; // 0 = phone, 1 = email
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
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
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
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      _showError('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }
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
      body: Stack(
        children: [
          Column(
            children: [
              // ── Hero section ──
              Container(
                height: 290,
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
                        padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const AppLogoMark(size: 46),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('تزيين', style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: const Color(0xFFF7F1E2))),
                                    Text('CAR DECORATION', style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.goldMuted, letterSpacing: 1)),
                                  ],
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'مرحباً بعودتك',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFFFBF7EC), height: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'سجّل دخولك لمتابعة طلباتك والعناية بسيارتك.',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.goldMuted, height: 1.5),
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

          // ── Card overlapping hero ──
          Positioned(
            top: 264,
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
                      duration: const Duration(milliseconds: 220),
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
                        : DarkButton(
                            label: 'تسجيل الدخول',
                            onTap: _tabIndex == 0 ? _loginWithPhone : _loginWithEmail,
                          ),

                    const SizedBox(height: 22),

                    // ── Divider ──
                    _OrDivider(),

                    const SizedBox(height: 18),

                    // ── Social buttons ──
                    Row(
                      children: [
                        Expanded(child: _SocialButton(label: 'Google', isGoogle: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _SocialButton(label: 'Apple')),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Register link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ليس لديك حساب؟ ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/onboarding'),
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
      decoration: BoxDecoration(
        color: AppColors.goldBg,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _TabItem(label: 'رقم الجوال', active: selected == 0, onTap: () => onChanged(0)),
          _TabItem(label: 'اسم المستخدم / البريد', active: selected == 1, onTap: () => onChanged(1)),
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
              fontSize: 13,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Text('رقم الجوال', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Text('🇸🇦', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 5),
                    Text('+966', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    hintText: '5X XXX XXXX',
                    hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.goldBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.goldText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'سنرسل لك رمز تحقق (OTP) عبر رسالة نصية لتأكيد رقمك.',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.goldText, height: 1.5),
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Text('البريد الإلكتروني / اسم المستخدم', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.alternate_email_rounded, size: 19, color: AppColors.textMuted),
              ),
              Expanded(
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'example@email.com',
                    hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Password field
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('كلمة المرور', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            GestureDetector(
              onTap: () {},
              child: Text('نسيت كلمة المرور؟', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldText)),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.lock_outline_rounded, size: 19, color: AppColors.textMuted),
              ),
              Expanded(
                child: TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '••••••••',
                    hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 3),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggleObscure,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// "Or continue via" divider
// ─────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1.2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('أو المتابعة عبر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1.2)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Social button
// ─────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final bool isGoogle;
  const _SocialButton({required this.label, this.isGoogle = false});

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
            if (isGoogle)
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('G', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
              )
            else
              const Icon(Icons.apple, size: 23, color: AppColors.dark),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Grid painter (same as onboarding)
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
