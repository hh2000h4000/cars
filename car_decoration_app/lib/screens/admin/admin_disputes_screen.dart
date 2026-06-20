import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../providers/app_provider.dart';
import '../../models/dispute.dart';

class AdminDisputesScreen extends StatelessWidget {
  const AdminDisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final disputes = context.watch<AppProvider>().disputes;
    final openCount = disputes.where((d) => d.status != DisputeStatus.resolved).length;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: [
                  // RIGHT: title + open count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إدارة النزاعات',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('$openCount نزاع مفتوح',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                    ],
                  ),
                  const Spacer(),
                  // LEFT: back button
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.white70, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: disputes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _DisputeCard(dispute: disputes[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final Dispute dispute;
  const _DisputeCard({required this.dispute});

  Color get _accentColor {
    switch (dispute.status) {
      case DisputeStatus.underReview: return AppColors.red;
      case DisputeStatus.waitingShop: return AppColors.goldText;
      case DisputeStatus.resolved: return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return Stack(
      children: [
        // ── Card body ──
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1912),
            border: Border.all(color: accent.withOpacity(.22)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP: status badge | dispute ID
                    Row(
                      children: [
                        _StatusBadge(dispute.status, accent),
                        const Spacer(),
                        Text(dispute.id,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white38)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Dispute title
                    Text(dispute.reason,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    // Info: request · customer ← shop
                    Text(
                      'الطلب #${dispute.requestId} · ${dispute.customerName} ← ${dispute.shopName}',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white38),
                    ),
                  ],
                ),
              ),

              Container(height: 1, color: Colors.white10),

              // ── Action buttons ──
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // RIGHT: اتخاذ قرار (gold, wider)
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.goldText.withOpacity(.14),
                            border: Border.all(color: AppColors.goldLight.withOpacity(.25)),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: Text('اتخاذ قرار',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // LEFT: مراجعة المحادثة (dark)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.07),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: Text('مراجعة المحادثة',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white60)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Left accent bar ──
        Positioned(
          left: 0, top: 0, bottom: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DisputeStatus status;
  final Color color;
  const _StatusBadge(this.status, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(.15),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(status.label,
      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
  );
}
