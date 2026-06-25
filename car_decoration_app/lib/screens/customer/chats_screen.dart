import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../services/chat_service.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<ChatRoom> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rooms = await ChatService.getChatRooms();
      if (mounted) setState(() { _rooms = rooms; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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
                  Text('المحادثات',
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const Spacer(),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  ),
                ],
              ),
            ),

            if (_loading)
              const LinearProgressIndicator(color: AppColors.goldText, backgroundColor: AppColors.goldBg),

            // Conversations list
            Expanded(
              child: _rooms.isEmpty && !_loading
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                      itemCount: _rooms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final room = _rooms[i];
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: room.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                ShopAvatar(mono: room.shopMono, size: 50, fontSize: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(room.shopName,
                                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                          const Spacer(),
                                          if (room.lastMessageTime.isNotEmpty)
                                            Text(room.lastMessageTime,
                                              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        room.lastMessage.isNotEmpty ? room.lastMessage : 'لا توجد رسائل بعد',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
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
        const Text('ستظهر هنا محادثاتك مع المتاجر',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ],
    ),
  );
}
