import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';
import '../../models/vehicle.dart';

class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({super.key});

  static const _brands = ['تويوتا', 'لكزس', 'مرسيدس', 'BMW', 'نيسان', 'هوندا', 'كيا', 'هيونداي'];
  static const _colors = ['أبيض', 'أسود', 'رمادي', 'أزرق', 'أحمر', 'فضي', 'ذهبي', 'بيج'];

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
                    Text('إضافة مركبة', style: GoogleFonts.tajawal(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(width: 14),
                    const AppBackButton(),
                  ],
                ),
              ),

              // Vehicle preview card
              Container(
                width: double.infinity,
                height: 120,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1B1A14), Color(0xFF2E2917)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30, right: -20,
                      child: Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [AppColors.goldLight.withOpacity(.2), Colors.transparent]),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(Icons.directions_car_outlined, color: Colors.white10, size: 80),
                    ),
                    Positioned(
                      bottom: 14, right: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('اسم المركبة', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white54)),
                          Text('السنة · اللون', style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.goldMuted.withOpacity(.5))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              _Label('الماركة'),
              _DropdownBox(hint: 'اختر الماركة', items: _brands),
              const SizedBox(height: 14),

              _Label('الموديل'),
              _FieldBox('مثال: لاند كروزر'),
              const SizedBox(height: 14),

              _Label('سنة الصنع'),
              _DropdownBox(hint: 'اختر السنة', items: List.generate(10, (i) => '${2024 - i}')),
              const SizedBox(height: 14),

              _Label('اللون'),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: i == 0 ? AppColors.goldBg : Colors.white,
                      border: Border.all(color: i == 0 ? AppColors.goldLight : AppColors.border),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(_colors[i], style: GoogleFonts.tajawal(fontSize: 12.5, fontWeight: FontWeight.w700, color: i == 0 ? AppColors.goldText : AppColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _Label('رقم اللوحة (اختياري)'),
              _FieldBox('أ ب ج 1234'),
              const SizedBox(height: 28),

              DarkButton(
                label: 'إضافة المركبة',
                onTap: () {
                  context.read<AppProvider>().addVehicle(Vehicle(
                    id: 'v${DateTime.now().millisecondsSinceEpoch}',
                    brand: 'تويوتا', model: 'موديل جديد', year: 2024,
                    color: 'أبيض', mono: 'ت', isMain: false,
                  ));
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

class _FieldBox extends StatelessWidget {
  final String hint;
  const _FieldBox(this.hint);
  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: Alignment.centerRight,
    child: Text(hint, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
  );
}

class _DropdownBox extends StatelessWidget {
  final String hint;
  final List<String> items;
  const _DropdownBox({required this.hint, required this.items});
  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 20),
        const Spacer(),
        Text(hint, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      ],
    ),
  );
}
