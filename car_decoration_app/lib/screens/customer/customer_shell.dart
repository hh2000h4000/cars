import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../providers/app_provider.dart';
import 'home_screen.dart';
import 'requests_screen.dart';
import 'vehicles_screen.dart';
import 'chats_screen.dart';
import 'profile_screen.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AppProvider>().initFromApi();
      if (mounted) {
        final err = context.read<AppProvider>().initError;
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('خطأ في تحميل البيانات: $err',
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13)),
            backgroundColor: const Color(0xFFD32F2F),
            duration: const Duration(seconds: 6),
          ));
        }
      }
    });
  }

  static const _screens = [
    HomeScreen(),
    RequestsScreen(),
    VehiclesScreen(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'الرئيسية'),
    (Icons.list_alt_outlined, Icons.list_alt_rounded, 'طلباتي'),
    (Icons.directions_car_outlined, Icons.directions_car_rounded, 'سياراتي'),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'المحادثات'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
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
              children: List.generate(_items.length, (i) {
                final (outlinedIcon, filledIcon, label) = _items[i];
                final active = _index == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _index = i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          active ? filledIcon : outlinedIcon,
                          color: active ? AppColors.dark : AppColors.textMuted,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          style: TextStyle(fontFamily: 'Tajawal',
                            fontSize: 10.5,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                            color: active ? AppColors.dark : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 16 : 0,
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: AppColors.goldText,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
