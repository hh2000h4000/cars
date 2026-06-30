import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../services/chat_service.dart';

class ShopChatsScreen extends StatefulWidget {
  const ShopChatsScreen({super.key});

  @override
  State<ShopChatsScreen> createState() => ShopChatsScreenState();
}

class ShopChatsScreenState extends State<ShopChatsScreen> {
  List<ChatRoom> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void reload() => _load();

  Future<void> _load() async {
    try {
      final result = await ChatService.getChatRooms();
      if (mounted) {
        setState(() {
          _rooms = result.items;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openChat(String roomId) {
    Navigator.pushNamed(context, '/customer/chat', arguments: roomId)
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
              child: Row(
                children: [
                  const Text('المحادثات',
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _load,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            if (_loading)
              const LinearProgressIndicator(color: AppColors.goldText, backgroundColor: AppColors.goldBg),

            Expanded(
              child: _rooms.isEmpty && !_loading
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                      itemCount: _rooms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final room = _rooms[i];
                        final hasUnread = room.unreadCount > 0;
                        return GestureDetector(
                          onTap: () => _openChat(room.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: hasUnread ? AppColors.goldText.withOpacity(0.4) : AppColors.border,
                                width: hasUnread ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                // Customer avatar
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(15)),
                                  alignment: Alignment.center,
                                  child: Text(room.customerMono,
                                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(room.customerName,
                                            style: TextStyle(
                                              fontFamily: 'Tajawal',
                                              fontSize: 14.5,
                                              fontWeight: hasUnread ? FontWeight.w900 : FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            )),
                                          const Spacer(),
                                          if (room.lastMessageTime.isNotEmpty)
                                            Text(room.lastMessageTime,
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 11.5,
                                                fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                                                color: hasUnread ? AppColors.goldText : AppColors.textMuted,
                                              )),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              room.lastMessage.isNotEmpty ? room.lastMessage : 'لا توجد رسائل بعد',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 12.5,
                                                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                                                color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          if (hasUnread)
                                            Container(
                                              margin: const EdgeInsets.only(right: 6),
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.red,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              constraints: const BoxConstraints(minWidth: 20, minHeight: 18),
                                              child: Text(
                                                room.unreadCount > 99 ? '99+' : '${room.unreadCount}',
                                                style: const TextStyle(
                                                  fontFamily: 'Tajawal',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.goldText, size: 34),
        ),
        const SizedBox(height: 16),
        const Text('لا توجد محادثات بعد',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('ستظهر هنا محادثاتك مع العملاء',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ],
    ),
  );
}
