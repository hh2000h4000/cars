import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../models/shop_request.dart';
import '../../models/quotation.dart';
import '../../services/shop_request_service.dart';
import '../../services/quotation_service.dart';
import 'send_quote_screen.dart';

class ShopRequestDetailScreen extends StatefulWidget {
  final ShopRequest request;
  const ShopRequestDetailScreen({super.key, required this.request});

  @override
  State<ShopRequestDetailScreen> createState() => _ShopRequestDetailScreenState();
}

class _ShopRequestDetailScreenState extends State<ShopRequestDetailScreen> {
  bool _accepting = false;
  bool _starting = false;
  bool _completing = false;
  late ShopRequestShopStatus _shopStatus;
  late String _requestStatus;
  String? _chatRoomId;
  Quotation? _myQuotation;

  @override
  void initState() {
    super.initState();
    _shopStatus = widget.request.shopStatus;
    _requestStatus = widget.request.status;
    _chatRoomId = widget.request.chatRoomId;
    _loadMyQuotation();
  }

  Future<void> _loadMyQuotation() async {
    final q = await QuotationService.getMyQuotation(widget.request.id);
    if (mounted) setState(() => _myQuotation = q);
  }

  Future<void> _openQuoteScreen() async {
    final result = await Navigator.push<Quotation>(
      context,
      MaterialPageRoute(
        builder: (_) => SendQuoteScreen(
          request: widget.request,
          existingQuotation: _myQuotation?.status == QuotationStatus.pending ? _myQuotation : null,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _myQuotation = result);
    } else if (result == null && _myQuotation == null && mounted) {
      _loadMyQuotation();
    }
  }

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      final chatId = await ShopRequestService.acceptRequest(widget.request.id);
      if (mounted) {
        setState(() {
          _shopStatus = ShopRequestShopStatus.accepted;
          _chatRoomId = chatId;
          _accepting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم قبول الطلب وفتح المحادثة بنجاح',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _accepting = false);
        _showError(e.toString());
      }
    }
  }

  Future<void> _startWork() async {
    setState(() => _starting = true);
    try {
      await ShopRequestService.startWork(widget.request.id);
      if (mounted) {
        setState(() { _requestStatus = 'InProgress'; _starting = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم تسجيل بدء العمل بنجاح',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.green,
        ));
      }
    } catch (e) {
      if (mounted) { setState(() => _starting = false); _showError(e.toString()); }
    }
  }

  Future<void> _complete() async {
    setState(() => _completing = true);
    try {
      await ShopRequestService.completeRequest(widget.request.id);
      if (mounted) {
        setState(() { _requestStatus = 'Completed'; _completing = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم إنهاء الطلب — سيتلقى العميل إشعاراً للتقييم',
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.green,
        ));
      }
    } catch (e) {
      if (mounted) { setState(() => _completing = false); _showError(e.toString()); }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg.replaceAll('Exception: ', ''),
        style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
      backgroundColor: AppColors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final isPending      = _shopStatus == ShopRequestShopStatus.pending;
    final isRejected     = _shopStatus == ShopRequestShopStatus.rejected;
    final isShopSelected = _requestStatus == 'ShopSelected';
    final isInProgress   = _requestStatus == 'InProgress';
    final isCompleted    = _requestStatus == 'Completed';
    final isCancelled    = _requestStatus == 'Cancelled' || _requestStatus == 'Expired';
    // هل اختار العميل هذا المتجر تحديداً؟
    final isChosenShop       = isShopSelected && _myQuotation?.status == QuotationStatus.accepted;
    final isRejectedByCustomer = isShopSelected && _myQuotation != null && _myQuotation!.status == QuotationStatus.rejected;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('طلب وارد',
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('${r.timeAgo} · ${r.location}',
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  // Status badge
                  _StatusBadge(requestStatus: _requestStatus, shopStatus: _shopStatus, isRejectedByCustomer: isRejectedByCustomer),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Customer card ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(14)),
                            alignment: Alignment.center,
                            child: Text(r.mono,
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.customerName,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const Text('عميل',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          if (_chatRoomId != null)
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: _chatRoomId),
                              child: Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(13)),
                                child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Service description ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.goldBg,
                        border: Border.all(color: AppColors.goldLight),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الخدمة المطلوبة',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                          const SizedBox(height: 8),
                          Text(r.description, textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.6)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Vehicle + Date ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('المركبة',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                const SizedBox(height: 5),
                                Text(r.vehicleInfo,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 36, color: AppColors.border),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('الموعد المفضّل',
                                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                  const SizedBox(height: 5),
                                  Text(r.appointmentLabel,
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Location ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.goldText, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(r.location,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                        ],
                      ),
                    ),

                    // ── Cancelled/Expired banner ──
                    if (isCancelled) ...[
                      const SizedBox(height: 16),
                      _InfoBanner(
                        icon: Icons.cancel_outlined,
                        message: _requestStatus == 'Expired' ? 'انتهت صلاحية هذا الطلب' : 'تم إلغاء هذا الطلب من قِبل العميل',
                        color: AppColors.red,
                      ),
                    ],

                    // ── Rejected — customer chose another shop ──
                    if (isRejected || isRejectedByCustomer) ...[
                      const SizedBox(height: 16),
                      _InfoBanner(
                        icon: Icons.do_not_disturb_on_outlined,
                        message: 'اختار العميل متجراً آخر — تم رفض عرضك',
                        color: AppColors.red,
                      ),
                    ],

                    // ── ShopSelected banner — only for the chosen shop ──
                    if (isChosenShop && _chatRoomId != null) ...[
                      const SizedBox(height: 16),
                      _InfoBanner(
                        icon: Icons.check_circle_outline_rounded,
                        message: 'تم قبول عرضك — اضغط "بدأ العمل" عند الوصول للعميل',
                        color: AppColors.green,
                      ),
                    ],

                    // ── Completed banner ──
                    if (isCompleted) ...[
                      const SizedBox(height: 16),
                      _InfoBanner(
                        icon: Icons.check_circle_rounded,
                        message: 'تم إنهاء الطلب بنجاح',
                        color: AppColors.green,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom buttons ──
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).padding.bottom + 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: _buildBottomAction(isPending, isRejected, isChosenShop, isRejectedByCustomer, isInProgress, isCompleted, isCancelled),
      ),
    );
  }

  Widget _buildBottomAction(
    bool isPending, bool isRejected,
    bool isChosenShop, bool isRejectedByCustomer,
    bool isInProgress, bool isCompleted, bool isCancelled,
  ) {
    if (isCancelled) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text('هذا الطلب لم يعد متاحاً',
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ),
      );
    }

    if (isCompleted) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text('✓ تم الانتهاء من الطلب',
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.green)),
        ),
      );
    }

    if (isRejected || isRejectedByCustomer) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text('اختار العميل متجراً آخر',
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ),
      );
    }

    if (isPending) {
      return DarkButton(
        label: _accepting ? 'جاري القبول...' : 'قبول الطلب وفتح المحادثة',
        onTap: _accepting ? null : _accept,
        height: 50,
      );
    }

    if (isChosenShop && _chatRoomId != null) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: DarkButton(
              label: _starting ? 'جاري...' : 'بدأ العمل',
              onTap: _starting ? null : _startWork,
              height: 50,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedDarkButton(
              label: 'المحادثة',
              onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: _chatRoomId),
              height: 50,
            ),
          ),
        ],
      );
    }

    if (isInProgress && _chatRoomId != null) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: DarkButton(
              label: _completing ? 'جاري...' : 'إنهاء الطلب',
              onTap: _completing ? null : _complete,
              height: 50,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedDarkButton(
              label: 'المحادثة',
              onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: _chatRoomId),
              height: 50,
            ),
          ),
        ],
      );
    }

    // Accepted but not yet ShopSelected (waiting for customer to pick)
    final hasPendingQuote = _myQuotation?.status == QuotationStatus.pending;
    final quoteLabel = hasPendingQuote ? 'تعديل العرض' : 'إرسال عرض سعر';

    if (_chatRoomId != null) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: DarkButton(
              label: quoteLabel,
              onTap: _openQuoteScreen,
              height: 50,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedDarkButton(
              label: 'المحادثة',
              onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: _chatRoomId),
              height: 50,
            ),
          ),
        ],
      );
    }

    return DarkButton(
      label: quoteLabel,
      onTap: _openQuoteScreen,
      height: 50,
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  const _InfoBanner({required this.icon, required this.message, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(.07),
      border: Border.all(color: color.withOpacity(.3)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String requestStatus;
  final ShopRequestShopStatus shopStatus;
  final bool isRejectedByCustomer;
  const _StatusBadge({required this.requestStatus, required this.shopStatus, this.isRejectedByCustomer = false});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;

    if (shopStatus == ShopRequestShopStatus.rejected || isRejectedByCustomer) {
      label = 'محجوز لمتجر آخر'; bg = AppColors.red.withOpacity(.1); fg = AppColors.red;
    } else {
      switch (requestStatus) {
        case 'ShopSelected': label = 'تم اختياري'; bg = AppColors.green.withOpacity(.1); fg = AppColors.green; break;
        case 'InProgress':   label = 'قيد التنفيذ'; bg = Colors.blue.withOpacity(.1); fg = Colors.blue; break;
        case 'Completed':    label = 'مكتمل'; bg = AppColors.green.withOpacity(.1); fg = AppColors.green; break;
        case 'Cancelled':    label = 'ملغي'; bg = AppColors.red.withOpacity(.1); fg = AppColors.red; break;
        default:             label = 'مفتوح'; bg = AppColors.goldBg; fg = AppColors.goldText;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
