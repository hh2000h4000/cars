import 'package:flutter/material.dart';

import '../../theme.dart';
import 'shop_dashboard_screen.dart';
import 'shop_requests_screen.dart';

class ShopShell extends StatefulWidget {
  const ShopShell({super.key});

  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> {
  int _index = 0;

  static const _screens = [
    ShopDashboardScreen(),
    ShopRequestsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [BoxShadow(color: AppColors.dark.withOpacity(.06), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(Icons.list_alt_outlined, Icons.list_alt_rounded, 'الطلبات', _index == 1, () => setState(() => _index = 1)),
                _NavItem(Icons.home_outlined, Icons.home_rounded, 'الرئيسية', _index == 0, () => setState(() => _index = 0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData outIcon;
  final IconData fillIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem(this.outIcon, this.fillIcon, this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? fillIcon : outIcon, color: active ? AppColors.dark : AppColors.textMuted, size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: active ? AppColors.dark : AppColors.textMuted)),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 16 : 0, height: 2.5,
            decoration: BoxDecoration(color: AppColors.goldText, borderRadius: BorderRadius.circular(999)),
          ),
        ],
      ),
    ),
  );
}
