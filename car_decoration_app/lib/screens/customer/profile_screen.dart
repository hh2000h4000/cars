import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/auth_service.dart';
import 'dart:math' as math;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _menuItems = [
    (Icons.person_outline, 'المعلومات الشخصية', null),
    (Icons.directions_car_outlined, 'سياراتي', '/customer/vehicles'),
    (Icons.list_alt_outlined, 'طلباتي وسجل الطلبات', '/customer/requests'),
    (Icons.star_outline_rounded, 'تقييماتي', null),
    (Icons.chat_bubble_outline, 'شكاوي ونزاعاتي', '/customer/complaint'),
    (Icons.location_on_outlined, 'العناوين المحفوظة', null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Dark header ──
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
              ),
              child: Stack(
                children: [
                  // Diagonal lines
                  Positioned.fill(child: CustomPaint(painter: _LinesPainter())),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        children: [
                          // Avatar + name + edit
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Text('ع', style: TextStyle(fontFamily: 'Tajawal', fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.dark)),
                              ),
                              const SizedBox(width: 14),
                              // Name + phone
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('عبدالله الحربي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                    const SizedBox(height: 3),
                                    Text('+966 50 123 4567', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w500, color: Colors.white54)),
                                  ],
                                ),
                              ),
                              // Edit button
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Stats
                          Row(
                            children: [
                              _DarkStat('8', 'تقييمات'),
                              _DarkDivider(),
                              _DarkStat('2', 'طلبات نشطة'),
                              _DarkDivider(),
                              _DarkStat('3', 'مركبات'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Menu ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: List.generate(_menuItems.length, (i) {
                  final (icon, label, route) = _menuItems[i];
                  return Column(
                    children: [
                      if (i > 0) const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
                      GestureDetector(
                        onTap: route != null ? () {
                          if (route == '/customer/complaint') {
                            Navigator.pushNamed(context, route, arguments: 'req1');
                          } else {
                            Navigator.pushNamed(context, route);
                          }
                        } : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          child: Row(
                            children: [
                              // Icon box
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(10)),
                                child: Icon(icon, color: AppColors.goldText, size: 18),
                              ),
                              const SizedBox(width: 14),
                              Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const Spacer(),
                              const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // ── Logout ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
              child: GestureDetector(
                onTap: () async {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/auth/login', (_) => false);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_outlined, color: AppColors.red, size: 18),
                      const SizedBox(width: 8),
                      Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.red)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  final String value;
  final String label;
  const _DarkStat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white54)),
      ],
    ),
  );
}

class _DarkDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 30, color: Colors.white12);
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4B96A).withOpacity(0.09)
      ..strokeWidth = 1.0;
    const spacing = 22.0;
    final count = (size.width + size.height) ~/ spacing + 2;
    for (int i = 0; i < count; i++) {
      final x = i * spacing - size.height;
      canvas.drawLine(Offset(x, 0), Offset(x + size.height * math.tan(math.pi / 4), size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_LinesPainter old) => false;
}
