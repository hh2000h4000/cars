import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';

class ShopRegisterScreen extends StatelessWidget {
  const ShopRegisterScreen({super.key});

  static const _fields = [
    ('رقم السجل التجاري', '1010 567 893'),
    ('اسم المالك', 'عبدالعزيز الشهري'),
    ('رقم الجوال', '+966 55 987 6543'),
    ('البريد الإلكتروني', 'info@goldentouch.sa'),
    ('المدينة', 'الرياض'),
    ('عنوان المتجر', 'حي العليا، طريق الملك فهد، الرياض'),
    ('وصف المتجر', 'مركز متخصص في تظليل وحماية وتلميع السيارات الفاخرة مع خدمة منزلية متنقلة.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text('تسجيل متجر / مركز', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Spacer(),
                    const AppBackButton(),
                  ],
                ),
              ),

              // Logo + shop name
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderStrong, width: 2, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFFFBF6EA),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: AppColors.goldText, size: 22),
                        const SizedBox(height: 5),
                        Text('شعار المتجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('اسم المتجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          Container(
                            height: 42,
                            decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(11)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.centerRight,
                            child: Text('مركز اللمسة الذهبية', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fields
              ...List.generate(_fields.length, (i) {
                final (label, value) = _fields[i];
                final isMultiline = i == 6;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: FormFieldBox(label: label, value: value, multiline: isMultiline),
                );
              }),

              // CR document upload
              Text('السجل التجاري (مستند)', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderStrong, width: 1.5, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFFBF6EA),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.description_outlined, color: AppColors.goldText, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('سجل_تجاري.pdf', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          Text('تم الإرفاق · 1.2MB', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_outline, color: AppColors.green, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              DarkButton(label: 'إرسال طلب التسجيل', onTap: () => Navigator.pushNamed(context, '/auth/shop-pending')),
            ],
          ),
        ),
      ),
    );
  }
}
