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

class _ShopDashboardScreenState extends State<ShopDashboardScreen> {
  bool _isOpen = true;
  bool _loading = true;

  String _shopName = '';
  double _rating = 0;
  int _totalJobs = 0;

  List<ShopRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final shopFuture = ApiClient.dio.get('/api/shops/my');
      final requestsFuture = ShopRequestService.getShopRequests();
      final shopRes = await shopFuture;
      final requestsResult = await requestsFuture;
      final shopData = shopRes.data as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _shopName = shopData['name'] as String? ?? '';
          _rating = (shopData['rating'] as num?)?.toDouble() ?? 0.0;
          _totalJobs = shopData['totalJobs'] as int? ?? 0;
          _requests = requestsResult.items;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _newCount =>
      _requests.where((r) => r.shopStatus == ShopRequestShopStatus.pending).length;

  int get _waitingCount =>
      _requests.where((r) =>
          r.shopStatus == ShopRequestShopStatus.accepted &&
          r.status != 'Active').length;

  int get _activeCount =>
      _requests.where((r) => r.status == 'Active').length;

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
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.verified_rounded, color: AppColors.green, size: 13),
                                              const SizedBox(width: 4),
                                              Text(
                                                _isOpen ? 'متجر معتمد · متاح للطلبات' : 'متجر معتمد · مغلق حالياً',
                                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700,
                                                  color: _isOpen ? AppColors.green : Colors.white54)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
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
                                      ),
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
