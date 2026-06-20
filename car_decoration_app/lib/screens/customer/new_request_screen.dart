import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';

class NewRequestScreen extends StatelessWidget {
  const NewRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final vehicles = provider.vehicles;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── اختر المركبة ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                      child: Text('اختر المركبة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    SizedBox(
                      height: 108,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                        itemCount: vehicles.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final v = vehicles[i];
                          final selected = v.isMain;
                          return Container(
                            width: 130,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : Colors.white,
                              border: Border.all(
                                color: selected ? AppColors.dark : AppColors.border,
                                width: selected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: selected ? AppColors.dark : AppColors.surface,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(v.mono, style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w900, color: selected ? AppColors.goldLight : AppColors.textMuted)),
                                    ),
                                    const Spacer(),
                                    if (selected)
                                      Container(
                                        width: 8, height: 8,
                                        decoration: const BoxDecoration(color: AppColors.dark, shape: BoxShape.circle),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('${v.brand} ${v.model}',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(v.year.toString(), style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── وصف الخدمة ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                      child: Text('وصف الخدمة المطلوبة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.all(14),
                        alignment: Alignment.topRight,
                        child: Text(
                          'تظليل حراري كامل (٥٠٪ جوانب + ٧٠٪ أمامي) مع تركيب فيلم حماية شفاف على الواجهة الأمامية.',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── صور توضيحية ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                      child: Text('صور توضيحية', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: Row(
                        children: [
                          // Add photo button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                color: AppColors.goldBg,
                                border: Border.all(color: AppColors.goldLight, width: 1.5, style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.add, color: AppColors.goldText, size: 28),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Placeholder slots
                          _PhotoPlaceholder(),
                          const SizedBox(width: 10),
                          _PhotoPlaceholder(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── التاريخ والوقت ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('التاريخ المفضّل', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const SizedBox(height: 8),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      Text('٢٢ يونيو', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                      const Spacer(),
                                      const Icon(Icons.calendar_today_outlined, color: AppColors.goldText, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الوقت المفضّل', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                const SizedBox(height: 8),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      Text('٤:٠٠ م', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                      const Spacer(),
                                      const Icon(Icons.access_time_outlined, color: AppColors.goldText, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── موقع تنفيذ الخدمة ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                      child: Text('موقع تنفيذ الخدمة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          children: [
                            // Mock map
                            Container(
                              height: 140,
                              color: const Color(0xFFF5F0E8),
                              child: Stack(
                                children: [
                                  // Grid lines
                                  CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
                                  // Pin
                                  const Center(
                                    child: Icon(Icons.location_on, color: AppColors.goldText, size: 38),
                                  ),
                                ],
                              ),
                            ),
                            // Address
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('المنزل – حي الياسمين', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                        const SizedBox(height: 2),
                                        Text('طريق الأمير محمد بن سلمان، الرياض', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.home_outlined, color: AppColors.goldText, size: 22),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── ملاحظات إضافية ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                      child: Text('ملاحظات إضافية', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
                      child: Container(
                        height: 95,
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.all(14),
                        alignment: Alignment.topRight,
                        child: Text(
                          'يفضّل التنفيذ في المرآب المغطى. السيارة متوفرة طوال اليوم.',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.6),
                        ),
                      ),
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
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
        child: DarkButton(
          label: 'التالي · اختيار المتاجر',
          onTap: () => Navigator.pushNamed(context, '/customer/requests/shop-select'),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 90, height: 90,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: const Color(0xFFE8E3D8),
    ),
    clipBehavior: Clip.hardEdge,
    child: CustomPaint(painter: _DiagonalStripePainter()),
  );
}

class _DiagonalStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4CFC4)
      ..strokeWidth = 8;
    for (double i = -size.height; i < size.width + size.height; i += 16) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_DiagonalStripePainter old) => false;
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDD8CC)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => false;
}
