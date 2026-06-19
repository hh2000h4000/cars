import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';

class CustomerRegisterScreen extends StatelessWidget {
  const CustomerRegisterScreen({super.key});

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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const Spacer(),
                    Text('إنشاء حساب عميل', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(width: 14),
                    const AppBackButton(),
                  ],
                ),
              ),
              Text(
                'أنشئ حسابك في دقيقة — يتم تفعيل حساب العميل فوراً ويمكنك طلب الخدمات مباشرة.',
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary, height: 1.6),
              ),
              const SizedBox(height: 22),

              _FieldLabel('الاسم الكامل'),
              _FieldBox('عبدالله الحربي'),
              const SizedBox(height: 16),

              _FieldLabel('رقم الجوال'),
              Container(
                height: 52,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('+966 50 123 4567', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const Spacer(),
                    Text('🇸🇦 +966', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _FieldLabel('البريد الإلكتروني'),
              _FieldBox('abdullah@email.com', ltr: true),
              const SizedBox(height: 16),

              _FieldLabel('كلمة المرور'),
              Container(
                height: 52,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
                    const Spacer(),
                    Text('••••••••', style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 3)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              DarkButton(label: 'إنشاء الحساب', onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (_) => false)),
              const SizedBox(height: 16),
              const GreenInfoBanner(text: 'حساب العميل يُفعّل فوراً دون انتظار'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  );
}

class _FieldBox extends StatelessWidget {
  final String value;
  final bool ltr;
  const _FieldBox(this.value, {this.ltr = false});

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(15)),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: ltr ? Alignment.centerLeft : Alignment.centerRight,
    child: Text(value, style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
  );
}
