import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../providers/app_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final pending = provider.pendingShops.where((s) => s.status.name == 'pending').length;
    final disputes = provider.disputes.where((d) => d.status.name == 'underReview').length;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ──
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('لوحة تحكم الإدارة',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                      const SizedBox(height: 2),
                      Text('مرحباً، المشرف',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    alignment: Alignment.center,
                    child: Text('A',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.dark)),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── 2×2 Stat cards ──
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.25,
                children: [
                  _StatCard(
                    label: 'إجمالي العملاء',
                    value: '3,482',
                    subtitle: '▲ 12% هذا الشهر',
                    subtitleColor: AppColors.green,
                  ),
                  _StatCard(
                    label: 'المتاجر المعتمدة',
                    value: '214',
                    subtitle: '$pending بانتظار الاعتماد',
                    subtitleColor: const Color(0xFFE65100),
                  ),
                  _StatCard(
                    label: 'طلبات نشطة',
                    value: '1,029',
                  ),
                  _StatCard(
                    label: 'نزاعات مفتوحة',
                    value: disputes > 0 ? disputes.toString() : '2',
                    valueColor: AppColors.red,
                    subtitle: 'تتطلب مراجعة',
                    subtitleColor: AppColors.red,
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // ── Quick management title ──
              Text('إدارة سريعة',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 12),

              // ── Quick action rows ──
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1912),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _QuickRow(
                      label: 'العملاء',
                      badge: '3,482',
                      onTap: () {},
                    ),
                    _RowDivider(),
                    _QuickRow(
                      label: 'المتاجر والاعتماد',
                      badge: '$pending جديد',
                      badgeColor: const Color(0xFFE65100),
                      onTap: () => Navigator.pushNamed(context, '/admin/pending'),
                    ),
                    _RowDivider(),
                    _QuickRow(label: 'الطلبات', onTap: () {}),
                    _RowDivider(),
                    _QuickRow(label: 'المحادثات', onTap: () {}),
                    _RowDivider(),
                    _QuickRow(label: 'عروض الأسعار', onTap: () {}),
                    _RowDivider(),
                    _QuickRow(
                      label: 'النزاعات والشكاوى',
                      badge: disputes > 0 ? disputes.toString() : '2',
                      badgeColor: AppColors.red,
                      onTap: () => Navigator.pushNamed(context, '/admin/disputes'),
                    ),
                    _RowDivider(),
                    _QuickRow(label: 'التقييمات', onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final String? subtitle;
  final Color? subtitleColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
    this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1912),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white54)),
        const SizedBox(height: 6),
        Text(value,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 26, fontWeight: FontWeight.w900, color: valueColor)),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!,
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700,
              color: subtitleColor ?? Colors.white38)),
        ],
      ],
    ),
  );
}

class _QuickRow extends StatelessWidget {
  final String label;
  final String? badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const _QuickRow({
    required this.label,
    this.badge,
    this.badgeColor = AppColors.goldText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(color: AppColors.goldLight, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(label,
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(badge!,
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: badgeColor)),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_left, color: Colors.white30, size: 18),
        ],
      ),
    ),
  );
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: Colors.white10);
}
