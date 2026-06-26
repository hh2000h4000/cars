import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../models/quotation.dart';
import '../../services/quotation_service.dart';

class QuotationDetailScreen extends StatefulWidget {
  final Quotation quotation;
  const QuotationDetailScreen({super.key, required this.quotation});

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen> {
  late bool _accepted;
  String? _chatRoomId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _accepted = widget.quotation.status == QuotationStatus.accepted;
    _chatRoomId = widget.quotation.chatRoomId;
  }

  Future<void> _accept() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final chatRoomId = await QuotationService.acceptQuotation(widget.quotation.id);
      if (!mounted) return;
      setState(() {
        _accepted = true;
        _chatRoomId = chatRoomId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
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
    final q = widget.quotation;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              child: Row(
                children: [
                  const Text('تفاصيل العرض',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const Spacer(),
                  const AppBackButton(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          ShopAvatar(mono: q.shopMono, size: 52, fontSize: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.shopName,
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                              const SizedBox(height: 3),
                              const Text('متجر معتمد', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(q.shopRating.toString(),
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.star, color: AppColors.star, size: 13),
                                ],
                              ),
                              if (_accepted)
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: AppColors.green, size: 13),
                                      SizedBox(width: 4),
                                      Text('تم القبول',
                                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.green)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Price breakdown
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('السعر الإجمالي',
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white54)),
                              const Spacer(),
                              Text('${q.finalPrice.toStringAsFixed(0)} ريال',
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 12),
                          _PriceRow('رسوم الزيارة', '${q.visitFee}'),
                          const SizedBox(height: 6),
                          _PriceRow('الضمان', q.warranty),
                          const SizedBox(height: 6),
                          _PriceRow('مدة التنفيذ', q.duration),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Service details
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('تفاصيل الخدمة',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          const SizedBox(height: 10),
                          Text(q.serviceDetails, textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.65)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Parts
                    if (q.parts.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('المواد والقطع المستخدمة',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            const SizedBox(height: 10),
                            ...q.parts.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: const BoxDecoration(color: AppColors.goldText, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(p,
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                  const Spacer(),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _accepted
          ? Container(
              padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).padding.bottom + 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: OutlinedDarkButton(
                label: 'فتح المحادثة مع المتجر',
                onTap: _chatRoomId != null
                    ? () => Navigator.pushNamed(context, '/customer/chat', arguments: _chatRoomId)
                    : null,
              ),
            )
          : Container(
              padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).padding.bottom + 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: DarkButton(
                label: _loading ? 'جاري القبول...' : 'قبول هذا العرض',
                onTap: _loading ? null : _accept,
              ),
            ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label,
        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white38)),
      const Spacer(),
      Text(value,
        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70)),
    ],
  );
}
