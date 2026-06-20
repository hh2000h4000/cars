import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../data/mock_data.dart';

class ShopMyStoreScreen extends StatelessWidget {
  const ShopMyStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = MockData.shops.first;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dark header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _LinesPainter())),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ShopAvatar(mono: shop.mono, size: 60, fontSize: 22),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(shop.name,
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                    const SizedBox(height: 3),
                                    Text(shop.area,
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white54)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
                                  child: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                                ),
                              ),
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

            // Services
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: Text('الخدمات المقدّمة',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: shop.services.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.goldBg,
                    border: Border.all(color: AppColors.goldLight),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(s.name, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                )).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Tags
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: Text('التخصصات',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: shop.tags.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(t, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                )).toList(),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
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
