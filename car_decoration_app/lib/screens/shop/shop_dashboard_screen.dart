import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../models/shop_request.dart';
import '../../services/shop_request_service.dart';
import '../../services/api_client.dart';

class ShopDashboardScreen extends StatefulWidget {
  const ShopDashboardScreen({super.key});

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen> with WidgetsBindingObserver {
  bool _isOpen = true;
  bool _loading = true;
  String? _loadError;

  String _shopName = '';
  String _shopStatus = 'Pending';
  String? _rejectionReason;
  double _rating = 0;
  int _totalJobs = 0;

  List<ShopRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _loadError = null; });
    try {
      final shopRes = await ApiClient.dio.get('/api/shops/my');
      final shopData = shopRes.data as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _shopName = shopData['name'] as String? ?? '';
        _shopStatus = shopData['status'] as String? ?? 'Pending';
        _rejectionReason = shopData['rejectionReason'] as String?;
        _rating = (shopData['rating'] as num?)?.toDouble() ?? 0.0;
        _totalJobs = shopData['totalJobs'] as int? ?? 0;
        _loading = false;
      });
      // Requests are only available for approved shops — failure is silently ignored
      try {
        final requestsResult = await ShopRequestService.getShopRequests();
        if (mounted) setState(() => _requests = requestsResult.items);
      } catch (_) {}
    } catch (e) {
      if (mounted) setState(() { _loading = false; _loadError = ApiClient.extractError(e); });
    }
  }

  int get _newCount =>
      _requests.where((r) => r.shopStatus == ShopRequestShopStatus.pending).length;

  int get _waitingCount =>
      _requests.where((r) =>
          r.shopStatus == ShopRequestShopStatus.accepted &&
          r.status == 'Open').length;

  int get _activeCount =>
      _requests.where((r) =>
          r.status == 'ShopSelected' || r.status == 'InProgress').length;

  int get _completedThisMonth {
    final now = DateTime.now();
    return _requests.where((r) =>
        r.status == 'Completed' &&
        r.createdAt.year == now.year &&
        r.createdAt.month == now.month).length;
  }

  List<ShopRequest> get _recentNew =>
      _requests.where((r) => r.shopStatus == ShopRequestShopStatus.pending).take(5).toList();

  String get _mono => _shopName.isNotEmpty ? _shopName[0] : 'م';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldText))
          : _loadError != null
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 42),
                    const SizedBox(height: 12),
                    Text(_loadError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Colors.white54), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextButton(onPressed: _load, child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.goldText))),
                  ],
                ))
              : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.goldText,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Dark header ──
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(child: CustomPaint(painter: _LinesPainter())),
                          SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ShopAvatar(mono: _mono, size: 52, fontSize: 20),
                                      const Spacer(),
                                      Column(
                                        children: [
                                          Text(_shopName.isNotEmpty ? _shopName : 'متجري',
                                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                                          const SizedBox(height: 4),
                                          _StatusBadge(status: _shopStatus, isOpen: _isOpen, rejectionReason: _rejectionReason),
                                        ],
                                      ),
                                      const Spacer(),
                                      if (_shopStatus == 'Approved')
                                        Transform.scale(
                                          scale: 0.85,
                                          child: Switch(
                                            value: _isOpen,
                                            onChanged: (v) => setState(() => _isOpen = v),
                                            activeColor: Colors.white,
                                            activeTrackColor: AppColors.green,
                                            inactiveThumbColor: Colors.white54,
                                            inactiveTrackColor: Colors.white24,
                                          ),
                                        )
                                      else
                                        const SizedBox(width: 52),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      _HeaderStat(
                                        value: _rating > 0 ? _rating.toStringAsFixed(1) : '—',
                                        sub: '$_totalJobs عملية',
                                        hasStar: true,
                                      ),
                                      _HeaderStat(value: _newCount.toString(), sub: 'طلبات جديدة'),
                                      _HeaderStat(value: _activeCount.toString(), sub: 'قيد التنفيذ'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── نظرة عامة ──
                    const Padding(
                      padding: EdgeInsets.fromLTRB(22, 0, 22, 12),
                      child: Text('نظرة عامة',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.65,
                        children: [
                          _OverviewCard(value: _newCount.toString(), label: 'طلبات بانتظار رد', hasRedDot: _newCount > 0),
                          _OverviewCard(value: _waitingCount.toString(), label: 'عروض قيد الانتظار'),
                          _OverviewCard(value: _activeCount.toString(), label: 'أعمال قيد التنفيذ'),
                          _OverviewCard(value: _completedThisMonth.toString(), label: 'مكتملة هذا الشهر'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── أحدث الطلبات ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                      child: Row(
                        children: [
                          const Text('أحدث الطلبات',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: const Text('عرض الكل',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                          ),
                        ],
                      ),
                    ),

                    if (_recentNew.isEmpty)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(22, 0, 22, 32),
                        child: Center(
                          child: Text('لا توجد طلبات جديدة',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textSecondary)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                        itemCount: _recentNew.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final r = _recentNew[i];
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/shop/request-detail', arguments: r),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(13)),
                                    alignment: Alignment.center,
                                    child: Text(r.mono,
                                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.customerName,
                                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                          maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 3),
                                        Text('${r.vehicleInfo} · ${r.location}',
                                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(r.timeAgo,
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isOpen;
  final String? rejectionReason;
  const _StatusBadge({required this.status, required this.isOpen, this.rejectionReason});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'Approved':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.green, size: 13),
            const SizedBox(width: 4),
            Text(
              isOpen ? 'متجر معتمد · متاح للطلبات' : 'متجر معتمد · مغلق حالياً',
              style: TextStyle(
                fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700,
                color: isOpen ? AppColors.green : Colors.white54),
            ),
          ],
        );
      case 'Rejected':
        return Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.cancel_rounded, color: AppColors.red, size: 13),
                SizedBox(width: 4),
                Text('تم رفض طلب التسجيل',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.red)),
              ],
            ),
            if (rejectionReason != null) ...[
              const SizedBox(height: 3),
              Text(rejectionReason!,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white38),
                textAlign: TextAlign.center),
            ],
          ],
        );
      case 'Suspended':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.block_rounded, color: Color(0xFFCE93D8), size: 13),
            SizedBox(width: 4),
            Text('المتجر موقوف من الإدارة',
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFCE93D8))),
          ],
        );
      case 'DocsRequested':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.folder_open_rounded, color: Color(0xFF64B5F6), size: 13),
            SizedBox(width: 4),
            Text('مطلوب منك رفع مستندات',
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF64B5F6))),
          ],
        );
      default: // Pending
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.hourglass_top_rounded, color: Color(0xFFFFB74D), size: 13),
            SizedBox(width: 4),
            Text('قيد المراجعة من الإدارة',
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFFFB74D))),
          ],
        );
    }
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String sub;
  final bool hasStar;
  const _HeaderStat({required this.value, required this.sub, this.hasStar = false});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(value,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              if (hasStar) ...[
                const SizedBox(width: 3),
                const Icon(Icons.star_rounded, color: AppColors.star, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(sub,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white54)),
        ],
      ),
    ),
  );
}

class _OverviewCard extends StatelessWidget {
  final String value;
  final String label;
  final bool hasRedDot;
  const _OverviewCard({required this.value, required this.label, this.hasRedDot = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (hasRedDot) ...[
              const SizedBox(width: 6),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle)),
            ],
          ],
        ),
        Text(value,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
      ],
    ),
  );
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4B96A).withOpacity(0.09)
      ..strokeWidth = 1.0;
    const spacing = 22.0;
    final count = (size.width + size.height) ~/ spacing + 2;
    for (int i = 0; i < count; i++) {
      final x = i * spacing - size.height;
      canvas.drawLine(Offset(x, 0), Offset(x + size.height * math.tan(math.pi / 4), size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_LinesPainter old) => false;
}
