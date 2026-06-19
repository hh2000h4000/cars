import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../providers/app_provider.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicles = context.watch<AppProvider>().vehicles;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/customer/vehicles/add'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: AppColors.dark, size: 18),
                          const SizedBox(width: 5),
                          Text('إضافة مركبة', style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.dark)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text('مركباتي', style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final v = vehicles[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: v.isMain ? AppColors.goldLight : AppColors.border, width: v.isMain ? 1.5 : 1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.04), blurRadius: 14, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        // Cover
                        Container(
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: -20, right: -10,
                                child: Container(
                                  width: 120, height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(colors: [AppColors.goldLight.withOpacity(.2), Colors.transparent]),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10, left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: const Color(0xFF15140F), border: Border.all(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
                                  child: Text(v.year.toString(), style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.goldMuted)),
                                ),
                              ),
                              Center(
                                child: Text(v.mono, style: GoogleFonts.tajawal(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(.08))),
                              ),
                              Positioned(
                                bottom: 10, right: 14,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${v.brand} ${v.model}', style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                                    Text(v.color, style: GoogleFonts.tajawal(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.goldMuted)),
                                  ],
                                ),
                              ),
                              if (v.isMain)
                                Positioned(
                                  top: 10, right: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(999)),
                                    child: Text('رئيسية', style: GoogleFonts.tajawal(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.dark)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Bottom info
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 12, 15, 14),
                          child: Row(
                            children: [
                              if (!v.isMain)
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('جعلها رئيسية', style: GoogleFonts.tajawal(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                  ),
                                ),
                              const Spacer(),
                              if (v.plateNumber != null)
                                Row(
                                  children: [
                                    Text(v.plateNumber!, style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(7)),
                                      child: Text('لوحة', style: GoogleFonts.tajawal(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
