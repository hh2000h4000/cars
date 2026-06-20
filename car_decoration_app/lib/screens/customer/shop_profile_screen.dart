import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../data/mock_data.dart';
import 'dart:math' as math;

class ShopProfileScreen extends StatelessWidget {
  final String shopId;
  const ShopProfileScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final shop = MockData.shops.firstWhere((s) => s.id == shopId, orElse: () => MockData.shops.first);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Cover + Logo
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Cover background
                    SizedBox(
                      height: 210,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Dark gradient
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [Color(0xFF1B1A14), Color(0xFF2E2917)],
                              ),
                            ),
                          ),
                          // Golden diagonal lines
                          CustomPaint(painter: _GoldenLinesPainter()),
                          // Radial glow
                          Positioned(
                            top: -40, right: -20,
                            child: Container(
                              width: 220, height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [AppColors.goldLight.withOpacity(.22), Colors.transparent]),
                              ),
                            ),
                          ),
                          // Back button — top right
                          Positioned(
                            top: 48, right: 16,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Icon(Icons.chevron_right, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                          // Heart + Share buttons — top left
                          Positioned(
                            top: 48, left: 16,
                            child: Row(
                              children: [
                                _TopIconButton(icon: Icons.favorite_border, onTap: () {}),
                                const SizedBox(width: 8),
                                _TopIconButton(icon: Icons.ios_share_outlined, onTap: () {}),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile avatar — overlaps cover
                    Positioned(
                      bottom: -38,
                      right: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.25), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: shop.profileImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(shop.profileImageUrl!, width: 72, height: 72, fit: BoxFit.cover),
                              )
                            : ShopAvatar(mono: shop.mono, size: 72, fontSize: 28),
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 52)),

              // Name + tags
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(shop.name, style: TextStyle(fontFamily: 'Tajawal', fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          const SizedBox(width: 7),
                          if (shop.verified) const Icon(Icons.verified, color: AppColors.goldText, size: 17),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(shop.area, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 7, runSpacing: 6,
                        alignment: WrapAlignment.start,
                        children: shop.tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFFF4F1EA), borderRadius: BorderRadius.circular(999)),
                          child: Text(t, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF6B675E))),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(value: shop.rating.toString(), label: 'التقييم', icon: Icons.star, iconColor: AppColors.star),
                        _Divider(),
                        _StatItem(value: shop.reviewCount.toString(), label: 'تقييم'),
                        _Divider(),
                        _StatItem(value: shop.completedJobs.toString(), label: 'خدمة مكتملة'),
                        _Divider(),
                        _StatItem(value: shop.distance, label: 'المسافة', icon: Icons.location_on, iconColor: AppColors.goldText),
                      ],
                    ),
                  ),
                ),
              ),

              // Description
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('عن المتجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        shop.description,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.65),
                      ),
                    ],
                  ),
                ),
              ),

              // Services
              const SliverToBoxAdapter(child: SectionHeader(title: 'الخدمات المتاحة')),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
                  child: Column(
                    children: shop.services.map((s) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                if (s.description != null) ...[
                                  const SizedBox(height: 3),
                                  Text(s.description!, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 18),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),

              // Gallery
              const SliverToBoxAdapter(child: SectionHeader(title: 'معرض الأعمال')),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
                    itemCount: shop.gallery.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => Container(
                      width: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFF23211A), Color(0xFF3A3320 + (i * 0x020100))],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(10),
                      child: Text(shop.gallery[i], style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.goldMuted)),
                    ),
                  ),
                ),
              ),

              // Reviews
              const SliverToBoxAdapter(child: SectionHeader(title: 'آراء العملاء')),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final r = shop.reviews[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                      child: Container(
                        padding: const EdgeInsets.all(15),
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
                                Row(
                                  children: [
                                    Text(r.author, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.star, color: AppColors.star, size: 13),
                                    const SizedBox(width: 3),
                                    Text(r.rating.toString(), style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                  ],
                                ),
                                const Spacer(),
                                Text(r.date, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(r.comment, textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.6)),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: shop.reviews.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),

          // Floating bottom actions
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).padding.bottom + 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.08), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/customer/requests/new'),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_outline, size: 18, color: AppColors.dark),
                            const SizedBox(width: 6),
                            Text('طلب خدمة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.dark)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: shopId),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.borderStrong),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textPrimary),
                            const SizedBox(width: 6),
                            Text('مراسلة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;
  const _StatItem({required this.value, required this.label, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 3),
          ],
          Text(value, style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        ],
      ),
      const SizedBox(height: 3),
      Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 32, color: AppColors.border);
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

class _GoldenLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4B96A).withOpacity(0.11)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 22.0;
    final count = (size.width + size.height) ~/ spacing + 2;
    for (int i = 0; i < count; i++) {
      final x = i * spacing - size.height;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * math.tan(math.pi / 4), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GoldenLinesPainter oldDelegate) => false;
}
