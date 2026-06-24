import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../theme.dart';
import '../../providers/app_provider.dart';
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final vehicles = provider.vehicles;
    final loading = provider.initLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/customer/vehicles/add'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: AppColors.goldLight, size: 17),
                          SizedBox(width: 5),
                          Text('إضافة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.goldLight)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text('سياراتي', style: TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                ],
              ),
            ),
            if (loading)
              const LinearProgressIndicator(color: AppColors.goldText, backgroundColor: AppColors.goldBg),
            Expanded(
              child: vehicles.isEmpty && !loading
                  ? _EmptyState(onAdd: () => Navigator.pushNamed(context, '/customer/vehicles/add'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                      itemCount: vehicles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _VehicleCard(vehicle: vehicles[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  void _showMenu(BuildContext context) {
    final provider = context.read<AppProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 38, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: 18),
            _menuItem(
              icon: Icons.edit_outlined,
              label: 'تعديل السيارة',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/customer/vehicles/add', arguments: vehicle);
              },
            ),
            if (!vehicle.isMain) ...[
              const Divider(height: 1),
              _menuItem(
                icon: Icons.star_outline,
                label: 'جعلها الرئيسية',
                onTap: () => Navigator.pop(context),
              ),
            ],
            const Divider(height: 1),
            _menuItem(
              icon: Icons.delete_outline,
              label: 'حذف السيارة',
              color: AppColors.red,
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف السيارة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800)),
                    content: const Text('هل أنت متأكد من حذف هذه السيارة؟', style: TextStyle(fontFamily: 'Tajawal')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal'))),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(fontFamily: 'Tajawal', color: AppColors.red))),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  try {
                    await VehicleService.deleteVehicle(vehicle.id);
                    provider.removeVehicle(vehicle.id);
                  } on DioException catch (e) {
                    final msg = e.response?.data is Map ? e.response?.data['message'] : null;
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(msg as String? ?? 'حدث خطأ', style: const TextStyle(fontFamily: 'Tajawal')),
                        backgroundColor: AppColors.red,
                      ));
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    final c = color ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w700, color: c)),
            const Spacer(),
            Icon(icon, size: 20, color: c),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/customer/vehicles/add', arguments: vehicle),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: vehicle.isMain ? AppColors.goldLight : AppColors.border, width: vehicle.isMain ? 1.5 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showMenu(context),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.more_vert, size: 20, color: AppColors.textMuted),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (vehicle.isMain) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(999)),
                              child: const Text('الرئيسية', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.goldText)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text('${vehicle.brand} ${vehicle.model}',
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${vehicle.year} · ${vehicle.color.isNotEmpty ? vehicle.color : "—"}',
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Text(vehicle.mono,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 16, 13),
              child: Row(
                children: [
                  _ImageThumbnails(imageUrls: vehicle.imageUrls),
                  const Spacer(),
                  if (vehicle.plateNumber != null) ...[
                    Text(vehicle.plateNumber!,
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(7)),
                      child: const Text('اللوحة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.goldText)),
                    ),
                  ] else
                    Text('بدون لوحة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumbnails extends StatelessWidget {
  final List<String> imageUrls;
  const _ImageThumbnails({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    const size = 38.0;
    const radius = 8.0;
    const maxShow = 2;

    if (imageUrls.isEmpty) {
      return Row(
        children: [
          ...List.generate(2, (_) => Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: _StripePlaceholder(size: size)),
          )),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Container(
              width: size, height: size,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(radius), border: Border.all(color: AppColors.border)),
              alignment: Alignment.center,
              child: const Text('+3', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        ...List.generate(imageUrls.length.clamp(0, maxShow), (i) => Padding(
          padding: const EdgeInsets.only(left: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.network(imageUrls[i], width: size, height: size, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _StripePlaceholder(size: size)),
          ),
        )),
        if (imageUrls.length > maxShow)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Container(
              width: size, height: size,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(radius), border: Border.all(color: AppColors.border)),
              alignment: Alignment.center,
              child: Text('+${imageUrls.length - maxShow}',
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
            ),
          ),
      ],
    );
  }
}

class _StripePlaceholder extends StatelessWidget {
  final double size;
  const _StripePlaceholder({required this.size});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size, height: size,
    child: CustomPaint(painter: _StripePainter()),
  );
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFE8E3D8));
    final p = Paint()..color = const Color(0xFFD4CFC4)..strokeWidth = 5;
    for (double i = -size.height; i < size.width + size.height; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(color: AppColors.goldBg, shape: BoxShape.circle),
          child: const Icon(Icons.directions_car_outlined, size: 38, color: AppColors.goldText),
        ),
        const SizedBox(height: 18),
        const Text('لا توجد سيارات', style: TextStyle(fontFamily: 'Tajawal', fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text('أضف سيارتك الأولى لتبدأ', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
            decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(14)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.goldLight, size: 18),
                SizedBox(width: 6),
                Text('إضافة سيارة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.goldLight)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
