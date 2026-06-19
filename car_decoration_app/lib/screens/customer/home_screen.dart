import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../data/mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _categories = [
    ('تظليل', Icons.gradient),
    ('حماية PPF', Icons.shield_outlined),
    ('تلميع', Icons.auto_fix_high_outlined),
    ('تنظيف', Icons.water_drop_outlined),
    ('إضاءة', Icons.lightbulb_outline),
    ('صوتيات', Icons.speaker_outlined),
    ('جلود', Icons.airline_seat_recline_normal_outlined),
    ('ملصقات', Icons.style_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // Top bar
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 16),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: Text('ع', style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.dark)),
                    ),
                    const SizedBox(width: 10),
                    // Notification
                    Stack(
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(13)),
                          child: const Icon(Icons.notifications_outlined, color: AppColors.dark, size: 21),
                        ),
                        Positioned(
                          top: 9, right: 11,
                          child: Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: AppColors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('مساء الخير،', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        Row(
                          children: [
                            Text('▾', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                            const SizedBox(width: 5),
                            Text('العليا، الرياض', style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            const SizedBox(width: 5),
                            const Icon(Icons.location_on_outlined, color: AppColors.goldText, size: 15),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
              child: Container(
                height: 50,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('ابحث عن خدمة أو متجر تزيين...', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    const Spacer(),
                    const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  ],
                ),
              ),
            ),
          ),

          // Hero banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/customer/requests/new'),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.3), blurRadius: 28, offset: const Offset(0, 12))],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -40, right: -20,
                        child: Container(
                          width: 160, height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [AppColors.goldLight.withOpacity(.35), Colors.transparent]),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(999)),
                            child: Text('خدمة منزلية متنقلة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.dark)),
                          ),
                          const SizedBox(height: 11),
                          Text('احجز خدمة احترافية\nتصلك أينما كنت', style: TextStyle(fontFamily: 'Tajawal', fontSize: 21, fontWeight: FontWeight.w900, color: const Color(0xFFFBF7EC), height: 1.35)),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                            decoration: BoxDecoration(color: const Color(0xFFFBF7EC), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chevron_left, color: AppColors.dark, size: 18),
                                const SizedBox(width: 4),
                                Text('اطلب الآن', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.dark)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Categories
          const SliverToBoxAdapter(child: SectionHeader(title: 'الخدمات')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 16, crossAxisSpacing: 6, childAspectRatio: .85),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final (name, icon) = _categories[i];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/customer/requests/new'),
                    child: Column(
                      children: [
                        Container(
                          width: 58, height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.04), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Icon(icon, color: AppColors.goldText, size: 26),
                        ),
                        const SizedBox(height: 7),
                        Text(name, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF3A382F))),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Featured shops
          SliverToBoxAdapter(
            child: SectionHeader(title: 'متاجر مميزة قريبة منك', action: 'عرض الكل', onAction: () {}),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final shop = MockData.shops[i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/customer/shop', arguments: shop.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.04), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: [
                          // Cover
                          Container(
                            height: 96,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFF23211A), Color(0xFF3A3320)]),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 8, right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
                                    child: Row(
                                      children: [
                                        Text(shop.distance, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFFFBF7EC))),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.location_on, color: AppColors.goldLight, size: 13),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Info
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          if (shop.verified) const Icon(Icons.verified, color: AppColors.goldText, size: 15),
                                          const SizedBox(width: 6),
                                          Text(shop.name, style: TextStyle(fontFamily: 'Tajawal', fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(shop.area, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text('${shop.completedJobs} عملية مكتملة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                          const SizedBox(width: 12),
                                          Row(children: [
                                            Text(shop.rating.toString(), style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                            const SizedBox(width: 3),
                                            const Icon(Icons.star, color: AppColors.star, size: 14),
                                          ]),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        alignment: WrapAlignment.end,
                                        children: shop.tags.map((t) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFFF4F1EA), borderRadius: BorderRadius.circular(999)),
                                          child: Text(t, style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF6B675E))),
                                        )).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Logo overlaps cover
                                Transform.translate(
                                  offset: const Offset(0, -32),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 3),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.2), blurRadius: 12, offset: const Offset(0, 4))],
                                    ),
                                    child: ShopAvatar(mono: shop.mono, size: 50, fontSize: 20),
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
              childCount: MockData.shops.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
