import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/app_provider.dart';

class ShopSelectScreen extends StatefulWidget {
  const ShopSelectScreen({super.key});

  @override
  State<ShopSelectScreen> createState() => _ShopSelectScreenState();
}

class _ShopSelectScreenState extends State<ShopSelectScreen> {
  int _sortIndex = 0;
  bool _sendToAll = false;
  bool _loading = false;
  String? _error;

  static const _sortTabs = ['الأقرب', 'الأعلى تقييماً', 'الأكثر إنجازاً'];

  Future<void> _submit(Map<String, dynamic> args) async {
    final provider = context.read<AppProvider>();
    final shopIds = _sendToAll
        ? provider.shops.map((s) => s.id).toList()
        : provider.selectedShops;

    if (shopIds.isEmpty) {
      setState(() { _error = 'يرجى اختيار متجر واحد على الأقل'; });
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await provider.addRequestFromApi(
        vehicleId: args['vehicleId'] as String,
        description: args['description'] as String,
        location: args['location'] as String,
        shopIds: shopIds,
        notes: args['notes'] as String?,
      );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (r) => false);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message'] ?? data['title'] ?? data.toString()) : 'حدث خطأ، يرجى المحاولة مجدداً';
      setState(() { _error = msg.toString(); });
    } catch (_) {
      setState(() { _error = 'حدث خطأ، يرجى المحاولة مجدداً'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final provider = context.watch<AppProvider>();
    final shops = provider.shops;
    final count = _sendToAll ? shops.length : provider.selectedShops.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اختر المتاجر', style: TextStyle(fontFamily: 'Tajawal', fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text('سيُرسَل الطلب فقط للمتاجر المختارة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                  ),
                  const Spacer(),
                  const AppBackButton(),
                ],
              ),
            ),

            // Sort tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: Row(
                children: List.generate(_sortTabs.length, (i) {
                  final selected = _sortIndex == i;
                  return Padding(
                    padding: EdgeInsets.only(left: i < _sortTabs.length - 1 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _sortIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.dark : Colors.white,
                          border: Border.all(color: selected ? AppColors.dark : AppColors.border),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(_sortTabs[i],
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.textSecondary)),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Send to all toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
              child: GestureDetector(
                onTap: () => setState(() => _sendToAll = !_sendToAll),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _sendToAll ? AppColors.goldBg : Colors.white,
                    border: Border.all(color: _sendToAll ? AppColors.goldLight : AppColors.border, width: _sendToAll ? 1.5 : 1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    Switch(
                      value: _sendToAll,
                      onChanged: (v) => setState(() => _sendToAll = v),
                      activeColor: AppColors.goldText,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                    Text('إرسال لكل المتاجر القريبة',
                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w700,
                        color: _sendToAll ? AppColors.goldText : AppColors.textPrimary)),
                    const Spacer(),
                    Icon(Icons.add_circle_outline, color: _sendToAll ? AppColors.goldText : AppColors.textMuted, size: 18),
                  ]),
                ),
              ),
            ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFCDD2))),
                  child: Text(_error!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
                ),
              ),

            // Shop list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                itemCount: shops.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final shop = shops[i];
                  final selected = _sendToAll || provider.selectedShops.contains(shop.id);

                  return GestureDetector(
                    onTap: _sendToAll ? null : () => provider.toggleShop(shop.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: selected ? AppColors.goldLight : AppColors.border, width: selected ? 1.5 : 1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(children: [
                        ShopAvatar(mono: shop.mono, size: 46, fontSize: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(shop.name, style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.star, color: AppColors.star, size: 13),
                                const SizedBox(width: 3),
                                Text(shop.rating.toString(), style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                Text(' · ${shop.city} · ${shop.completedJobs} عملية',
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.goldText : Colors.transparent,
                            border: Border.all(color: selected ? AppColors.goldText : AppColors.borderStrong, width: 2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: selected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(22, 14, 22, MediaQuery.of(context).padding.bottom + 14),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
        child: DarkButton(
          label: _loading
              ? 'جارٍ إرسال الطلب...'
              : count == 0
                  ? 'اختر متجراً على الأقل'
                  : 'إرسال الطلب إلى $count متاجر',
          onTap: (_loading || count == 0) ? null : () => _submit(args),
        ),
      ),
    );
  }
}
