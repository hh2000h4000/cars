import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/pending_shop.dart';
import '../../services/shop_admin_service.dart';

class AdminPendingScreen extends StatefulWidget {
  const AdminPendingScreen({super.key});

  @override
  State<AdminPendingScreen> createState() => _AdminPendingScreenState();
}

class _AdminPendingScreenState extends State<AdminPendingScreen> {
  List<PendingShop> _shops = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final shops = await ShopAdminService.getPendingShops();
      if (mounted) setState(() { _shops = shops; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'تعذر تحميل المتاجر'; _loading = false; });
    }
  }

  Future<void> _approve(PendingShop shop) async {
    try {
      await ShopAdminService.approveShop(shop.id);
      if (mounted) setState(() => shop.status = AdminShopStatus.approved);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('فشل الاعتماد، حاول مجدداً',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  Future<void> _reject(PendingShop shop) async {
    try {
      await ShopAdminService.rejectShop(shop.id);
      if (mounted) setState(() => shop.status = AdminShopStatus.rejected);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('فشل الرفض، حاول مجدداً',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _shops.where((s) => s.status == AdminShopStatus.pending).length;

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
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.chevron_right, color: Colors.white70, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                  // Refresh button
                  GestureDetector(
                    onTap: _load,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.goldText))
                  : _error != null
                      ? Center(child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Colors.white54)),
                            const SizedBox(height: 12),
                            TextButton(onPressed: _load,
                              child: Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.goldText))),
                          ],
                        ))
                      : _shops.isEmpty
                          ? Center(child: Text('لا توجد متاجر بانتظار المراجعة',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Colors.white38)))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: _shops.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) => _ShopCard(
                                shop: _shops[i],
                                onApprove: () => _confirm(context, 'اعتماد المتجر',
                                  'هل تريد اعتماد ${_shops[i].name}؟', () => _approve(_shops[i])),
                                onReject: () => _confirm(context, 'رفض المتجر',
                                  'هل تريد رفض ${_shops[i].name}؟', () => _reject(_shops[i])),
                              ),
                            ),
            ),
          ],
        ),
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
            onPressed: () { Navigator.pop(context); fn(); },
            child: Text('تأكيد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText))),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final PendingShop shop;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _ShopCard({required this.shop, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final isPending = shop.status == AdminShopStatus.pending;

    Color statusColor;
    String statusLabel;
    switch (shop.status) {
      case AdminShopStatus.approved:
        statusColor = AppColors.green;
        statusLabel = 'معتمد';
      case AdminShopStatus.rejected:
        statusColor = AppColors.red;
        statusLabel = 'مرفوض';
      default:
        statusColor = const Color(0xFFFF9800);
        statusLabel = 'بانتظار المراجعة';
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1912),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // ── Header: mono + name + date ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(shop.mono,
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white54)),
                ),
                const SizedBox(width: 12),
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
                Text(shop.submittedAt,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white30)),
              ],
            ),
          ),

          // ── CR + status badge ──
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(statusLabel,
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: statusColor)),
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
                  Expanded(
                    flex: 3,
                    child: _ActionBtn(
                      label: 'اعتماد',
                      color: AppColors.green,
                      textColor: Colors.white,
                      onTap: onApprove,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(
                    icon: Icons.close_rounded,
                    bgColor: AppColors.red.withOpacity(.12),
                    iconColor: AppColors.red,
                    onTap: onReject,
                  ),
                ],
              ),
            ),
          ],
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
