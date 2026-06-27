import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme.dart';
import '../../models/pending_shop.dart';
import '../../services/shop_admin_service.dart';
import '../../services/api_client.dart';

class AdminPendingScreen extends StatefulWidget {
  const AdminPendingScreen({super.key});

  @override
  State<AdminPendingScreen> createState() => _AdminPendingScreenState();
}

class _AdminPendingScreenState extends State<AdminPendingScreen> {
  List<PendingShop> _all = [];
  bool _loading = true;
  String? _error;
  String _filterStatus = 'all';
  String _search = '';
  final _searchCtrl = TextEditingController();

  static const _tabs = [
    ('all', 'الكل'),
    ('Pending', 'بانتظار'),
    ('Approved', 'معتمد'),
    ('Rejected', 'مرفوض'),
    ('Suspended', 'موقوف'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final shops = await ShopAdminService.getAllShops(
        status: _filterStatus == 'all' ? null : _filterStatus,
        search: _search.isEmpty ? null : _search,
      );
      if (mounted) setState(() { _all = shops; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = ApiClient.extractError(e); _loading = false; });
    }
  }

  Future<void> _approve(PendingShop shop) async {
    try {
      await ShopAdminService.approveShop(shop.id);
      if (mounted) setState(() => shop.status = AdminShopStatus.approved);
    } catch (e) {
      _snack(ApiClient.extractError(e), isError: true);
    }
  }

  Future<void> _suspend(PendingShop shop) async {
    try {
      await ShopAdminService.suspendShop(shop.id);
      if (mounted) setState(() => shop.status = AdminShopStatus.suspended);
    } catch (e) {
      _snack(ApiClient.extractError(e), isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
      backgroundColor: isError ? AppColors.red : AppColors.green,
    ));
  }

  void _showRejectDialog(PendingShop shop) {
    String selectedReason = '';
    final customCtrl = TextEditingController();
    final predefined = [
      'السجل التجاري غير واضح',
      'الهوية غير واضحة',
      'بيانات غير صحيحة',
      'مستندات ناقصة',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1912),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(99)))),
                const SizedBox(height: 18),
                const Text('سبب الرفض', textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 4),
                Text('رفض طلب: ${shop.name}',
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: predefined.map((r) {
                    final sel = selectedReason == r;
                    return GestureDetector(
                      onTap: () => setSheet(() {
                        selectedReason = sel ? '' : r;
                        if (!sel) customCtrl.clear();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.red.withOpacity(.18) : Colors.white.withOpacity(.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: sel ? AppColors.red.withOpacity(.5) : Colors.white12),
                        ),
                        child: Text(r,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700,
                            color: sel ? AppColors.red : Colors.white60)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: customCtrl,
                  onChanged: (v) => setSheet(() => selectedReason = v.isNotEmpty ? v : selectedReason),
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.white),
                  maxLines: 2,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'أو اكتب سبباً مخصصاً...',
                    hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withOpacity(.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                    onPressed: () async {
                      final reason = customCtrl.text.trim().isNotEmpty
                          ? customCtrl.text.trim()
                          : selectedReason;
                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('يرجى اختيار أو كتابة سبب الرفض',
                            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
                          backgroundColor: AppColors.red,
                        ));
                        return;
                      }
                      Navigator.pop(ctx);
                      try {
                        await ShopAdminService.rejectShop(shop.id, reason);
                        if (mounted) setState(() => shop.status = AdminShopStatus.rejected);
                        _snack('تم رفض المتجر');
                      } catch (e) {
                        _snack(ApiClient.extractError(e), isError: true);
                      }
                    },
                    child: const Text('تأكيد الرفض',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showApproveConfirm(PendingShop shop) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1912),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('اعتماد المتجر', textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        content: Text('هل تريد اعتماد ${shop.name}؟\nسيتمكن المتجر من استقبال الطلبات فوراً.',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Colors.white38))),
          TextButton(
            onPressed: () { Navigator.pop(context); _approve(shop); },
            child: const Text('اعتماد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.green))),
        ],
      ),
    );
  }

  void _showSuspendConfirm(PendingShop shop) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1912),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('إيقاف المتجر', textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        content: Text('هل تريد إيقاف ${shop.name}؟\nلن يستطيع استقبال طلبات جديدة.',
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Colors.white38))),
          TextButton(
            onPressed: () { Navigator.pop(context); _suspend(shop); },
            child: const Text('إيقاف', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Color(0xFF9C27B0)))),
        ],
      ),
    );
  }

  int _countFor(String status) {
    if (status == 'all') return _all.length;
    final map = {
      'Pending': AdminShopStatus.pending,
      'Approved': AdminShopStatus.approved,
      'Rejected': AdminShopStatus.rejected,
      'Suspended': AdminShopStatus.suspended,
    };
    return _all.where((s) => s.status == map[status]).length;
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _all.where((s) => s.status == AdminShopStatus.pending).length;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إدارة المتاجر',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(pendingCount > 0 ? '$pendingCount بانتظار المراجعة' : 'جميع المتاجر',
                        style: TextStyle(
                          fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600,
                          color: pendingCount > 0 ? const Color(0xFFFF9800) : Colors.white38)),
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

            // ── Search ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) {
                  _search = v;
                  _load();
                },
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.white),
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'بحث بالاسم أو المالك أو السجل التجاري...',
                  hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, color: Colors.white30),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white30, size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? GestureDetector(
                          onTap: () { _searchCtrl.clear(); setState(() => _search = ''); _load(); },
                          child: const Icon(Icons.close_rounded, color: Colors.white30, size: 18))
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(.07),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),

            // ── Filter tabs ──
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final (key, label) = _tabs[i];
                  final active = _filterStatus == key;
                  final count = _loading ? null : _countFor(key);
                  return GestureDetector(
                    onTap: () { setState(() => _filterStatus = key); _load(); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? AppColors.goldText.withOpacity(.18) : Colors.white.withOpacity(.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: active ? AppColors.goldText.withOpacity(.5) : Colors.transparent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label,
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800,
                              color: active ? AppColors.goldText : Colors.white38)),
                          if (count != null && count > 0) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: active ? AppColors.goldText.withOpacity(.25) : Colors.white12,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text('$count',
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w900,
                                  color: active ? AppColors.goldText : Colors.white38)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

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
                              child: const Text('إعادة المحاولة',
                                style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.goldText))),
                          ],
                        ))
                      : _all.isEmpty
                          ? const Center(child: Text('لا توجد متاجر',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: Colors.white38)))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: _all.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) => _ShopCard(
                                shop: _all[i],
                                onApprove: () => _showApproveConfirm(_all[i]),
                                onReject: () => _showRejectDialog(_all[i]),
                                onSuspend: () => _showSuspendConfirm(_all[i]),
                              ),
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
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  const _ShopCard({required this.shop, required this.onApprove, required this.onReject, required this.onSuspend});

  @override
  Widget build(BuildContext context) {
    final statusColor = shop.status.color;
    final statusLabel = shop.status.label;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1912),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // ── Header row ──
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(statusLabel,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w800, color: statusColor)),
                    ),
                    const SizedBox(height: 4),
                    Text(shop.submittedAt,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white30)),
                  ],
                ),
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
                  Row(
                    children: [
                      _InfoChip(label: 'السجل التجاري', value: shop.crNumber.isNotEmpty ? shop.crNumber : '–'),
                      if (shop.idNumber != null) ...[
                        const SizedBox(width: 20),
                        _InfoChip(label: 'رقم الهوية', value: shop.idNumber!),
                      ],
                    ],
                  ),
                  if (shop.ownerPhone.isNotEmpty || shop.phone.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (shop.ownerPhone.isNotEmpty)
                          _InfoChip(label: 'جوال المالك', value: shop.ownerPhone),
                        if (shop.phone.isNotEmpty) ...[
                          const SizedBox(width: 20),
                          _InfoChip(label: 'جوال المتجر', value: shop.phone),
                        ],
                      ],
                    ),
                  ],
                  // rejection reason
                  if (shop.status == AdminShopStatus.rejected && shop.rejectionReason != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.red.withOpacity(.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.red, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('سبب الرفض: ${shop.rejectionReason}',
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.red)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Documents
                  if (shop.crDocumentUrl != null || shop.idDocumentUrl != null) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 10),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: const Text('الوثائق المرفقة',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white38)),
                    ),
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

          // ── Action buttons ──
          _ActionBar(shop: shop, onApprove: onApprove, onReject: onReject, onSuspend: onSuspend),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final PendingShop shop;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  const _ActionBar({required this.shop, required this.onApprove, required this.onReject, required this.onSuspend});

  @override
  Widget build(BuildContext context) {
    switch (shop.status) {
      case AdminShopStatus.pending:
      case AdminShopStatus.docsRequested:
        return _actionsRow([
          Expanded(flex: 3, child: _ActionBtn(label: 'اعتماد', color: AppColors.green, onTap: onApprove)),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.close_rounded, bgColor: AppColors.red.withOpacity(.12), iconColor: AppColors.red, onTap: onReject),
        ]);
      case AdminShopStatus.approved:
        return _actionsRow([
          Expanded(child: _ActionBtn(label: 'إيقاف المتجر', color: const Color(0xFF9C27B0), onTap: onSuspend)),
        ]);
      case AdminShopStatus.rejected:
        return _actionsRow([
          Expanded(child: _ActionBtn(label: 'إعادة الاعتماد', color: AppColors.green, onTap: onApprove)),
        ]);
      case AdminShopStatus.suspended:
        return _actionsRow([
          Expanded(child: _ActionBtn(label: 'رفع الإيقاف', color: AppColors.green, onTap: onApprove)),
        ]);
    }
  }

  Widget _actionsRow(List<Widget> children) => Column(
    children: [
      Container(height: 1, color: Colors.white10),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: children),
      ),
    ],
  );
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

  void _show(BuildContext context) {
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
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Colors.white38))),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('تم نسخ الرابط', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
                backgroundColor: AppColors.green, duration: Duration(seconds: 2),
              ));
            },
            child: const Text('نسخ الرابط', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.goldText))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _show(context),
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
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 42,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
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
