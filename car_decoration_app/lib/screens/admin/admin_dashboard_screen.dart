import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final pending = provider.pendingShops.where((s) => s.status.name == 'pending').length;
    final disputes = provider.disputes.where((d) => d.status.name == 'underReview').length;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('مباشر', style: GoogleFonts.tajawal(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white60)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('لوحة الإدارة', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text('المشرف العام', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: Text('م', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.dark)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // KPI grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.7,
                children: [
                  _KpiCard('١٢٤', 'متجر نشط', AppColors.goldLight, AppColors.dark),
                  _KpiCard(pending.toString(), 'بانتظار الموافقة', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
                  _KpiCard('٣٨٩', 'طلب هذا الشهر', const Color(0xFFEBF7EE), AppColors.green),
                  _KpiCard(disputes.toString(), 'نزاعات مفتوحة', const Color(0xFFFFF0EE), AppColors.red),
                ],
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('إجراءات سريعة', style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.storefront_outlined,
                          label: 'موافقة المتاجر',
                          badge: pending > 0 ? pending.toString() : null,
                          onTap: () => Navigator.pushNamed(context, '/admin/pending'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.gavel_outlined,
                          label: 'النزاعات',
                          badge: disputes > 0 ? disputes.toString() : null,
                          onTap: () => Navigator.pushNamed(context, '/admin/disputes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Recent shops
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/admin/pending'),
                    child: Text('عرض الكل', style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                  ),
                  const Spacer(),
                  Text('طلبات التسجيل الأخيرة', style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final shop = provider.pendingShops[i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1D17),
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AdminStatusBadge(shop.status.label, shop.status.color),
                            const SizedBox(height: 4),
                            Text(shop.submittedAt, style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white30)),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(shop.name, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                            Text(shop.city, style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                          ],
                        ),
                        const SizedBox(width: 10),
                        ShopAvatar(mono: shop.mono, size: 40, fontSize: 16),
                      ],
                    ),
                  ),
                );
              },
              childCount: provider.pendingShops.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color textColor;
  const _KpiCard(this.value, this.label, this.bg, this.textColor);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: GoogleFonts.tajawal(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
        Text(label, style: GoogleFonts.tajawal(fontSize: 11.5, fontWeight: FontWeight.w700, color: textColor.withOpacity(.7))),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1D17),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Icon(icon, color: AppColors.goldLight, size: 28),
              if (badge != null)
                Positioned(
                  top: -4, right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                    child: Text(badge!, style: GoogleFonts.tajawal(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white70)),
        ],
      ),
    ),
  );
}

class _AdminStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _AdminStatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(999)),
    child: Text(label, style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
  );
}
