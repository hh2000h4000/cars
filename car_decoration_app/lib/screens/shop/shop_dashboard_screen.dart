import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';

class ShopDashboardScreen extends StatefulWidget {
  const ShopDashboardScreen({super.key});

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen> {
  bool _isOpen = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final inbox = provider.shopInbox;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dark header ──
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        children: [
                          // Avatar | name+status | toggle
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Avatar
                              ShopAvatar(mono: 'ل', size: 52, fontSize: 20),
                              const Spacer(),
                              // Name + status
                              Column(
                                children: [
                                  Text('لمسات الفخامة',
                                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_rounded, color: AppColors.green, size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isOpen ? 'متجر معتمد · متاح للطلبات' : 'متجر معتمد · مغلق حالياً',
                                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700,
                                          color: _isOpen ? AppColors.green : Colors.white54)),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Toggle
                              Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: _isOpen,
                                  onChanged: (v) => setState(() => _isOpen = v),
                                  activeColor: Colors.white,
                                  activeTrackColor: AppColors.green,
                                  inactiveThumbColor: Colors.white54,
                                  inactiveTrackColor: Colors.white24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Stats row
                          Row(
                            children: [
                              _HeaderStat(value: '4.9', sub: '312 عملية', hasStar: true),
                              _HeaderDivider(),
                              _HeaderStat(value: '8', sub: 'طلبات جديدة'),
                              _HeaderDivider(),
                              _HeaderStat(value: '12,840', sub: 'إيراد الشهر (ر.س)'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── نظرة عامة ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: Text('نظرة عامة',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.65,
                children: const [
                  _OverviewCard(value: '8', label: 'طلبات بانتظار رد', hasRedDot: true),
                  _OverviewCard(value: '5', label: 'عروض قيد الانتظار'),
                  _OverviewCard(value: '3', label: 'أعمال قيد التنفيذ'),
                  _OverviewCard(value: '21', label: 'مكتملة هذا الشهر'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── أحدث الطلبات ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: Row(
                children: [
                  Text('أحدث الطلبات',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Text('عرض الكل',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
              itemCount: inbox.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = inbox[i];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/shop/request-detail', arguments: item.requestId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Customer avatar
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.dark,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: Text(item.mono,
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                        ),
                        const SizedBox(width: 12),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.serviceType,
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text('${item.vehicleInfo} · ${item.distance}',
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Time
                        Text(item.timeAgo,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header stat cell ──────────────────────────────────────────────────────────
class _HeaderStat extends StatelessWidget {
  final String value;
  final String sub;
  final bool hasStar;
  const _HeaderStat({required this.value, required this.sub, this.hasStar = false});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(value,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
            if (hasStar) ...[
              const SizedBox(width: 3),
              const Icon(Icons.star_rounded, color: AppColors.star, size: 18),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(sub,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white54)),
      ],
    ),
  );
}

class _HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 32, color: Colors.white12);
}

// ── Overview card ─────────────────────────────────────────────────────────────
class _OverviewCard extends StatelessWidget {
  final String value;
  final String label;
  final bool hasRedDot;
  const _OverviewCard({required this.value, required this.label, this.hasRedDot = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (hasRedDot) ...[
              const SizedBox(width: 6),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle)),
            ],
          ],
        ),
        Text(value,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
      ],
    ),
  );
}

// ── Diagonal lines painter ─────────────────────────────────────────────────────
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
