import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class ShopRequestsScreen extends StatelessWidget {
  const ShopRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<AppProvider>().requests;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
              child: Row(
                children: [
                  const Spacer(),
                  Text('الطلبات', style: TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                ],
              ),
            ),

            // Filter tabs
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                children: [
                  _FilterTab('الكل', true),
                  _FilterTab('جديدة', false),
                  _FilterTab('قيد التنفيذ', false),
                  _FilterTab('مكتملة', false),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final req = requests[i];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/shop/request-detail', arguments: req.id),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              StatusBadge(label: req.status.label, type: req.status.colorType),
                              const Spacer(),
                              Text('طلب #${req.id}', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(req.serviceType, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 3),
                          Text('${req.vehicleBrand} ${req.vehicleModel} ${req.vehicleYear}',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.chevron_left, color: AppColors.goldText, size: 16),
                              Text('عرض التفاصيل', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                              const Spacer(),
                              Text(req.dateLabel, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                              const SizedBox(width: 4),
                              const Icon(Icons.access_time, color: AppColors.textMuted, size: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterTab(this.label, this.active);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: active ? AppColors.dark : Colors.white,
      border: Border.all(color: active ? AppColors.dark : AppColors.border),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textSecondary)),
  );
}
