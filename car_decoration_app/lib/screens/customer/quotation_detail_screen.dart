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
  late bool _rejected;
  String? _chatRoomId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _accepted = widget.quotation.status == QuotationStatus.accepted;
    _rejected = widget.quotation.status == QuotationStatus.rejected;
    _chatRoomId = widget.quotation.chatRoomId;
  }

  Future<void> _accept() async {
    if (_loading) return;

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

  String get _quotationRef {
    final id = widget.quotation.id;
    final suffix = id.length > 6 ? id.substring(id.length - 6).toUpperCase() : id.toUpperCase();
    return 'QT-$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quotation;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              child: Row(
                children: [
                  const Text('عرض سعر رسمي',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const Spacer(),
                  const AppBackButton(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: _accepted ? AppColors.green : AppColors.border,
                          width: _accepted ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          if (_accepted)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.greenLight,
                                borderRadius: BorderRadius.circular(10),
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
                            ),
                          Row(
                            children: [
                              ShopAvatar(mono: q.shopMono, size: 48, fontSize: 19),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(q.shopName,
                                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(q.shopRating.toStringAsFixed(1),
                                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                        const SizedBox(width: 3),
                                        const Icon(Icons.star, color: AppColors.star, size: 13),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.greenLight,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('متجر معتمد',
                                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(_quotationRef,
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('صالح 72 ساعة',
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Stats chips row
                    Row(
                      children: [
                        Expanded(child: _StatChip(Icons.schedule_outlined, 'المدة', q.duration)),
                        const SizedBox(width: 8),
                        Expanded(child: _StatChip(Icons.verified_outlined, 'الضمان', q.warranty)),
                        const SizedBox(width: 8),
                        Expanded(child: _StatChip(Icons.directions_car_outlined, 'الزيارة', q.visitFee)),
                      ],
                    ),
                    const SizedBox(height: 14),

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
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 16,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.goldText,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const Text('تفاصيل الخدمة',
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(q.serviceDetails, textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.65)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Parts & materials
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
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 16,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldText,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const Text('القطع والمواد المستخدمة',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...q.parts.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  Text(p,
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 6, height: 6,
                                    decoration: const BoxDecoration(color: AppColors.goldText, shape: BoxShape.circle),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Price summary box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B1A14), Color(0xFF2E2917)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('السعر النهائي شامل الضريبة',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white54)),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Spacer(),
                              const Text('ريال',
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.goldMuted)),
                              const SizedBox(width: 6),
                              Text(q.finalPrice.toStringAsFixed(0),
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                            ],
                          ),
                          if (q.visitFee != 'مجاناً') ...[
                            const SizedBox(height: 10),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 8),
                            _PriceRow('رسوم الزيارة', q.visitFee),
                          ],
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).padding.bottom + 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: _accepted
            ? DarkButton(
                label: 'فتح المحادثة مع المتجر',
                onTap: _chatRoomId != null
                    ? () => Navigator.pushNamed(context, '/customer/chat', arguments: _chatRoomId)
                    : null,
              )
            : _rejected
                ? Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text('تم رفض هذا العرض',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                  )
                : GestureDetector(
                    onTap: _loading ? null : _accept,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _loading ? AppColors.border : AppColors.dark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: _loading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('قبول العرض',
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, size: 18, color: AppColors.goldText),
        const SizedBox(height: 5),
        Text(label,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    ),
  );
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
