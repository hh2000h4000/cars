import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class ShopRequestDetailScreen extends StatelessWidget {
  final String requestId;
  const ShopRequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final request = provider.requests.firstWhere((r) => r.id == requestId, orElse: () => provider.requests.first);
    final hasSentQuote = provider.sentQuote;

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
                  Text('طلب #${request.id}', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(width: 14),
                  const AppBackButton(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Vehicle card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('تفاصيل المركبة', style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldMuted)),
                          const SizedBox(height: 8),
                          Text('${request.vehicleBrand} ${request.vehicleModel} ${request.vehicleYear}',
                            style: GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(request.vehicleColor, style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white54)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Service info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              Text('نوع الخدمة المطلوبة', style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(request.serviceType, style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          if (request.notes != null) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: AppColors.border),
                            const SizedBox(height: 12),
                            Text('ملاحظات العميل', style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Text(request.notes!, textAlign: TextAlign.right,
                              style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.6)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Location
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.location_on_outlined, color: AppColors.goldText, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('موقع الخدمة (منزلية)', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                                Text('العليا، الرياض', style: GoogleFonts.tajawal(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Timeline info
                    Text('تاريخ الطلب: ${request.dateLabel}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),

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
                            const Spacer(),
                            Text('تم إرسال عرضك بنجاح — في انتظار رد العميل',
                              style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green)),
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle, color: AppColors.green, size: 18),
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).padding.bottom + 14),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
        child: hasSentQuote
            ? OutlinedDarkButton(
                label: 'فتح المحادثة',
                onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: 'sh1'),
              )
            : DarkButton(
                label: 'إرسال عرض سعر',
                onTap: () => Navigator.pushNamed(context, '/shop/send-quote', arguments: requestId),
              ),
      ),
    );
  }
}
