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

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.red.withOpacity(.15), borderRadius: BorderRadius.circular(10)),
                    child: Text('${disputes.where((d) => d.status == DisputeStatus.underReview).length} مفتوح',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.red)),
                  ),
                  const Spacer(),
                  Text('إدارة النزاعات', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1D17),
        border: Border.all(color: dispute.severity == DisputeSeverity.high ? AppColors.red.withOpacity(.3) : Colors.white10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Top accent
          if (dispute.severity == DisputeSeverity.high)
            Container(
              height: 3,
              decoration: const BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _SeverityBadge(dispute.severity),
                    const SizedBox(width: 8),
                    _StatusBadge(dispute.status),
                    const Spacer(),
                    Text('طلب #${dispute.requestId}', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(dispute.reason, textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 6),
                Text(dispute.description, textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w500, color: Colors.white54, height: 1.5)),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.white10),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(dispute.submittedAt, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white30)),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(dispute.customerName, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white70)),
                            const SizedBox(width: 4),
                            const Icon(Icons.person_outline, color: Colors.white38, size: 14),
                          ],
                        ),
                        Row(
                          children: [
                            Text(dispute.shopName, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white70)),
                            const SizedBox(width: 4),
                            const Icon(Icons.storefront_outlined, color: Colors.white38, size: 14),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (dispute.status == DisputeStatus.underReview) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(11)),
                            alignment: Alignment.center,
                            child: Text('طلب توضيح', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white70)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: Alignment.center,
                            child: Text('حل النزاع', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.dark)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final DisputeSeverity severity;
  const _SeverityBadge(this.severity);

  Color get color {
    switch (severity) {
      case DisputeSeverity.high: return AppColors.red;
      case DisputeSeverity.medium: return const Color(0xFFFF9800);
      case DisputeSeverity.low: return AppColors.textSecondary;
    }
  }

  String get label {
    switch (severity) {
      case DisputeSeverity.high: return 'عالي';
      case DisputeSeverity.medium: return 'متوسط';
      case DisputeSeverity.low: return 'منخفض';
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(999)),
    child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w800, color: color)),
  );
}

class _StatusBadge extends StatelessWidget {
  final DisputeStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final color = status == DisputeStatus.resolved ? AppColors.green : status == DisputeStatus.underReview ? AppColors.goldText : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w800, color: color)),
    );
  }
}
