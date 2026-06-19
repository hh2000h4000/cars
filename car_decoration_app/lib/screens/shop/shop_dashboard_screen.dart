import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';

class ShopDashboardScreen extends StatelessWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final inbox = provider.shopInbox;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.goldBg,
                        border: Border.all(color: AppColors.goldLight),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('مفتوح', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('لمسات الفخامة', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        Text('لوحة التحكم', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    ShopAvatar(mono: 'ل', size: 46, fontSize: 18),
                  ],
                ),
              ),
            ),
          ),

          // Stats grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.8,
                children: [
                  _StatCard('٣', 'طلبات جديدة', AppColors.goldBg, AppColors.goldText, Icons.inbox_outlined),
                  _StatCard('١٢', 'قيد التنفيذ', const Color(0xFFEBF7EE), AppColors.green, Icons.build_circle_outlined),
                  _StatCard('٤.٨', 'متوسط التقييم', const Color(0xFFFFF8E1), AppColors.star, Icons.star_outline),
                  _StatCard('٢٤٧', 'خدمة مكتملة', AppColors.surface, AppColors.textSecondary, Icons.check_circle_outline),
                ],
              ),
            ),
          ),

          // New requests
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'طلبات جديدة تحتاج ردك'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final item = inbox[i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/shop/request-detail', arguments: item.requestId),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: item.urgency == 'high' ? AppColors.red : AppColors.goldLight,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: item.urgency == 'high' ? AppColors.red.withOpacity(.1) : AppColors.goldBg,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        item.urgency == 'high' ? 'عاجل' : 'عادي',
                                        style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w800,
                                          color: item.urgency == 'high' ? AppColors.red : AppColors.goldText),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text('طلب #${item.requestId}', style: GoogleFonts.tajawal(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(item.timeAgo, style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(item.serviceType, style: GoogleFonts.tajawal(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                        Text(item.vehicleInfo, style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/shop/send-quote', arguments: item.requestId),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('إرسال عرض سعر', style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.dark)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: inbox.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color textColor;
  final IconData icon;
  const _StatCard(this.value, this.label, this.bg, this.textColor, this.icon);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: bg, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        Icon(icon, color: textColor, size: 26),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
            Text(label, style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      ],
    ),
  );
}
