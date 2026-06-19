import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';

class SendQuoteScreen extends StatelessWidget {
  final String requestId;
  const SendQuoteScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
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
                    Text('إرسال عرض سعر', style: GoogleFonts.tajawal(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(width: 14),
                    const AppBackButton(),
                  ],
                ),
              ),

              // Request summary
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(color: AppColors.goldBg, border: Border.all(color: AppColors.goldLight), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('طلب #$requestId', style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                        Text('تظليل زجاج · لاند كروزر 2023', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.description_outlined, color: AppColors.goldText, size: 22),
                  ],
                ),
              ),

              // Price
              _Label('السعر الإجمالي (ريال)'),
              _NumberBox('1,850', large: true),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Label('رسوم الزيارة'),
                        _NumberBox('50'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Label('مدة التنفيذ'),
                        _TextBox('٣-٤ ساعات'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _Label('مدة الضمان'),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['بدون ضمان', '٦ أشهر', 'سنة', 'سنتان'].map((w) => Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: w == 'سنة' ? AppColors.goldBg : Colors.white,
                      border: Border.all(color: w == 'سنة' ? AppColors.goldLight : AppColors.border),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(w, style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: w == 'سنة' ? AppColors.goldText : AppColors.textSecondary)),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 18),

              _Label('تفاصيل الخدمة'),
              Container(
                height: 100,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.all(14),
                alignment: Alignment.topRight,
                child: Text(
                  'تظليل النوافذ الجانبية والخلفية بأفلام 3M عالية الجودة، مع ضمان عدم التبقع أو التقشر لمدة سنة كاملة...',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.6),
                ),
              ),
              const SizedBox(height: 18),

              _Label('المواد والقطع المستخدمة'),
              Column(
                children: [
                  _PartRow('أفلام 3M مستوى FX-ST'),
                  _PartRow('مواد تنظيف احترافية'),
                  _PartRow('ضمان ضد التبقع والتقشر'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Spacer(),
                        Text('+ إضافة مادة', style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                        const SizedBox(width: 4),
                        const Icon(Icons.add_circle_outline, color: AppColors.goldText, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              DarkButton(
                label: 'إرسال العرض',
                onTap: () {
                  context.read<AppProvider>().submitQuote();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  );
}

class _NumberBox extends StatelessWidget {
  final String value;
  final bool large;
  const _NumberBox(this.value, {this.large = false});
  @override
  Widget build(BuildContext context) => Container(
    height: large ? 58 : 48,
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: Alignment.centerRight,
    child: Text(value, style: GoogleFonts.tajawal(fontSize: large ? 22 : 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  );
}

class _TextBox extends StatelessWidget {
  final String value;
  const _TextBox(this.value);
  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: Alignment.centerRight,
    child: Text(value, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  );
}

class _PartRow extends StatelessWidget {
  final String text;
  const _PartRow(this.text);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(11)),
    child: Row(
      children: [
        const Icon(Icons.remove_circle_outline, color: AppColors.red, size: 16),
        const Spacer(),
        Text(text, style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    ),
  );
}
