import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../theme.dart';

class ShopMyStoreScreen extends StatelessWidget {
  const ShopMyStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
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
                    child: Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.store_outlined, color: Colors.white54, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text('متجري', style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('قريباً — إدارة ملف المتجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, color: AppColors.textMuted)),
            ),
          ),
        ],
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
