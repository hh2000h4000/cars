import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../data/mock_data.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  static const _conversations = [
    ('sh1', 'لمسات الفخامة', 'ل', 'سنرسل لك عرض السعر الرسمي الآن.', '10:33', true, false),
    ('sh5', 'ماسة كار', 'م', 'شكراً على تواصلك معنا، سنتواصل قريباً.', 'أمس', false, false),
    ('sh2', 'بريق الخليج', 'ب', 'تم استلام طلبك، سيتم مراجعته.', '١٢ يونيو', false, false),
  ];

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
                    style: TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
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

            // Conversations list
            Expanded(
              child: _conversations.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                      itemCount: _conversations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final (shopId, name, mono, lastMsg, time, isUnread, hasNew) = _conversations[i];
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: shopId),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: isUnread ? AppColors.goldLight : AppColors.border, width: isUnread ? 1.5 : 1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                // Avatar with optional online dot
                                Stack(
                                  children: [
                                    ShopAvatar(mono: mono, size: 50, fontSize: 20),
                                    if (isUnread)
                                      Positioned(
                                        bottom: 0, left: 0,
                                        child: Container(
                                          width: 13, height: 13,
                                          decoration: BoxDecoration(
                                            color: AppColors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),

                                // Name + last message
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(name,
                                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                          const Spacer(),
                                          Text(time,
                                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600,
                                              color: isUnread ? AppColors.goldText : AppColors.textMuted)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(lastMsg,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                                                color: isUnread ? AppColors.textPrimary : AppColors.textSecondary)),
                                          ),
                                          if (isUnread)
                                            Container(
                                              width: 8, height: 8,
                                              margin: const EdgeInsets.only(right: 6),
                                              decoration: const BoxDecoration(color: AppColors.goldText, shape: BoxShape.circle),
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
        Text('لا توجد محادثات بعد',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text('ستظهر هنا محادثاتك مع المتاجر',
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ],
    ),
  );
}
