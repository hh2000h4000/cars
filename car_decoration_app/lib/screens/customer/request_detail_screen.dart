import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/service_request.dart';
import '../../models/quotation.dart';
import '../../services/quotation_service.dart';

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
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    _loadQuotations();
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

  Future<void> _acceptQuote(String quotationId) async {
    if (_accepting) return;
    setState(() => _accepting = true);
    try {
      final chatRoomId = await QuotationService.acceptQuotation(quotationId);
      if (!mounted) return;
      setState(() {
        _acceptedQuoteId = quotationId;
        _accepting = false;
        for (final q in _quotations) {
          q.status = q.id == quotationId ? QuotationStatus.accepted : QuotationStatus.rejected;
        }
      });
      context.read<AppProvider>().reloadRequests();
      Navigator.pushNamed(context, '/customer/chat', arguments: chatRoomId);
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
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${request.vehicleBrand} ${request.vehicleModel}',
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                              Text('${request.vehicleYear} · ${request.vehicleColor}',
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.goldMuted)),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(request.serviceType,
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.goldMuted)),
                              Text(request.dateLabel,
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

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
                      const SizedBox(height: 16),
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
                            decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(999)),
                            child: Text('${_quotations.length} عروض وصلت',
                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._quotations.map((q) => _QuotationCard(
                        quotation: q,
                        isAccepted: _acceptedQuoteId == q.id,
                        isAccepting: _accepting,
                        onAccept: () => _acceptQuote(q.id),
                        onView: () => Navigator.pushNamed(
                          context, '/customer/quotation-detail', arguments: q,
                        ).then((_) => _loadQuotations()),
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

                    if (request.status == RequestStatus.pending)
                      OutlinedDarkButton(
                        label: 'تعديل الطلب',
                        onTap: () => Navigator.pushNamed(context, '/customer/requests/edit', arguments: request),
                        textColor: AppColors.textPrimary,
                        borderColor: AppColors.border,
                      ),

                    if (request.status == RequestStatus.inProgress)
                      OutlinedDarkButton(
                        label: 'تقديم شكوى',
                        onTap: () => Navigator.pushNamed(context, '/customer/complaint', arguments: widget.requestId),
                        textColor: AppColors.red,
                        borderColor: AppColors.red.withOpacity(.4),
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

class _QuotationCard extends StatelessWidget {
  final Quotation quotation;
  final bool isAccepted;
  final bool isAccepting;
  final VoidCallback onAccept;
  final VoidCallback onView;

  const _QuotationCard({
    required this.quotation,
    required this.isAccepted,
    required this.isAccepting,
    required this.onAccept,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onView,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isAccepted ? AppColors.green : (quotation.isBestValue ? AppColors.goldLight : AppColors.border),
            width: isAccepted || quotation.isBestValue ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            if (quotation.isBestValue && !isAccepted)
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
            if (isAccepted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.green, size: 14),
                    SizedBox(width: 5),
                    Text('تم القبول',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.green)),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          ShopAvatar(mono: quotation.shopMono, size: 40, fontSize: 16),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(quotation.shopName,
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              Row(
                                children: [
                                  Text(quotation.shopRating.toString(),
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.star, color: AppColors.star, size: 12),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${quotation.finalPrice.toStringAsFixed(0)} ريال',
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          Text('+ ${quotation.visitFee} رسوم زيارة',
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoChip(Icons.schedule_outlined, quotation.duration),
                      const SizedBox(width: 8),
                      _InfoChip(Icons.verified_outlined, quotation.warranty),
                    ],
                  ),
                  if (!isAccepted && quotation.status == QuotationStatus.pending) ...[
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
                  ],
                ],
              ),
            ),
          ],
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
