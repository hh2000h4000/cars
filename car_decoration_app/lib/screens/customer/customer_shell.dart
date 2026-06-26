import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../providers/app_provider.dart';
import '../../services/api_client.dart';
import '../../services/chat_service.dart';
import '../../services/signalr_service.dart';
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

class _CustomerShellState extends State<CustomerShell>
    with WidgetsBindingObserver {
  int _index = 0;
  int _unreadCount = 0;
  String _myRole = '';
  StreamSubscription<String>? _notifSub;

  static const _chatTabIndex = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await ApiClient.getToken();
      if (token == null) {
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/auth/login', (r) => false);
        return;
      }
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
    _connectSignalR();
  }

  Future<void> _connectSignalR() async {
    _myRole = await ApiClient.getRole() ?? '';
    await SignalRService.instance.connect();
    // Update badge immediately on load
    await _refreshBadge();
    // Then update badge on every new message notification
    _notifSub = SignalRService.instance.onNotification.listen((_) {
      _refreshBadge();
    });
  }

  // Called when app comes back to foreground — reconnect if needed
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SignalRService.instance.connect();
      _refreshBadge();
    }
  }

  Future<void> _refreshBadge() async {
    try {
      final rooms = await ChatService.getChatRooms();
      int count = 0;
      for (final room in rooms) {
        if (room.lastMessageAt.isEmpty) continue;
        if (room.lastSenderRole == _myRole) continue;
        final lastRead = await ApiClient.readData('chat_lastread_${room.id}');
        if (lastRead == null) { count++; continue; }
        try {
          if (DateTime.parse(room.lastMessageAt).isAfter(DateTime.parse(lastRead))) count++;
        } catch (_) {}
      }
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifSub?.cancel();
    super.dispose();
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
              children: List.generate(_items.length, (i) {
                final (outlinedIcon, filledIcon, label) = _items[i];
                final active = _index == i;
                final showBadge = i == _chatTabIndex && _unreadCount > 0;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _index = i);
                      if (i == _chatTabIndex) _refreshBadge();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              active ? filledIcon : outlinedIcon,
                              color: active ? AppColors.dark : AppColors.textMuted,
                              size: 22,
                            ),
                            if (showBadge)
                              Positioned(
                                right: -6, top: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 14),
                                  child: Text(
                                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white, fontSize: 9,
                                      fontWeight: FontWeight.w900, fontFamily: 'Tajawal',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(label,
                          style: TextStyle(fontFamily: 'Tajawal', fontSize: 10.5,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                            color: active ? AppColors.dark : AppColors.textMuted)),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 16 : 0, height: 2.5,
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
