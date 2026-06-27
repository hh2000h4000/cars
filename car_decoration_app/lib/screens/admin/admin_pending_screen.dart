import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                      decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.chevron_right, color: Colors.white70, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('اعتماد المتاجر',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('$pendingCount طلبات بانتظار المراجعة',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _load,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(11)),
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
                            Text(_error!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Colors.white54)),
                            const SizedBox(height: 12),
                            TextButton(onPressed: _load,
                              child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.goldText))),
                          ],
                        ))
                      : _shops.isEmpty
                          ? const Center(child: Text('لا توجد متاجر بانتظار المراجعة',
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
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        content: Text(msg, textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white38))),
          TextButton(
            onPressed: () { Navigator.pop(context); fn(); },
            child: const Text('تأكيد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText))),
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
        statusColor = AppColors.green; statusLabel = 'معتمد';
      case AdminShopStatus.rejected:
        statusColor = AppColors.red; statusLabel = 'مرفوض';
      default:
        statusColor = const Color(0xFFFF9800); statusLabel = 'بانتظار المراجعة';
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
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(shop.mono,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white54)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.name,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 3),
                      Text('${shop.ownerName} · ${shop.city}',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                    ],
                  ),
                ),
                Text(shop.submittedAt,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white30)),
              ],
            ),
          ),

          // ── Info grid ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Row 1: CR number + status
                  Row(
                    children: [
                      _InfoChip(label: 'السجل التجاري', value: shop.crNumber.isNotEmpty ? shop.crNumber : '–'),
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
                  // Row 2: Owner phone + ID number
                  if (shop.ownerPhone.isNotEmpty || shop.idNumber != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (shop.ownerPhone.isNotEmpty)
                          _InfoChip(label: 'جوال المالك', value: shop.ownerPhone),
                        if (shop.idNumber != null) ...[
                          const SizedBox(width: 16),
                          _InfoChip(label: 'رقم الهوية', value: shop.idNumber!),
                        ],
                      ],
                    ),
                  ],
                  // Row 3: Shop phone
                  if (shop.phone.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(children: [_InfoChip(label: 'جوال المتجر', value: shop.phone)]),
                  ],
                  // Documents
                  if (shop.crDocumentUrl != null || shop.idDocumentUrl != null) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Text('الوثائق المرفقة',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white38)),
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (shop.crDocumentUrl != null)
                          _DocBadge(label: 'السجل التجاري', url: shop.crDocumentUrl!),
                        if (shop.crDocumentUrl != null && shop.idDocumentUrl != null)
                          const SizedBox(width: 8),
                        if (shop.idDocumentUrl != null)
                          _DocBadge(label: 'الهوية', url: shop.idDocumentUrl!),
                      ],
                    ),
                  ],
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
                    child: _ActionBtn(label: 'اعتماد', color: AppColors.green, textColor: Colors.white, onTap: onApprove),
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(icon: Icons.close_rounded, bgColor: AppColors.red.withOpacity(.12), iconColor: AppColors.red, onTap: onReject),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white38)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white70)),
    ],
  );
}

class _DocBadge extends StatelessWidget {
  final String label;
  final String url;
  const _DocBadge({required this.label, required this.url});

  void _showDocDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1912),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('وثيقة: $label', textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('رابط الوثيقة:', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Colors.white38)),
            const SizedBox(height: 6),
            SelectableText(url,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, color: AppColors.goldText, height: 1.5)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Colors.white38))),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('تم نسخ الرابط', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
                backgroundColor: AppColors.green,
                duration: Duration(seconds: 2),
              ));
            },
            child: const Text('نسخ الرابط', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.goldText))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _showDocDialog(context),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.goldText.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description_outlined, color: AppColors.goldText, size: 14),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.goldText)),
        ],
      ),
    ),
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
