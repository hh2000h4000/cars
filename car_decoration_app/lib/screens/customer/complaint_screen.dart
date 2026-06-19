import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../data/mock_data.dart';

class ComplaintScreen extends StatelessWidget {
  final String requestId;
  const ComplaintScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final selected = provider.selectedComplaintReason;

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
                    Text('تقديم شكوى', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(width: 14),
                    const AppBackButton(),
                  ],
                ),
              ),

              // Warning banner
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(.06),
                  border: Border.all(color: AppColors.red.withOpacity(.25)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 5,
                      child: Text(
                        'سيتم مراجعة شكواك من قبل فريق الإدارة وسيتم التواصل معك خلال ٢٤ ساعة.',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.red, height: 1.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 22),
                  ],
                ),
              ),

              // Request info
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Text('طلب #$requestId', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Spacer(),
                    Text('الطلب المتعلق بالشكوى', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  ],
                ),
              ),

              // Reason selection
              Text('سبب الشكوى', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Column(
                children: MockData.complaintReasons.map((reason) {
                  final isSelected = selected == reason;
                  return GestureDetector(
                    onTap: () => provider.selectComplaintReason(reason),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF0EE) : Colors.white,
                        border: Border.all(color: isSelected ? AppColors.red.withOpacity(.4) : AppColors.border, width: isSelected ? 1.5 : 1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.red : Colors.transparent,
                              border: Border.all(color: isSelected ? AppColors.red : AppColors.borderStrong, width: 2),
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
                          ),
                          const Spacer(),
                          Text(reason, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Description
              Text('وصف المشكلة بالتفصيل', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.all(14),
                alignment: Alignment.topRight,
                child: Text(
                  'اشرح المشكلة بالتفصيل هنا...',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),

              // Attachments
              Text('إرفاق صور (اختياري)', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderStrong, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.surface,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined, color: AppColors.textMuted, size: 28),
                      const SizedBox(height: 6),
                      Text('اضغط لإضافة صور', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              DarkButton(
                label: 'إرسال الشكوى',
                onTap: selected.isEmpty ? null : () {
                  Navigator.pushNamedAndRemoveUntil(context, '/customer/requests', (r) => r.settings.name == '/customer/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
