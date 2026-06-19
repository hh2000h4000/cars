import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_pending_screen.dart';
import 'admin_disputes_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _screens = [
    AdminDashboardScreen(),
    AdminPendingScreen(),
    AdminDisputesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.dark,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                _DarkNavItem(Icons.gavel_outlined, Icons.gavel_rounded, 'النزاعات', _index == 2, () => setState(() => _index = 2)),
                _DarkNavItem(Icons.storefront_outlined, Icons.storefront_rounded, 'المتاجر', _index == 1, () => setState(() => _index = 1)),
                _DarkNavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'الرئيسية', _index == 0, () => setState(() => _index = 0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkNavItem extends StatelessWidget {
  final IconData outIcon;
  final IconData fillIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _DarkNavItem(this.outIcon, this.fillIcon, this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? fillIcon : outIcon, color: active ? AppColors.goldLight : Colors.white30, size: 22),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.tajawal(fontSize: 10.5, fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: active ? AppColors.goldLight : Colors.white30)),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 14 : 0, height: 2,
            decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(999)),
          ),
        ],
      ),
    ),
  );
}
