import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final review = provider.reviewData;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const Spacer(),
                    Text('تقييم الخدمة', style: GoogleFonts.tajawal(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(width: 14),
                    const AppBackButton(),
                  ],
                ),
              ),

              // Shop summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تظليل زجاج', style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldMuted)),
                        Text('طلب #1038', style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white38)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('لمسات الفخامة', style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text('خدمة مكتملة', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.goldMuted)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    ShopAvatar(mono: 'ل', size: 46, fontSize: 18),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Overall rating
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: [
                    Text('التقييم العام', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) => GestureDetector(
                        onTap: () => provider.setReviewRating('overall', i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            i < review.overall ? Icons.star_rounded : Icons.star_border_rounded,
                            color: i < review.overall ? AppColors.star : AppColors.border,
                            size: 40,
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.overall >= 5 ? 'ممتاز!' : review.overall >= 4 ? 'جيد جداً' : review.overall >= 3 ? 'جيد' : review.overall >= 2 ? 'مقبول' : 'ضعيف',
                      style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.goldText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Sub ratings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    StarRatingRow(
                      label: 'جودة العمل',
                      value: review.quality,
                      onChanged: (v) => provider.setReviewRating('quality', v),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 14),
                    StarRatingRow(
                      label: 'التواصل والاستجابة',
                      value: review.communication,
                      onChanged: (v) => provider.setReviewRating('communication', v),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 14),
                    StarRatingRow(
                      label: 'الالتزام بالمواعيد',
                      value: review.timeliness,
                      onChanged: (v) => provider.setReviewRating('timeliness', v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Comment
              Text('تعليق إضافي', style: GoogleFonts.tajawal(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Container(
                height: 110,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.all(14),
                alignment: Alignment.topRight,
                child: Text(
                  review.comment.isEmpty ? 'شاركنا تجربتك مع الخدمة...' : review.comment,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w500, color: review.comment.isEmpty ? AppColors.textMuted : AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 28),

              DarkButton(
                label: 'إرسال التقييم',
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
