import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../data/mock_data.dart';
import '../../providers/app_provider.dart';

class ShopSelectScreen extends StatelessWidget {
  const ShopSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
              child: Row(
                children: [
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('اختر المتاجر', style: GoogleFonts.tajawal(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text('سيتلقى كل متجر طلبك ويرسل عرضه', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(width: 14),
                  const AppBackButton(),
                ],
              ),
            ),

            // Info banner
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: AppColors.goldBg, border: Border.all(color: AppColors.goldLight), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Spacer(),
                    Text('اختر حتى ٥ متاجر للحصول على أفضل عرض', style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                    const SizedBox(width: 8),
                    const Icon(Icons.info_outline, color: AppColors.goldText, size: 16),
                  ],
                ),
              ),
            ),

            // Selected count
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
              child: Row(
                children: [
                  const Spacer(),
                  Text('تم اختيار ${provider.selectedShops.length} متجر',
                    style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                itemCount: MockData.shops.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final shop = MockData.shops[i];
                  final selected = provider.selectedShops.contains(shop.id);

                  return GestureDetector(
                    onTap: () => provider.toggleShop(shop.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.goldBg : Colors.white,
                        border: Border.all(color: selected ? AppColors.goldLight : AppColors.border, width: selected ? 1.5 : 1),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: selected ? [BoxShadow(color: AppColors.gold.withOpacity(.12), blurRadius: 14, offset: const Offset(0, 4))] : [],
                      ),
                      child: Row(
                        children: [
                          // Checkbox
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.goldText : Colors.transparent,
                              border: Border.all(color: selected ? AppColors.goldText : AppColors.borderStrong, width: 2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: selected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                          ),
                          const SizedBox(width: 12),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (shop.verified) const Icon(Icons.verified, color: AppColors.goldText, size: 13),
                                    const SizedBox(width: 5),
                                    Text(shop.name, style: GoogleFonts.tajawal(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(shop.area, style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(shop.distance, style: GoogleFonts.tajawal(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                                    const SizedBox(width: 3),
                                    const Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 12),
                                    const SizedBox(width: 10),
                                    Text(shop.rating.toString(), style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                    const SizedBox(width: 3),
                                    const Icon(Icons.star, color: AppColors.star, size: 12),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ShopAvatar(mono: shop.mono, size: 46, fontSize: 18),
                        ],
                      ),
                    ),
                  );
                },
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
        child: DarkButton(
          label: 'إرسال الطلب (${provider.selectedShops.length} متاجر)',
          onTap: provider.selectedShops.isEmpty ? null : () {
            Navigator.pushNamedAndRemoveUntil(context, '/customer/requests', (r) => r.settings.name == '/customer/home');
          },
        ),
      ),
    );
  }
}
