import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/review_service.dart';
import '../../services/api_client.dart';

class ReviewArgs {
  final String requestId;
  final String shopName;
  const ReviewArgs({required this.requestId, required this.shopName});
}

class ReviewScreen extends StatefulWidget {
  final ReviewArgs args;
  const ReviewScreen({super.key, required this.args});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _quality = 0;
  int _communication = 0;
  int _commitment = 0;
  int _general = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _quality > 0 && _communication > 0 && _commitment > 0 && _general > 0;

  Future<void> _submit() async {
    if (!_canSubmit || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ReviewService.createReview(
        requestId: widget.args.requestId,
        qualityRating: _quality,
        communicationRating: _communication,
        commitmentRating: _commitment,
        generalRating: _general,
        comment: _commentController.text.trim(),
      );
      if (mounted) setState(() { _submitting = false; _submitted = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ApiClient.extractError(e),
            style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: _submitted ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildSuccess() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 20),
          const Text('شكراً على تقييمك!',
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('ساعدت ${widget.args.shopName} على التطور',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          DarkButton(
            label: 'العودة للرئيسية',
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false),
          ),
        ],
      ),
    ),
  );

  Widget _buildForm() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text('تقييم الخدمة',
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const Spacer(),
              const AppBackButton(),
            ],
          ),
        ),

        // Shop card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              ShopAvatar(mono: widget.args.shopName.isNotEmpty ? widget.args.shopName[0] : '؟', size: 46, fontSize: 18),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.args.shopName,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                  const Text('خدمة مكتملة',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.goldMuted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // General rating (big stars)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const Text('التقييم العام',
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _general = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      i < _general ? Icons.star_rounded : Icons.star_border_rounded,
                      color: i < _general ? AppColors.star : AppColors.border,
                      size: 40,
                    ),
                  ),
                )),
              ),
              if (_general > 0) ...[
                const SizedBox(height: 8),
                Text(
                  _general >= 5 ? 'ممتاز!' : _general >= 4 ? 'جيد جداً' : _general >= 3 ? 'جيد' : _general >= 2 ? 'مقبول' : 'ضعيف',
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.goldText),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Sub ratings
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _RatingRow(label: 'جودة العمل', value: _quality,
                onChanged: (v) => setState(() => _quality = v)),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 14),
              _RatingRow(label: 'التواصل والاستجابة', value: _communication,
                onChanged: (v) => setState(() => _communication = v)),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 14),
              _RatingRow(label: 'الالتزام بالمواعيد', value: _commitment,
                onChanged: (v) => setState(() => _commitment = v)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Comment
        const Text('تعليق إضافي (اختياري)',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(14),
          child: TextField(
            controller: _commentController,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            maxLines: 4,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'شاركنا تجربتك مع الخدمة...',
              hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 28),

        if (!_canSubmit)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Center(
              child: Text('يرجى تقييم جميع المحاور أولاً',
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            ),
          ),

        DarkButton(
          label: _submitting ? 'جاري الإرسال...' : 'إرسال التقييم',
          onTap: _canSubmit && !_submitting ? _submit : null,
        ),
      ],
    ),
  );
}

class _RatingRow extends StatelessWidget {
  final String label;
  final int value;
  final void Function(int) onChanged;
  const _RatingRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      Row(
        children: List.generate(5, (i) => GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              i < value ? Icons.star_rounded : Icons.star_border_rounded,
              color: i < value ? AppColors.star : AppColors.border,
              size: 24,
            ),
          ),
        )),
      ),
    ],
  );
}
