import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../services/review_service.dart';
import '../../models/paged_result.dart';

class ShopProfileScreen extends StatefulWidget {
  final String shopId;
  const ShopProfileScreen({super.key, required this.shopId});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  PagedResult<ReviewItem>? _reviewsResult;
  bool _reviewsLoading = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews({bool loadMore = false}) async {
    if (loadMore && (_reviewsResult?.hasNextPage != true || _loadingMore)) return;

    if (loadMore) {
      setState(() => _loadingMore = true);
    } else {
      setState(() => _reviewsLoading = true);
    }

    try {
      final nextPage = loadMore ? (_reviewsResult?.page ?? 0) + 1 : 1;
      final result = await ReviewService.getShopReviews(widget.shopId, page: nextPage);
      if (!mounted) return;
      setState(() {
        if (loadMore && _reviewsResult != null) {
          _reviewsResult = PagedResult(
            items: [..._reviewsResult!.items, ...result.items],
            totalCount: result.totalCount,
            page: result.page,
            pageSize: result.pageSize,
            totalPages: result.totalPages,
            hasNextPage: result.hasNextPage,
          );
        } else {
          _reviewsResult = result;
        }
        _reviewsLoading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() { _reviewsLoading = false; _loadingMore = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shops = context.watch<AppProvider>().shops;
    final matches = shops.where((s) => s.id == widget.shopId).toList();
    if (matches.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: Text('المتجر غير متاح',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, color: AppColors.textSecondary))),
      );
    }
    final shop = matches.first;
    final reviews = _reviewsResult?.items ?? [];
    final totalReviews = _reviewsResult?.totalCount ?? shop.reviewCount;

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
                    SizedBox(
                      height: 210,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [Color(0xFF1B1A14), Color(0xFF2E2917)],
                              ),
                            ),
                          ),
                          CustomPaint(painter: _GoldenLinesPainter()),
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
                        ],
                      ),
                    ),
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
                        children: [
                          Text(shop.name, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          const SizedBox(width: 7),
                          if (shop.verified) const Icon(Icons.verified, color: AppColors.goldText, size: 17),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(shop.area, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 7, runSpacing: 6,
                        children: shop.tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFFF4F1EA), borderRadius: BorderRadius.circular(999)),
                          child: Text(t, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B675E))),
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
                        _StatItem(
                          value: shop.rating > 0 ? shop.rating.toStringAsFixed(1) : '—',
                          label: 'التقييم',
                          icon: Icons.star,
                          iconColor: AppColors.star,
                        ),
                        _Divider(),
                        _StatItem(value: '$totalReviews', label: 'تقييم'),
                        _Divider(),
                        _StatItem(value: shop.completedJobs.toString(), label: 'خدمة مكتملة'),
                        _Divider(),
                        _StatItem(value: shop.distance.isNotEmpty ? shop.distance : '—', label: 'المسافة', icon: Icons.location_on, iconColor: AppColors.goldText),
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
                      const Text('عن المتجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(
                        shop.description.isNotEmpty ? shop.description : 'لا يوجد وصف متاح.',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.65),
                      ),
                    ],
                  ),
                ),
              ),

              // Reviews header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
                  child: Row(
                    children: [
                      const Text('آراء العملاء', style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(width: 8),
                      if (totalReviews > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(999)),
                          child: Text('$totalReviews', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                        ),
                    ],
                  ),
                ),
              ),

              // Rating summary bar (if has reviews)
              if (!_reviewsLoading && reviews.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                    child: _RatingSummaryBar(reviews: reviews, overallRating: shop.rating),
                  ),
                ),

              // Reviews list
              if (_reviewsLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator(color: AppColors.goldText, strokeWidth: 2)),
                  ),
                )
              else if (reviews.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.star_border_rounded, color: AppColors.border, size: 36),
                          SizedBox(height: 8),
                          Text('لا توجد تقييمات بعد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                          SizedBox(height: 4),
                          Text('كن أول من يُقيّم هذا المتجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                      child: _ReviewCard(review: reviews[i]),
                    ),
                    childCount: reviews.length,
                  ),
                ),

              // Load more button
              if (_reviewsResult?.hasNextPage == true)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
                    child: GestureDetector(
                      onTap: () => _loadReviews(loadMore: true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _loadingMore
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText))
                            : const Text('عرض المزيد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                      ),
                    ),
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
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/customer/requests/new'),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text('اطلب عرض سعر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final ReviewItem review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final firstName = review.customerName.split(' ').first;
    final mono = firstName.isNotEmpty ? firstName[0] : 'ع';
    final avg = review.averageRating;
    final dateStr = _formatDate(review.createdAt);

    return Container(
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
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(mono, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.dark)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(firstName, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    _StarRow(rating: avg),
                  ],
                ),
              ),
              Text(dateStr, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment!,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.6)),
          ],
          const SizedBox(height: 10),
          // Sub-ratings row
          Row(
            children: [
              _SubRating(label: 'الجودة', value: review.qualityRating),
              const SizedBox(width: 6),
              _SubRating(label: 'التواصل', value: review.communicationRating),
              const SizedBox(width: 6),
              _SubRating(label: 'الالتزام', value: review.commitmentRating),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسابيع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} أشهر';
    return '${dt.year}/${dt.month}/${dt.day}';
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ...List.generate(5, (i) => Icon(
        i < rating.floor()
            ? Icons.star_rounded
            : (i < rating ? Icons.star_half_rounded : Icons.star_border_rounded),
        color: AppColors.star,
        size: 13,
      )),
      const SizedBox(width: 4),
      Text(rating.toStringAsFixed(1),
        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    ],
  );
}

class _SubRating extends StatelessWidget {
  final String label;
  final int value;
  const _SubRating({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.goldBg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 11, color: AppColors.star),
        const SizedBox(width: 3),
        Text('$value', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.goldText)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      ],
    ),
  );
}

// ── Rating summary bar ────────────────────────────────────────────────────────

class _RatingSummaryBar extends StatelessWidget {
  final List<ReviewItem> reviews;
  final double overallRating;
  const _RatingSummaryBar({required this.reviews, required this.overallRating});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    final avgQuality = reviews.map((r) => r.qualityRating).reduce((a, b) => a + b) / reviews.length;
    final avgComm = reviews.map((r) => r.communicationRating).reduce((a, b) => a + b) / reviews.length;
    final avgCommit = reviews.map((r) => r.commitmentRating).reduce((a, b) => a + b) / reviews.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Big score
          Column(
            children: [
              Text(overallRating.toStringAsFixed(1),
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < overallRating.floor() ? Icons.star_rounded
                      : (i < overallRating ? Icons.star_half_rounded : Icons.star_border_rounded),
                  color: AppColors.star, size: 14,
                )),
              ),
              const SizedBox(height: 4),
              Text('${reviews.length} تقييم',
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white54)),
            ],
          ),
          const SizedBox(width: 20),
          Container(width: 1, height: 70, color: Colors.white12),
          const SizedBox(width: 20),
          // Dimension bars
          Expanded(
            child: Column(
              children: [
                _DimBar(label: 'الجودة', value: avgQuality),
                const SizedBox(height: 8),
                _DimBar(label: 'التواصل', value: avgComm),
                const SizedBox(height: 8),
                _DimBar(label: 'الالتزام', value: avgCommit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DimBar extends StatelessWidget {
  final String label;
  final double value;
  const _DimBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 52,
        child: Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 5,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.star),
            minHeight: 6,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(value.toStringAsFixed(1),
        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white70)),
    ],
  );
}

// ── Simple helpers ────────────────────────────────────────────────────────────

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
          Text(value, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        ],
      ),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 32, color: AppColors.border);
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
