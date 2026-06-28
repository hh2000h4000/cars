import 'dart:async';
import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../services/api_client.dart';
import '../../services/chat_service.dart';
import '../../services/signalr_service.dart';
import 'shop_dashboard_screen.dart';
import 'shop_requests_screen.dart';
import 'shop_chats_screen.dart';
import 'shop_my_store_screen.dart';

class ShopShell extends StatefulWidget {
  const ShopShell({super.key});

  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> with WidgetsBindingObserver {
  int _index = 0;
  int _unreadCount = 0;
  StreamSubscription<String>? _notifSub;
  StreamSubscription<Map<String, dynamic>>? _shopStatusSub;

  static const _chatTabIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await ApiClient.getToken();
      if (token == null && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/auth/login', (r) => false);
      }
    });
    _connectSignalR();
  }

  Future<void> _connectSignalR() async {
    await SignalRService.instance.connect();
    await _refreshBadge();
    _notifSub = SignalRService.instance.onNotification.listen((_) {
      _refreshBadge();
    });
    _shopStatusSub = SignalRService.instance.onShopStatusChanged.listen(_onShopStatusChanged);
  }

  void _onShopStatusChanged(Map<String, dynamic> data) {
    if (!mounted) return;
    final status = data['status'] as String? ?? '';
    final reason = data['reason'] as String?;
    if (status == 'Suspended' || status == 'Rejected' || status == 'DocsRequested') {
      setState(() => _index = 3);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showStatusDialog(status, reason);
    });
  }

  void _showStatusDialog(String status, String? reason) {
    IconData icon;
    Color color;
    String title;
    String body;
    String buttonLabel;

    switch (status) {
      case 'Approved':
        icon = Icons.verified_rounded;
        color = const Color(0xFF4CAF50);
        title = 'تهانينا! تم اعتماد متجرك';
        body = 'يمكنك الآن استقبال طلبات العملاء وتقديم عروض الأسعار.';
        buttonLabel = 'رائع!';
        break;
      case 'Rejected':
        icon = Icons.cancel_rounded;
        color = const Color(0xFFE53935);
        title = 'تم رفض طلب الاعتماد';
        body = (reason != null && reason.isNotEmpty)
            ? 'السبب: $reason\n\nيمكنك تصحيح البيانات وإعادة التقديم من تبويب "متجري".'
            : 'يمكنك تصحيح البيانات وإعادة التقديم من تبويب "متجري".';
        buttonLabel = 'تصحيح البيانات';
        break;
      case 'Suspended':
        icon = Icons.block_rounded;
        color = const Color(0xFF9C27B0);
        title = 'تم إيقاف متجرك من قبل الإدارة';
        body = 'تواصل مع الإدارة لمعرفة المزيد من التفاصيل.';
        buttonLabel = 'حسناً';
        break;
      case 'DocsRequested':
        icon = Icons.folder_open_rounded;
        color = const Color(0xFF0288D1);
        title = 'مطلوب مستندات إضافية';
        body = 'طلب المشرف تحديث الوثائق المرفقة. راجع تبويب "متجري" لرفعها.';
        buttonLabel = 'رفع المستندات';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(color: color.withOpacity(.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 34),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Tajawal', fontSize: 16,
                  fontWeight: FontWeight.w900, color: Color(0xFF1C1917),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Tajawal', fontSize: 13,
                  fontWeight: FontWeight.w500, color: Color(0xFF6B6B6B), height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontFamily: 'Tajawal', fontSize: 14,
                      fontWeight: FontWeight.w800, color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SignalRService.instance.connect();
      _refreshBadge();
    }
  }

  Future<void> _refreshBadge() async {
    try {
      final result = await ChatService.getChatRooms();
      final count = result.items.fold(0, (sum, r) => sum + r.unreadCount);
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifSub?.cancel();
    _shopStatusSub?.cancel();
    super.dispose();
  }

  static const _screens = [
    ShopDashboardScreen(),
    ShopRequestsScreen(),
    ShopChatsScreen(),
    ShopMyStoreScreen(),
  ];

  static const _items = [
    (Icons.dashboard_outlined, Icons.dashboard_rounded, 'لوحتي'),
    (Icons.list_alt_outlined, Icons.list_alt_rounded, 'الطلبات'),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'المحادثات'),
    (Icons.storefront_outlined, Icons.storefront_rounded, 'متجري'),
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
                final (outIcon, fillIcon, label) = _items[i];
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
                            Icon(active ? fillIcon : outIcon,
                              color: active ? AppColors.dark : AppColors.textMuted, size: 22),
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
