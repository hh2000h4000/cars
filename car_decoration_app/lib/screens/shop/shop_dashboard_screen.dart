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

  int get _waitingCount => _requests
      .where((r) =>
          r.shopStatus == ShopRequestShopStatus.accepted && r.status == 'Open')
      .length;

  int get _activeCount => _requests
      .where((r) => r.status == 'ShopSelected' || r.status == 'InProgress')
      .length;

  int get _completedThisMonth {
    final now = DateTime.now();
    return _requests
        .where((r) =>
            r.status == 'Completed' &&
            r.createdAt.year == now.year &&
            r.createdAt.month == now.month)
        .length;
  }

  List<ShopRequest> get _recentRequests => _requests.take(5).toList();

  ({String label, Color bg, Color textColor}) _chipFor(ShopRequest r) {
    if (r.shopStatus == ShopRequestShopStatus.pending) {
      return (
        label: 'جديد',
        bg: const Color(0xFFE3F2FD),
        textColor: const Color(0xFF1565C0),
      );
    }
    switch (r.status) {
      case 'Completed':
        return (label: 'مكتمل', bg: AppColors.greenLight, textColor: AppColors.green);
      case 'InProgress':
      case 'ShopSelected':
        return (label: 'جارٍ', bg: const Color(0xFFFFF8E1), textColor: const Color(0xFFF57C00));
      case 'Cancelled':
        return (label: 'ملغى', bg: AppColors.redLight, textColor: AppColors.red);
      default:
        return (label: 'مفتوح', bg: AppColors.goldBg, textColor: AppColors.goldText);
    }
  }

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Dark olive header ──────────────────────────────────────────
              Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C3320), Color(0xFF4A5530)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Top row: Toggle | Name+Status | Avatar ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Toggle (RIGHT in RTL — first child)
                            if (isApproved)
                              Switch(
                                value: _isOpen,
                                onChanged: (v) => setState(() => _isOpen = v),
                                activeColor: Colors.white,
                                activeTrackColor: AppColors.green,
                                inactiveThumbColor: Colors.white54,
                                inactiveTrackColor: Colors.white24,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )
                            else
                              const SizedBox(width: 48),

                            // Name + status (centered, Expanded)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: AppColors.goldLight,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_rounded,
                                            size: 10, color: Color(0xFF2C3320)),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          shop.name.isNotEmpty ? shop.name : 'متجري',
                                          style: const TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  _StatusBadge(
                                    status: shop.status,
                                    isOpen: _isOpen,
                                    rejectionReason: shop.rejectionReason,
                                  ),
                                ],
                              ),
                            ),

                            // Avatar (LEFT in RTL — last child)
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(mono,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2C3320),
                                  )),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── Revenue: centered ──
                        const Text(
                          'إيراد هذا الشهر (ر.س)',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '0',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('↗',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF4ADE80))),
                              SizedBox(width: 4),
                              Text('— عن الشهر الماضي',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4ADE80),
                                  )),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Full-width chart ──
                        SizedBox(
                          height: 56,
                          width: double.infinity,
                          child: CustomPaint(painter: _ChartPainter()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 3 Stat Cards ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    // Rating (RIGHT in RTL — first)
                    _StatCard(
                      value: shop.rating > 0
                          ? shop.rating.toStringAsFixed(1)
                          : '—',
                      label: '${shop.totalJobs} عملية',
                      hasStar: shop.rating > 0,
                    ),
                    const SizedBox(width: 10),
                    // طلبات جديدة (middle)
                    _StatCard(value: _newCount.toString(), label: 'طلبات جديدة'),
                    const SizedBox(width: 10),
                    // متوسط الرد (LEFT in RTL — last)
                    const _StatCard(value: '—', label: 'متوسط الرد', unit: 'د'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── نظرة عامة ─────────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text('نظرة عامة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.2,
                  children: [
                    // 1st → RIGHT in RTL
                    _OverviewCard(
                      value: _waitingCount.toString(),
                      label: 'عروض قيد الانتظار',
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFFF57C00),
                      iconBg: const Color(0xFFFFF3E0),
                    ),
                    // 2nd → LEFT in RTL
                    _OverviewCard(
                      value: _newCount.toString(),
                      label: 'طلبات بانتظار رد',
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: const Color(0xFFE91E63),
                      iconBg: const Color(0xFFFCE4EC),
                      isUrgent: _newCount > 0,
                    ),
                    // 3rd → RIGHT in RTL
                    _OverviewCard(
                      value: _completedThisMonth.toString(),
                      label: 'مكتملة هذا الشهر',
                      icon: Icons.task_alt_rounded,
                      iconColor: AppColors.green,
                      iconBg: AppColors.greenLight,
                    ),
                    // 4th → LEFT in RTL
                    _OverviewCard(
                      value: _activeCount.toString(),
                      label: 'أعمال قيد التنفيذ',
                      icon: Icons.build_outlined,
                      iconColor: const Color(0xFF0288D1),
                      iconBg: const Color(0xFFE3F2FD),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── أحدث الطلبات ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('عرض الكل',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.goldText,
                              )),
                          SizedBox(width: 2),
                          Icon(Icons.chevron_left_rounded,
                              color: AppColors.goldText, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_recentRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, 32),
                  child: Center(
                    child: Text('لا توجد طلبات',
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
                  itemCount: _recentRequests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final r = _recentRequests[i];
                    final chip = _chipFor(r);
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(
                              context, '/shop/request-detail',
                              arguments: r)
                          .then((_) => _loadRequests()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Status chip (RIGHT in RTL — first)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: chip.bg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(chip.label,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: chip.textColor,
                                  )),
                            ),
                            const SizedBox(width: 10),
                            // Name + service (center)
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start, // RTL = RIGHT
                                children: [
                                  Text(
                                    r.description.isNotEmpty
                                        ? r.description
                                        : r.customerName,
                                    style: const TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(r.vehicleInfo,
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Avatar (LEFT in RTL — last)
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(r.mono,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF2C3320),
                                  )),
                            ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isOpen ? 'متاح للطلبات الآن' : 'مغلق حالياً',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isOpen ? const Color(0xFF4ADE80) : Colors.white54,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: isOpen ? const Color(0xFF4ADE80) : Colors.white38,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      case 'Rejected':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      color: Colors.white38),
                  textAlign: TextAlign.center),
            ],
          ],
        );
      case 'Suspended':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.folder_open_rounded,
                color: Color(0xFF64B5F6), size: 13),
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
          mainAxisAlignment: MainAxisAlignment.center,
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

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool hasStar;
  final String? unit;
  const _StatCard(
      {required this.value,
      required this.label,
      this.hasStar = false,
      this.unit});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
                        color: AppColors.star, size: 15),
                  ] else if (unit != null) ...[
                    const SizedBox(width: 2),
                    Text(unit!,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        )),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(label,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
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

// ── Overview Card ─────────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) => Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon at top (LEFT-aligned in RTL via CrossAxisAlignment.end)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(height: 10),
                // Number centered
                Align(
                  alignment: Alignment.center,
                  child: Text(value,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      )),
                ),
                const SizedBox(height: 3),
                // Label centered
                Align(
                  alignment: Alignment.center,
                  child: Text(label,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2),
                ),
              ],
            ),
          ),
          // Urgent badge: top-right corner (RTL start)
          if (isUrgent)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('عاجل',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
              ),
            ),
        ],
      );
}

// ── Full-width line chart ─────────────────────────────────────────────────────

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFC9A84C)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final points = [
      Offset(0, size.height * 0.85),
      Offset(size.width * 0.15, size.height * 0.65),
      Offset(size.width * 0.32, size.height * 0.72),
      Offset(size.width * 0.50, size.height * 0.42),
      Offset(size.width * 0.68, size.height * 0.28),
      Offset(size.width * 0.84, size.height * 0.16),
      Offset(size.width, size.height * 0.06),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final cpx = (points[i - 1].dx + points[i].dx) / 2;
      path.cubicTo(
          cpx, points[i - 1].dy, cpx, points[i].dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = const Color(0xFFC9A84C)
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => false;
}
