import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';

class ShopRequestDetailScreen extends StatelessWidget {
  final String requestId;
  const ShopRequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final item = provider.shopInbox.firstWhere(
      (i) => i.requestId == requestId,
      orElse: () => provider.shopInbox.first,
    );
    final request = provider.requests.where((r) => r.id == requestId).isNotEmpty
        ? provider.requests.firstWhere((r) => r.id == requestId)
        : null;
    final hasSentQuote = provider.sentQuote;

    final serviceDesc = request?.notes ??
        'تظليل حراري كامل (٥٠٪ جوانب + ٧٠٪ أمامي) مع تركيب فيلم حماية شفاف على الواجهة الأمامية.';

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
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('طلب وارد #$requestId',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('${item.timeAgo} · ${item.area}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const AppBackButton(),
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
                          // Avatar (visual RIGHT in RTL)
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(14)),
                            alignment: Alignment.center,
                            child: Text(item.mono,
                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                          ),
                          const SizedBox(width: 12),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.customerName,
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const SizedBox(height: 3),
                                Text('عميل · ٨٠ طلبات سابقة',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          // Chat icon (visual LEFT in RTL)
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(13)),
                            child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Service description card ──
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
                          Text('الخدمة المطلوبة',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                          const SizedBox(height: 8),
                          Text(serviceDesc,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.6)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Vehicle + Date side by side ──
                    Row(
                      children: [
                        // Vehicle (visual RIGHT)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('المركبة',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                const SizedBox(height: 5),
                                Text(item.vehicleInfo,
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Preferred date (visual LEFT)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الموعد المفضّل',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                const SizedBox(height: 5),
                                Text('٢٢ يونيو · ٤:٠٠ م',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Vehicle photos ──
                    Text('صور المركبة',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _PhotoSlot(),
                        const SizedBox(width: 10),
                        _PhotoSlot(),
                        const SizedBox(width: 10),
                        _PhotoSlot(),
                      ],
                    ),

                    if (hasSentQuote) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(.07),
                          border: Border.all(color: AppColors.green.withOpacity(.3)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.green, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('تم إرسال عرضك بنجاح — في انتظار رد العميل',
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green)),
                            ),
                          ],
                        ),
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
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
        child: hasSentQuote
            ? OutlinedDarkButton(
                label: 'فتح المحادثة',
                onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: 'sh1'),
              )
            : Row(
                children: [
                  // Send quote (visual RIGHT, wider)
                  Expanded(
                    flex: 2,
                    child: DarkButton(
                      label: 'إرسال عرض سعر',
                      onTap: () => Navigator.pushNamed(context, '/shop/send-quote', arguments: requestId),
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Dismiss (visual LEFT, narrower)
                  Expanded(
                    child: OutlinedDarkButton(
                      label: 'تجاهل',
                      onTap: () => Navigator.pop(context),
                      height: 50,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Expanded(
    child: AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8E3D8),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.hardEdge,
        child: CustomPaint(painter: _StripePainter()),
      ),
    ),
  );
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4CFC4)
      ..strokeWidth = 8;
    for (double i = -size.height; i < size.width + size.height; i += 16) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => false;
}
