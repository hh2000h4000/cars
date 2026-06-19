import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _menuItems = [
    (Icons.directions_car_outlined, 'مركباتي', '/customer/vehicles'),
    (Icons.history_outlined, 'سجل الخدمات', '/customer/requests'),
    (Icons.favorite_border_outlined, 'المتاجر المفضلة', null),
    (Icons.notifications_outlined, 'الإشعارات', null),
    (Icons.location_on_outlined, 'عناويني', null),
    (Icons.headset_mic_outlined, 'الدعم الفني', null),
    (Icons.info_outline, 'عن التطبيق', null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('الحساب', style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 20),

              // Profile card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                          child: Text('عميل', style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldMuted)),
                        ),
                        const SizedBox(height: 8),
                        Text('+966 50 123 4567', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('عبدالله الحربي', style: GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text('abdullah@email.com', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white38)),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text('ع', style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.dark)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  Expanded(child: _StatCard('٤', 'طلبات مكتملة')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard('٣', 'مركبات مسجلة')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard('١٢', 'تقييم مُعطى')),
                ],
              ),
              const SizedBox(height: 20),

              // Menu
              Container(
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: List.generate(_menuItems.length, (i) {
                    final (icon, label, route) = _menuItems[i];
                    return Column(
                      children: [
                        if (i > 0) const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
                        GestureDetector(
                          onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 18),
                                const Spacer(),
                                Text(label, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                const SizedBox(width: 12),
                                Icon(icon, color: AppColors.goldText, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // Logout
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (_) => false),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0EE),
                    border: Border.all(color: AppColors.red.withOpacity(.3)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_outlined, color: AppColors.red, size: 18),
                      const SizedBox(width: 8),
                      Text('تسجيل الخروج', style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.red)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard(this.value, this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
    child: Column(
      children: [
        Text(value, style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        const SizedBox(height: 3),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.tajawal(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    ),
  );
}
