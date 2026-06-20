import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';

class NewRequestScreen extends StatelessWidget {
  const NewRequestScreen({super.key});

  static const _services = [
    ('تظليل زجاج', Icons.gradient, 'حماية من الأشعة وخصوصية'),
    ('حماية PPF', Icons.shield_outlined, 'طبقة حماية شفافة للطلاء'),
    ('تلميع وسيراميك', Icons.auto_fix_high_outlined, 'لمعة واحترافية عالية'),
    ('تنظيف داخلي وخارجي', Icons.water_drop_outlined, 'غسيل شامل للسيارة'),
    ('إضاءة LED', Icons.lightbulb_outline, 'تحسين أنظمة الإضاءة'),
    ('صوتيات وشاشات', Icons.speaker_outlined, 'نظام ترفيهي احترافي'),
    ('تنجيد جلود', Icons.airline_seat_recline_normal_outlined, 'تجديد المقاعد الجلدية'),
    ('ملصقات وتصميم', Icons.style_outlined, 'ملصقات خارجية مخصصة'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final vehicle = provider.vehicles.firstWhere((v) => v.isMain, orElse: () => provider.vehicles.first);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              child: Row(
                children: [
                  Text('طلب خدمة جديد', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const Spacer(),
                  const AppBackButton(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle selector
                    Text('المركبة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.goldLight, width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(vehicle.mono, style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${vehicle.brand} ${vehicle.model} ${vehicle.year}',
                                style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              Text(vehicle.color, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Service type
                    Text('نوع الخدمة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.4,
                      ),
                      itemCount: _services.length,
                      itemBuilder: (_, i) {
                        final (name, icon, sub) = _services[i];
                        final selected = i == 0;
                        return GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.goldBg : Colors.white,
                              border: Border.all(color: selected ? AppColors.goldLight : AppColors.border, width: selected ? 1.5 : 1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(icon, color: selected ? AppColors.goldText : AppColors.textMuted, size: 20),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(name, style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: selected ? AppColors.goldText : AppColors.textPrimary)),
                                    Text(sub, style: TextStyle(fontFamily: 'Tajawal', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                                  ],
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),

                    // Notes
                    Text('ملاحظات إضافية', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.all(14),
                      alignment: Alignment.topRight,
                      child: Text(
                        'أريد تظليل النوافذ الجانبية والخلفية فقط مع الحفاظ على الزجاج الأمامي شفافاً...',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Location
                    Text('موقع الخدمة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.location_on_outlined, color: AppColors.goldText, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('العليا، الرياض', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                Text('طريق الملك فهد، مبنى الأعمال', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Service mode
                    Text('طريقة الخدمة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.storefront_outlined, color: AppColors.textSecondary, size: 22),
                                const SizedBox(height: 5),
                                Text('في المركز', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.goldBg,
                              border: Border.all(color: AppColors.goldLight, width: 1.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.home_outlined, color: AppColors.goldText, size: 22),
                                const SizedBox(height: 5),
                                Text('خدمة منزلية', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).padding.bottom + 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: DarkButton(
          label: 'التالي: اختيار المتاجر',
          onTap: () => Navigator.pushNamed(context, '/customer/requests/shop-select'),
        ),
      ),
    );
  }
}
