import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/service_request.dart';
import '../../models/quotation.dart';
import '../../services/quotation_service.dart';
import '../../services/request_service.dart';
import '../../services/review_service.dart';
import 'review_screen.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  List<Quotation> _quotations = [];
  bool _loadingQuotations = false;
  String? _acceptedQuoteId;
  String? _acceptedChatRoomId;
  bool _accepting = false;
  bool _cancelling = false;
  bool _reopening = false;
  bool _hasReviewed = false;

  @override
  void initState() {
    super.initState();
    _loadQuotations();
    _checkHasReviewed();
  }

  Future<void> _checkHasReviewed() async {
    try {
      final result = await ReviewService.hasReviewed(widget.requestId);
      if (mounted) setState(() => _hasReviewed = result);
    } catch (_) {}
  }

  Future<void> _loadQuotations() async {
    setState(() => _loadingQuotations = true);
    try {
      final quotes = await QuotationService.getQuotations(widget.requestId);
      if (!mounted) return;
      String? acceptedId;
      for (final q in quotes) {
        if (q.status == QuotationStatus.accepted) { acceptedId = q.id; break; }
      }
      setState(() {
        _quotations = quotes;
        _loadingQuotations = false;
        _acceptedQuoteId = acceptedId;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingQuotations = false);
    }
  }

  Future<void> _reopenRequest() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('إلغاء الاتفاق',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        content: const Text(
          'سيتم إلغاء الاتفاق مع المتجر الحالي وإعادة فتح الطلب لاستقبال عروض جديدة. هل تريد المتابعة؟',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.65),
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, color: AppColors.goldText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _reopening = true);
    try {
      await RequestService.reopenRequest(widget.requestId);
      if (!mounted) return;
      context.read<AppProvider>().reloadRequests();
      await _loadQuotations();
      if (mounted) setState(() => _reopening = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _reopening = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', ''),
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13)),
        backgroundColor: AppColors.red,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  Future<void> _cancelRequest() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('إلغاء الطلب نهائياً',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        content: const Text(
          'سيتم إلغاء الطلب نهائياً ولن يتمكن أي متجر من تقديم عروض جديدة عليه. هل تريد المتابعة؟',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.65),
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد الإلغاء',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, color: AppColors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await RequestService.cancelRequest(widget.requestId);
      if (!mounted) return;
      context.read<AppProvider>().reloadRequests();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', ''),
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13)),
        backgroundColor: AppColors.red,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  Future<void> _acceptQuote(String quotationId) async {
    if (_accepting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('تأكيد قبول العرض',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        content: const Text(
          'عند قبول هذا العرض، سيتم رفض جميع العروض الأخرى المرتبطة بهذا الطلب تلقائياً، ولن تتمكن من اختيار متجر آخر لنفس الطلب.',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.65),
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد القبول',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, color: AppColors.goldText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _accepting = true);
    try {
      final chatRoomId = await QuotationService.acceptQuotation(quotationId);
      if (!mounted) return;
      setState(() {
        _acceptedQuoteId = quotationId;
        _acceptedChatRoomId = chatRoomId;
        _accepting = false;
        for (final q in _quotations) {
          q.status = q.id == quotationId ? QuotationStatus.accepted : QuotationStatus.rejected;
        }
      });
      context.read<AppProvider>().reloadRequests();
      Navigator.pushNamed(context, '/customer/chat', arguments: chatRoomId)
          .then((_) { if (mounted) _loadQuotations(); });
    } catch (e) {
      if (!mounted) return;
      setState(() => _accepting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', ''),
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13)),
        backgroundColor: AppColors.red,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final request = provider.requests.firstWhere(
      (r) => r.id == widget.requestId,
      orElse: () => provider.requests.first,
    );
    final hasAccepted = _acceptedQuoteId != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              child: Row(
                children: [
                  StatusBadge(label: request.status.label, type: request.status.colorType),
                  const Spacer(),
                  Text('طلب #${request.requestNumber}',
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(width: 14),
                  const AppBackButton(),
                ],
              ),
            ),

            if (_loadingQuotations)
              const LinearProgressIndicator(color: AppColors.goldText, backgroundColor: AppColors.goldBg),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${request.vehicleBrand} ${request.vehicleModel}',
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('${request.vehicleYear} · ${request.vehicleColor}',
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.goldMuted)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(request.serviceType,
                                  textAlign: TextAlign.end,
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldMuted)),
                                Text(request.dateLabel,
                                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 5-stage progress stepper
                    _RequestStepper(
                      status: request.status,
                      hasQuotations: _quotations.isNotEmpty || request.quotationCount > 0,
                    ),
                    const SizedBox(height: 14),

                    // Notes
                    if (request.notes != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ملاحظات الطلب',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            const SizedBox(height: 7),
                            Text(request.notes!, textAlign: TextAlign.right,
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.6)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Quotations section
                    if (_quotations.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text('العروض الواردة',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: hasAccepted ? AppColors.greenLight : AppColors.goldBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              hasAccepted ? 'تم الاختيار' : '${_quotations.length} عروض وصلت',
                              style: TextStyle(
                                fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800,
                                color: hasAccepted ? AppColors.green : AppColors.goldText,
                              )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._quotations.map((q) => _QuotationCard(
                        quotation: q,
                        requestStatus: request.status,
                        isAccepted: _acceptedQuoteId == q.id,
                        isAccepting: _accepting,
                        onAccept: () => _acceptQuote(q.id),
                        onView: () => Navigator.pushNamed(
                          context, '/customer/quotation-detail', arguments: q,
                        ).then((_) => _loadQuotations()),
                        onOpenChat: (_acceptedQuoteId == q.id && _acceptedChatRoomId != null)
                            ? () => Navigator.pushNamed(context, '/customer/chat', arguments: _acceptedChatRoomId)
                            : q.chatRoomId != null
                                ? () => Navigator.pushNamed(context, '/customer/chat', arguments: q.chatRoomId)
                                : null,
                      )),
                    ] else if (!_loadingQuotations) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.hourglass_empty_outlined, color: AppColors.textMuted, size: 36),
                            SizedBox(height: 10),
                            Text('في انتظار العروض',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    if (request.status == RequestStatus.open) ...[
                      OutlinedDarkButton(
                        label: 'تعديل الطلب',
                        onTap: () => Navigator.pushNamed(context, '/customer/requests/edit', arguments: request),
                        textColor: AppColors.textPrimary,
                        borderColor: AppColors.border,
                      ),
                      const SizedBox(height: 10),
                      OutlinedDarkButton(
                        label: _cancelling ? 'جاري الإلغاء...' : 'إلغاء الطلب',
                        onTap: _cancelling ? null : _cancelRequest,
                        textColor: AppColors.red,
                        borderColor: AppColors.red.withOpacity(.3),
                      ),
                    ],

                    if (request.status == RequestStatus.shopSelected ||
                        request.status == RequestStatus.inProgress)
                      OutlinedDarkButton(
                        label: 'تقديم شكوى',
                        onTap: () => Navigator.pushNamed(context, '/customer/complaint', arguments: widget.requestId),
                        textColor: AppColors.red,
                        borderColor: AppColors.red.withOpacity(.4),
                      ),

                    if (request.status == RequestStatus.shopSelected) ...[
                      const SizedBox(height: 10),
                      OutlinedDarkButton(
                        label: _reopening ? 'جاري إعادة الفتح...' : 'إلغاء الاتفاق وإعادة فتح الطلب',
                        onTap: (_reopening || _cancelling) ? null : _reopenRequest,
                        textColor: AppColors.goldText,
                        borderColor: AppColors.goldLight,
                      ),
                      const SizedBox(height: 10),
                      OutlinedDarkButton(
                        label: _cancelling ? 'جاري الإلغاء...' : 'إلغاء الطلب نهائياً',
                        onTap: (_cancelling || _reopening) ? null : _cancelRequest,
                        textColor: AppColors.red,
                        borderColor: AppColors.red.withOpacity(.3),
                      ),
                    ],

                    if (request.status == RequestStatus.completed)
                      _hasReviewed
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.greenLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.green.withOpacity(.3)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
                                  SizedBox(width: 8),
                                  Text('تم تقييم الخدمة',
                                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.green)),
                                ],
                              ),
                            )
                          : DarkButton(
                              label: 'تقييم الخدمة',
                              onTap: () {
                                final accepted = _quotations.firstWhere(
                                  (q) => q.status == QuotationStatus.accepted,
                                  orElse: () => _quotations.isNotEmpty ? _quotations.first : Quotation.empty,
                                );
                                Navigator.pushNamed(context, '/customer/review',
                                  arguments: ReviewArgs(
                                    requestId: widget.requestId,
                                    shopName: accepted.shopName,
                                  )).then((_) => _checkHasReviewed());
                              },
                            ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 5-stage progress tracker ──────────────────────────────────────────────────

class _RequestStepper extends StatelessWidget {
  final RequestStatus status;
  final bool hasQuotations;

  const _RequestStepper({required this.status, required this.hasQuotations});

  int get _activeStage {
    switch (status) {
      case RequestStatus.open:
        return hasQuotations ? 1 : 0;
      case RequestStatus.shopSelected:
        return 2;
      case RequestStatus.inProgress:
        return 3;
      case RequestStatus.completed:
        return 5; // all stages done
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['نُشر الطلب', 'عروض مستلمة', 'تم الاختيار', 'قيد التنفيذ', 'مكتمل'];
    const icons = [
      Icons.article_outlined,
      Icons.inbox_outlined,
      Icons.handshake_outlined,
      Icons.engineering_outlined,
      Icons.verified_outlined,
    ];
    final active = _activeStage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: List.generate(labels.length, (i) {
          final isDone = i < active;
          final isActive = i == active;
          final isLast = i == labels.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? AppColors.goldText
                          : isActive
                              ? AppColors.dark
                              : Colors.transparent,
                      border: Border.all(
                        color: isDone
                            ? AppColors.goldText
                            : isActive
                                ? AppColors.dark
                                : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isDone ? Icons.check : icons[i],
                      size: 15,
                      color: isDone || isActive ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 26,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: isDone ? AppColors.goldText.withOpacity(.35) : AppColors.border,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Label
              Padding(
                padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 32),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13.5,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isDone
                        ? AppColors.goldText
                        : isActive
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Quotation card ────────────────────────────────────────────────────────────

class _QuotationCard extends StatelessWidget {
  final Quotation quotation;
  final RequestStatus requestStatus;
  final bool isAccepted;
  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onView;
  final VoidCallback? onOpenChat;

  const _QuotationCard({
    required this.quotation,
    required this.requestStatus,
    required this.isAccepted,
    required this.isAccepting,
    required this.onAccept,
    required this.onView,
    this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = quotation.status == QuotationStatus.rejected;
    final isPending = quotation.status == QuotationStatus.pending;

    return Opacity(
      opacity: isRejected ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onView,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isAccepted
                  ? AppColors.green
                  : (quotation.isBestValue && isPending ? AppColors.goldLight : AppColors.border),
              width: isAccepted ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              // Top banner
              if (isAccepted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.green, size: 14),
                      SizedBox(width: 6),
                      Text('تم قبول هذا العرض',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.green)),
                    ],
                  ),
                )
              else if (isRejected)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cancel_outlined, color: AppColors.textMuted, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        requestStatus == RequestStatus.open
                            ? 'تم الإلغاء — انتظر عرضاً جديداً'
                            : 'تم رفض هذا العرض تلقائياً',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              else if (quotation.isBestValue)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: const BoxDecoration(
                    color: AppColors.goldBg,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
                  ),
                  child: const Text('الأفضل قيمة', textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Shop + Price row
                    Row(
                      children: [
                        ShopAvatar(mono: quotation.shopMono, size: 40, fontSize: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(quotation.shopName,
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              Row(
                                children: [
                                  Text(quotation.shopRating.toStringAsFixed(1),
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.star, color: AppColors.star, size: 12),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${quotation.finalPrice.toStringAsFixed(0)} ريال',
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                            Text('+ ${quotation.visitFee} رسوم زيارة',
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Info chips
                    Row(
                      children: [
                        _InfoChip(Icons.schedule_outlined, quotation.duration),
                        const SizedBox(width: 8),
                        _InfoChip(Icons.verified_outlined, quotation.warranty),
                      ],
                    ),

                    // Action buttons
                    if (isPending) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onView,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.borderStrong),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                alignment: Alignment.center,
                                child: const Text('عرض التفاصيل',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: isAccepting ? null : onAccept,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: isAccepting ? null
                                      : const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                                  color: isAccepting ? AppColors.border : null,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                alignment: Alignment.center,
                                child: isAccepting
                                    ? const SizedBox(width: 18, height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText))
                                    : const Text('قبول العرض',
                                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.dark)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (isAccepted && onOpenChat != null) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: onOpenChat,
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.dark,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, color: Colors.white, size: 14),
                              SizedBox(width: 7),
                              Text('فتح المحادثة',
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(width: 4),
        Icon(icon, size: 13, color: AppColors.textMuted),
      ],
    ),
  );
}
