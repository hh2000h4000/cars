import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/pending_shop.dart';

class AdminPendingScreen extends StatelessWidget {
  const AdminPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shops = context.watch<AppProvider>().pendingShops;

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
                    decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(10)),
                    child: Text('${shops.where((s) => s.status == AdminShopStatus.pending).length} بانتظار',
                      style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                  ),
                  const Spacer(),
                  Text('موافقة المتاجر', style: GoogleFonts.tajawal(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1D17),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                _StatusBadge(shop.status),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(shop.name, style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text('${shop.city} · ${shop.submittedAt}', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                  ],
                ),
                const SizedBox(width: 12),
                ShopAvatar(mono: shop.mono, size: 46, fontSize: 18),
              ],
            ),
          ),

          // Owner info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white06, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _InfoRow(Icons.person_outline, shop.ownerName),
                  const SizedBox(height: 6),
                  _InfoRow(Icons.phone_outlined, shop.phone),
                  const SizedBox(height: 6),
                  _InfoRow(Icons.badge_outlined, 'CR: ${shop.crNumber}'),
                ],
              ),
            ),
          ),

          // Tags
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Wrap(
              spacing: 6, runSpacing: 6,
              alignment: WrapAlignment.end,
              children: shop.services.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white08, borderRadius: BorderRadius.circular(999)),
                child: Text(s, style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white60)),
              )).toList(),
            ),
          ),

          // Action buttons (only for pending)
          if (isPending) ...[
            const Divider(height: 1, color: Colors.white10),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      label: 'طلب مستندات',
                      color: Colors.white24,
                      textColor: Colors.white70,
                      onTap: () => provider.requestDocsFromShop(shop.id),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionBtn(
                      label: 'رفض',
                      color: AppColors.red.withOpacity(.15),
                      textColor: AppColors.red,
                      onTap: () => _showConfirmDialog(context, 'رفض المتجر', 'هل تريد رفض طلب ${shop.name}؟', () => provider.rejectShop(shop.id)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _ActionBtn(
                      label: 'اعتماد المتجر',
                      color: AppColors.green,
                      textColor: Colors.white,
                      onTap: () => _showConfirmDialog(context, 'اعتماد المتجر', 'هل تريد اعتماد ${shop.name}؟', () => provider.approveShop(shop.id)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1D17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, textAlign: TextAlign.right, style: GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        content: Text(message, textAlign: TextAlign.right, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: Text('تأكيد', style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText)),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AdminShopStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: status.color.withOpacity(.15), borderRadius: BorderRadius.circular(999)),
    child: Text(status.label, style: GoogleFonts.tajawal(fontSize: 11.5, fontWeight: FontWeight.w800, color: status.color)),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Spacer(),
      Text(text, style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white60)),
      const SizedBox(width: 8),
      Icon(icon, color: Colors.white38, size: 16),
    ],
  );
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
      height: 40,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
      alignment: Alignment.center,
      child: Text(label, style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w800, color: textColor)),
    ),
  );
}
