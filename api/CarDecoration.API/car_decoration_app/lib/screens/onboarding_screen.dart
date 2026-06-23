import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import '../providers/app_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Column(
            children: [
          // Hero section
          Container(
            height: 340,
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
                // Grid pattern
                Positioned.fill(
                  child: CustomPaint(painter: _GridPainter()),
                ),
                // Glow
                Positioned(
                  top: -60,
                  right: -40,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.goldLight.withOpacity(.32), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 24, 26, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const AppLogoMark(size: 52),
                            const SizedBox(width: 11),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('تزيين', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w900, color: const Color(0xFFF7F1E2))),
                                Text('CAR DECORATION', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.goldMuted, letterSpacing: 1)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'العناية بسيارتك\nتصلك أينما كنت',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 30, fontWeight: FontWeight.w900, color: const Color(0xFFFBF7EC), height: 1.25, letterSpacing: -.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'منصة احترافية تربطك بأفضل مراكز تزيين السيارات في مدينتك.',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.goldMuted, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
            ],
          ),

          // Account type selection overlapping hero
          Positioned(
            top: 314,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
              child: SingleChildScrollView(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اختر نوع الحساب', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 5),
                  Text('كيف تريد استخدام التطبيق؟', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 22),

                  // Customer option
                  _AccountTypeCard(
                    icon: Icons.person_outline_rounded,
                    title: 'عميل',
                    subtitle: 'أملك سيارة وأبحث عن خدمة تزيين',
                    onTap: () {
                      context.read<AppProvider>().userType = UserType.customer;
                      Navigator.pushNamed(context, '/auth/customer-register');
                    },
                  ),
                  const SizedBox(height: 14),

                  // Shop option
                  _AccountTypeCard(
                    icon: Icons.storefront_outlined,
                    title: 'متجر / مركز تزيين',
                    subtitle: 'أقدّم خدمات تزيين وأبحث عن عملاء',
                    onTap: () {
                      context.read<AppProvider>().userType = UserType.shop;
                      Navigator.pushNamed(context, '/auth/shop-register');
                    },
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('لديك حساب بالفعل؟ ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/auth/login'),
                        child: Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Admin demo shortcut
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        context.read<AppProvider>().userType = UserType.admin;
                        Navigator.pushNamed(context, '/admin/dashboard');
                      },
                      child: Text('دخول الإدارة (تجريبي)', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ),
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


class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountTypeCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.06), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: AppColors.goldText, size: 26),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_left, color: Color(0xFFC9C4B8), size: 22),
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
