import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../models/shop_request.dart';
import '../../providers/shop_owner_provider.dart';
import '../../services/shop_request_service.dart';

class ShopDashboardScreen extends StatefulWidget {
  const ShopDashboardScreen({super.key});

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen> {
  bool _isOpen = true;
  List<ShopRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final result = await ShopRequestService.getShopRequests();
      if (mounted) setState(() => _requests = result.items);
    } catch (_) {}
  }

  int get _newCount =>
      _requests.where((r) => r.shopStatus == ShopRequestShopStatus.pending).length;

  int get _waitingCount => _requests.where((r) =>
      r.shopStatus == ShopRequestShopStatus.accepted && r.status == 'Open').length;

  int get _activeCount =>
      _requests.where((r) => r.status == 'ShopSelected' || r.status == 'InProgress').length;

  int get _completedThisMonth {
    final now = DateTime.now();
    return _requests.where((r) =>
        r.status == 'Completed' &&
        r.createdAt.year == now.year &&
        r.createdAt.month == now.month).length;
  }

  List<ShopRequest> get _recentNew =>
      _requests.where((r) => r.shopStatus == ShopRequestShopStatus.pending).take(5).toList();

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopOwnerProvider>();

    if (shopProvider.shop == null && shopProvider.error == null) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator(color: AppColors.goldText)),
      );
    }

    if (shopProvider.shop == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 42),
              const SizedBox(height: 12),
              Text(shopProvider.error ?? 'خطأ في تحميل البيانات',
                  style: const TextStyle(
                      fontFamily: 'Tajawal', fontSize: 13, color: Colors.white54),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.read<ShopOwnerProvider>().load(),
                child: const Text('إعادة المحاولة',
                    style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldText)),
              ),
            ],
          ),
        ),
      );
    }

    final shop = shopProvider.shop!;
    final mono = shop.name.isNotEmpty ? shop.name[0] : 'م';
    final isApproved = shop.status == 'Approved';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          context.read<ShopOwnerProvider>().load(),
          _loadRequests(),
        ]),
        color: AppColors.goldText,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dark header ──
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B1A14), Color(0xFF2E2917)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _LinesPainter())),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row: Toggle (left/end) | Name+Status | Avatar (right/start)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Avatar — right side (RTL start)
                                ShopAvatar(mono: mono, size: 50, fontSize: 19),
                                const SizedBox(width: 12),
                                // Shop name + status
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            shop.name.isNotEmpty ? shop.name : 'متجري',
                                            style: const TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (isApproved) ...[
                                            const SizedBox(width: 5),
                                            const Icon(Icons.verified_rounded,
                                                color: AppColors.goldLight, size: 16),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      _StatusBadge(
                                        status: shop.status,
                                        isOpen: _isOpen,
                                        rejectionReason: shop.rejectionReason,
                                      ),
                                    ],
                                  ),
                                ),
                                // Toggle — left side (RTL end)
                                if (isApproved)
                                  Switch(
                                    value: _isOpen,
                                    onChanged: (v) => setState(() => _isOpen = v),
                                    activeColor: Colors.white,
                                    activeTrackColor: AppColors.green,
                                    inactiveThumbColor: Colors.white54,
                                    inactiveTrackColor: Colors.white24,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  )
                                else
                                  const SizedBox(width: 48),
                              ],
                            ),

                            const SizedBox(height: 26),

                            // Revenue section
                            const Text(
                              'إيراد هذا الشهر (ر.س)',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '0',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.trending_up_rounded,
                                      color: AppColors.green, size: 14),
                                  SizedBox(width: 5),
                                  Text('— عن الشهر الماضي',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.green,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 3 Stat Cards ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    _StatCard(
                      value: shop.rating > 0
                          ? shop.rating.toStringAsFixed(1)
                          : '—',
                      sub: '${shop.totalJobs} عملية',
                      hasStar: shop.rating > 0,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(value: _newCount.toString(), sub: 'طلبات جديدة'),
                    const SizedBox(width: 10),
                    const _StatCard(value: '—', sub: 'متوسط الرد', unit: 'د'),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ── نظرة عامة ──
              const Padding(
                padding: EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: Text('نظرة عامة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    _OverviewCard(
                      value: _newCount.toString(),
                      label: 'طلبات بانتظار رد',
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xFFE91E63),
                      iconBg: const Color(0xFFFCE4EC),
                      isUrgent: _newCount > 0,
                    ),
                    _OverviewCard(
                      value: _waitingCount.toString(),
                      label: 'عروض قيد الانتظار',
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFFF57C00),
                      iconBg: const Color(0xFFFFF3E0),
                    ),
                    _OverviewCard(
                      value: _completedThisMonth.toString(),
                      label: 'مكتملة هذا الشهر',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.green,
                      iconBg: AppColors.greenLight,
                    ),
                    _OverviewCard(
                      value: _activeCount.toString(),
                      label: 'أعمال قيد التنفيذ',
                      icon: Icons.build_rounded,
                      iconColor: const Color(0xFF0288D1),
                      iconBg: const Color(0xFFE3F2FD),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ── أحدث الطلبات ──
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: Row(
                  children: [
                    const Text('أحدث الطلبات',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        )),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('عرض الكل',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.goldText,
                          )),
                    ),
                  ],
                ),
              ),

              if (_recentNew.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, 32),
                  child: Center(
                    child: Text('لا توجد طلبات جديدة',
                        style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            color: AppColors.textSecondary)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: _recentNew.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final r = _recentNew[i];
                    return GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/shop/request-detail',
                                  arguments: r)
                              .then((_) => _loadRequests()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.dark,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              alignment: Alignment.center,
                              child: Text(r.mono,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.goldLight,
                                  )),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.customerName,
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 3),
                                  Text('${r.vehicleInfo} · ${r.location}',
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(r.timeAgo,
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                )),
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

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isOpen;
  final String? rejectionReason;
  const _StatusBadge(
      {required this.status, required this.isOpen, this.rejectionReason});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'Approved':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: isOpen ? AppColors.green : Colors.white38,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              isOpen ? 'متاح للطلبات الآن' : 'مغلق حالياً',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isOpen ? AppColors.green : Colors.white54,
              ),
            ),
          ],
        );
      case 'Rejected':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.cancel_rounded, color: AppColors.red, size: 13),
                SizedBox(width: 4),
                Text('تم رفض طلب التسجيل',
                    style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.red)),
              ],
            ),
            if (rejectionReason != null) ...[
              const SizedBox(height: 3),
              Text(rejectionReason!,
                  style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white38)),
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
                style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFCE93D8))),
          ],
        );
      case 'DocsRequested':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.folder_open_rounded, color: Color(0xFF64B5F6), size: 13),
            SizedBox(width: 4),
            Text('مطلوب منك رفع مستندات',
                style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64B5F6))),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.hourglass_top_rounded,
                color: Color(0xFFFFB74D), size: 13),
            SizedBox(width: 4),
            Text('قيد المراجعة من الإدارة',
                style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFB74D))),
          ],
        );
    }
  }
}

// ── Stat Card (3 cards row) ───────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String sub;
  final bool hasStar;
  final String? unit;
  const _StatCard(
      {required this.value,
      required this.sub,
      this.hasStar = false,
      this.unit});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      )),
                  if (hasStar) ...[
                    const SizedBox(width: 2),
                    const Icon(Icons.star_rounded,
                        color: AppColors.star, size: 16),
                  ] else if (unit != null) ...[
                    const SizedBox(width: 2),
                    Text(unit!,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        )),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(sub,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}

// ── Overview Card (2×2 grid) ──────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isUrgent;
  const _OverviewCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: number + urgent badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(value,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.0,
                      )),
                ),
                if (isUrgent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.redLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('عاجل',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.red,
                        )),
                  ),
              ],
            ),
            // Bottom: label + icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 34,
                  height: 34,
                  decoration:
                      BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
              ],
            ),
          ],
        ),
      );
}

// ── Background painter ────────────────────────────────────────────────────────

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
      canvas.drawLine(
          Offset(x, 0),
          Offset(x + size.height * math.tan(math.pi / 4), size.height),
          paint);
    }
  }

  @override
  bool shouldRepaint(_LinesPainter old) => false;
}
