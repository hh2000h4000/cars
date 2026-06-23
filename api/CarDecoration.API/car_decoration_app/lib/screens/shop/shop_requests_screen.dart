import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class ShopRequestsScreen extends StatefulWidget {
  const ShopRequestsScreen({super.key});

  @override
  State<ShopRequestsScreen> createState() => _ShopRequestsScreenState();
}

class _ShopRequestsScreenState extends State<ShopRequestsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final inbox = provider.shopInbox;
    final newCount = inbox.length;

    final tabs = ['جديدة ($newCount)', 'بانتظار العميل', 'قيد التنفيذ'];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
              child: Text('الطلبات الواردة',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            ),

            // ── Filter tabs ──
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                itemCount: tabs.length,
                itemBuilder: (_, i) {
                  final active = _tab == i;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(left: i < tabs.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: active ? AppColors.dark : Colors.white,
                        border: Border.all(color: active ? AppColors.dark : AppColors.border),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(tabs[i],
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700,
                          color: active ? Colors.white : AppColors.textSecondary)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // ── Content ──
            Expanded(
              child: _tab == 0
                  ? ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                      itemCount: inbox.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _RequestCard(item: inbox[i]),
                    )
                  : _EmptyTab(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Request card ──────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final ShopInboxItem item;
  const _RequestCard({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer row
              Row(
                children: [
                  // Avatar (visual RIGHT)
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center,
                    child: Text(item.mono,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                  ),
                  const SizedBox(width: 10),
                  // Name + area/distance/time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.customerName,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('${item.area} · ${item.distance} · ${item.timeAgo}',
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  // Badge (visual LEFT)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.goldBg,
                      border: Border.all(color: AppColors.goldLight),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('جديد',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Service type
              Text(item.serviceType,
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 5),

              // Vehicle with icon
              Row(
                children: [
                  const Icon(Icons.directions_car_outlined, color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(item.vehicleInfo,
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),

        // Divider
        const Divider(height: 1, color: AppColors.border),

        // Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Row(
            children: [
              // View details (visual RIGHT)
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/shop/request-detail', arguments: item.requestId),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('عرض التفاصيل',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Send quote (visual LEFT)
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/shop/send-quote', arguments: item.requestId),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('إرسال عرض',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.inbox_outlined, color: AppColors.goldText, size: 32),
        ),
        const SizedBox(height: 14),
        Text('لا توجد طلبات',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text('ستظهر هنا الطلبات عند وصولها',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ],
    ),
  );
}
