import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/shop_request.dart';
import '../../services/shop_request_service.dart';

class ShopRequestsScreen extends StatefulWidget {
  const ShopRequestsScreen({super.key});

  @override
  State<ShopRequestsScreen> createState() => _ShopRequestsScreenState();
}

class _ShopRequestsScreenState extends State<ShopRequestsScreen> {
  List<ShopRequest> _all = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  String? _error;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ShopRequestService.getShopRequests(page: 1);
      if (mounted) setState(() { _all = result.items; _page = 1; _hasMore = result.hasNextPage; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'تعذر تحميل الطلبات'; _loading = false; });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore) return;
    setState(() { _loadingMore = true; });
    try {
      final result = await ShopRequestService.getShopRequests(page: _page + 1);
      if (mounted) setState(() {
        _all = [..._all, ...result.items];
        _page++;
        _hasMore = result.hasNextPage;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() { _loadingMore = false; });
    }
  }

  List<ShopRequest> get _new =>
      _all.where((r) => r.shopStatus == ShopRequestShopStatus.pending).toList();

  List<ShopRequest> get _waiting =>
      _all.where((r) =>
          r.shopStatus == ShopRequestShopStatus.accepted &&
          r.status == 'Open').toList();

  List<ShopRequest> get _active =>
      _all.where((r) =>
          (r.status == 'ShopSelected' && r.quotationStatus == 'Accepted') ||
          r.status == 'InProgress').toList();

  List<ShopRequest> get _completed =>
      _all.where((r) => r.status == 'Completed').toList();

  @override
  Widget build(BuildContext context) {
    final newCount = _new.length;
    final waitingCount = _waiting.length;
    final activeCount = _active.length;
    final completedCount = _completed.length;

    final tabs = [
      'الكل (${_all.length})',
      'جديدة ($newCount)',
      'بانتظار العميل ($waitingCount)',
      'قيد التنفيذ ($activeCount)',
      'مكتمل ($completedCount)',
    ];

    final currentList = switch (_tab) {
      0 => _all,
      1 => _new,
      2 => _waiting,
      3 => _active,
      4 => _completed,
      _ => _all,
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: Row(
                children: [
                  Text('الطلبات الواردة',
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _load,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.goldText))
                  : _error != null
                      ? _ErrorState(message: _error!, onRetry: _load)
                      : currentList.isEmpty
                          ? const _EmptyTab()
                          : RefreshIndicator(
                              onRefresh: _load,
                              color: AppColors.goldText,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                                itemCount: currentList.length + (_hasMore ? 1 : 0),
                                itemBuilder: (_, i) {
                                  if (i == currentList.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: _LoadMoreButton(loading: _loadingMore, onTap: _loadMore),
                                    );
                                  }
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: i < currentList.length - 1 || _hasMore ? 12 : 0),
                                    child: _RequestCard(request: currentList[i]),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Load more button ─────────────────────────────────────────────────────────
class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _LoadMoreButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText))
          : const Text('تحميل المزيد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
    ),
  );
}

// ── Request card ──────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final ShopRequest request;
  const _RequestCard({required this.request});

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
              Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center,
                    child: Text(request.mono,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.customerName,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('${request.location} · ${request.timeAgo}',
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  _StatusBadge(request.shopStatus, requestStatus: request.status, quotationStatus: request.quotationStatus),
                ],
              ),
              const SizedBox(height: 10),
              Text(request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.directions_car_outlined, color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(request.vehicleInfo,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/shop/request-detail', arguments: request)
                      .then((_) => _load()),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('عرض التفاصيل',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ),
                ),
              ),
              if (request.chatRoomId != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: request.chatRoomId),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text('فتح المحادثة',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final ShopRequestShopStatus status;
  final String? requestStatus;
  final String? quotationStatus;
  const _StatusBadge(this.status, {this.requestStatus, this.quotationStatus});

  @override
  Widget build(BuildContext context) {
    final isChosenShop   = requestStatus == 'ShopSelected' && quotationStatus == 'Accepted';
    final isRejectedShop = requestStatus == 'ShopSelected' && !isChosenShop;

    final (label, bg, fg) = isRejectedShop
        ? ('محجوز لمتجر آخر', const Color(0xFFFFEBEE), AppColors.red)
        : isChosenShop
            ? ('تم اختياري', const Color(0xFFE8F5E9), AppColors.green)
            : switch (requestStatus) {
                'Completed' => ('مكتمل', const Color(0xFFE8F5E9), AppColors.green),
                'InProgress' => ('قيد التنفيذ', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
                'ShopSelected' => ('تم الاختيار', const Color(0xFFF3E5F5), const Color(0xFF6A1B9A)),
                'Cancelled' => ('ملغي', const Color(0xFFFFEBEE), AppColors.red),
                _ => switch (status) {
                  ShopRequestShopStatus.pending => ('جديد', AppColors.goldBg, AppColors.goldText),
                  ShopRequestShopStatus.accepted => ('مقبول', const Color(0xFFE8F5E9), AppColors.green),
                  ShopRequestShopStatus.rejected => ('مرفوض', const Color(0xFFFFEBEE), AppColors.red),
                  ShopRequestShopStatus.withdrawn => ('مسحوب', AppColors.surface, AppColors.textMuted),
                },
              };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg.withOpacity(.3)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
        style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab();

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
        const Text('لا توجد طلبات',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('ستظهر هنا الطلبات عند وصولها',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onRetry,
          child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.goldText)),
        ),
      ],
    ),
  );
}
