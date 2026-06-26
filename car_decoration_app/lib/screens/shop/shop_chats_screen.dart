import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../services/chat_service.dart';
import '../../services/api_client.dart';

class ShopChatsScreen extends StatefulWidget {
  const ShopChatsScreen({super.key});

  @override
  State<ShopChatsScreen> createState() => _ShopChatsScreenState();
}

class _ShopChatsScreenState extends State<ShopChatsScreen> {
  List<ChatRoom> _rooms = [];
  bool _loading = true;
  String _myRole = '';
  Map<String, String> _lastRead = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _myRole = await ApiClient.getRole() ?? '';
    try {
      final rooms = await ChatService.getChatRooms();
      final lastRead = <String, String>{};
      for (final r in rooms) {
        final stored = await ApiClient.readData('chat_lastread_${r.id}');
        if (stored != null) lastRead[r.id] = stored;
      }
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _lastRead = lastRead;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _hasUnread(ChatRoom room) {
    if (room.lastMessageAt.isEmpty) return false;
    if (room.lastSenderRole.isEmpty) return false;
    if (room.lastSenderRole == _myRole) return false;
    final lastRead = _lastRead[room.id];
    if (lastRead == null) return true;
    try {
      final msgTime = DateTime.parse(room.lastMessageAt);
      final readTime = DateTime.parse(lastRead);
      return msgTime.isAfter(readTime);
    } catch (_) {
      return false;
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
                        final unread = _hasUnread(room);
                        return GestureDetector(
                          onTap: () => _openChat(room.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: unread ? AppColors.goldText.withOpacity(0.4) : AppColors.border,
                                width: unread ? 1.5 : 1,
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
                                              fontWeight: unread ? FontWeight.w900 : FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            )),
                                          const Spacer(),
                                          if (room.lastMessageTime.isNotEmpty)
                                            Text(room.lastMessageTime,
                                              style: TextStyle(
                                                fontFamily: 'Tajawal',
                                                fontSize: 11.5,
                                                fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                                                color: unread ? AppColors.goldText : AppColors.textMuted,
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
                                                fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                                                color: unread ? AppColors.textPrimary : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          if (unread)
                                            Container(
                                              width: 10, height: 10,
                                              margin: const EdgeInsets.only(right: 6),
                                              decoration: const BoxDecoration(
                                                color: AppColors.goldText,
                                                shape: BoxShape.circle,
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
