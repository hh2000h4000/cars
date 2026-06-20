import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../providers/app_provider.dart';
import '../../models/pending_shop.dart';

class AdminPendingScreen extends StatelessWidget {
  const AdminPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shops = context.watch<AppProvider>().pendingShops;
    final pendingCount = shops.where((s) => s.status == AdminShopStatus.pending).length;

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
                  // RIGHT: title (right-aligned in RTL)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اعتماد المتاجر',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('$pendingCount طلبات بانتظار المراجعة',
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
                itemCount: shops.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _ShopCard(shop: shops[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final PendingShop shop;
  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final isPending = shop.status == AdminShopStatus.pending;

    // Docs badge
    final String docsLabel;
    final Color docsColor;
    if (shop.status == AdminShopStatus.docsRequested) {
      docsLabel = 'طلب مستندات';
      docsColor = const Color(0xFF2196F3);
    } else if (shop.hasCompleteDocs) {
      docsLabel = 'مستندات مكتملة';
      docsColor = AppColors.green;
    } else {
      docsLabel = 'مستندات ناقصة';
      docsColor = AppColors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1912),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // ── Top: name + logo placeholder ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RIGHT: name + owner · city
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.name,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 3),
                      Text('${shop.ownerName} · ${shop.city}',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // LEFT: image placeholder + time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(shop.submittedAt,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white30)),
                  ],
                ),
              ],
            ),
          ),

          // ── Inner box: CR + docs badge ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // RIGHT: CR label + number
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('السجل التجاري',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white38)),
                      const SizedBox(height: 2),
                      Text(shop.crNumber.isNotEmpty ? shop.crNumber : '–',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white70)),
                    ],
                  ),
                  const Spacer(),
                  // LEFT: docs status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: docsColor.withOpacity(.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(docsLabel,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: docsColor)),
                  ),
                ],
              ),
            ),
          ),

          // ── Action buttons (pending only) ──
          if (isPending) ...[
            Container(height: 1, color: Colors.white10),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // RIGHT: approve (wide green)
                  Expanded(
                    flex: 3,
                    child: _ActionBtn(
                      label: 'اعتماد',
                      color: AppColors.green,
                      textColor: Colors.white,
                      onTap: () => _confirm(context, 'اعتماد المتجر',
                        'هل تريد اعتماد ${shop.name}؟', () => provider.approveShop(shop.id)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Docs icon button
                  _IconBtn(
                    icon: Icons.description_outlined,
                    bgColor: Colors.white.withOpacity(.08),
                    iconColor: Colors.white54,
                    onTap: () => provider.requestDocsFromShop(shop.id),
                  ),
                  const SizedBox(width: 8),
                  // LEFT: reject X
                  _IconBtn(
                    icon: Icons.close_rounded,
                    bgColor: AppColors.red.withOpacity(.12),
                    iconColor: AppColors.red,
                    onTap: () => _confirm(context, 'رفض المتجر',
                      'هل تريد رفض ${shop.name}؟', () => provider.rejectShop(shop.id)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirm(BuildContext context, String title, String msg, VoidCallback fn) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1912),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        content: Text(msg, textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white38))),
          TextButton(
            onPressed: () { fn(); Navigator.pop(context); },
            child: Text('تأكيد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText))),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 42,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: textColor)),
    ),
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.bgColor, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(11)),
      child: Icon(icon, color: iconColor, size: 20),
    ),
  );
}
