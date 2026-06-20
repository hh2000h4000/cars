import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';

class ShopPendingScreen extends StatelessWidget {
  const ShopPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 40, 30, 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(30)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.goldLight, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    const Icon(Icons.access_time_outlined, color: AppColors.goldText, size: 46),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Text('طلبك قيد المراجعة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text(
                'تم استلام طلب تسجيل متجرك بنجاح. يقوم فريق الإدارة بمراجعة بياناتك والسجل التجاري، وعادة ما تستغرق المراجعة من ٢٤ إلى ٤٨ ساعة.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.7),
              ),
              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('حتى يتم الاعتماد، لا يمكن لمتجرك:', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                    const SizedBox(height: 13),
                    _RestrictedItem('استقبال طلبات الخدمة'),
                    const SizedBox(height: 9),
                    _RestrictedItem('إرسال عروض الأسعار'),
                    const SizedBox(height: 9),
                    _RestrictedItem('الظهور في نتائج البحث'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              OutlinedDarkButton(label: 'معاينة لوحة التحكم (بعد الاعتماد)', onTap: () => Navigator.pushNamed(context, '/shop/dashboard')),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestrictedItem extends StatelessWidget {
  final String text;
  const _RestrictedItem(this.text);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text('✕', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.red)),
      const SizedBox(width: 9),
      Text(text, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF3A382F))),
    ],
  );
}
