import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../data/mock_data.dart';

class ShopChatsScreen extends StatelessWidget {
  const ShopChatsScreen({super.key});

  static const _conversations = [
    ('ع', 'عبدالله الحربي', 'تظليل كامل + فيلم حماية أمامي', 'ساعتان إلى ثلاث ساعات في موقعك.', '10:33', true),
    ('خ', 'خالد المطيري', 'تلميع نانو سيراميك', 'شكراً، ننتظر تأكيدك.', 'أمس', false),
    ('ر', 'ريم الزهراني', 'تركيب إضاءة داخلية', 'تم الاطلاع على الطلب.', '١٣ يونيو', false),
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
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                itemCount: _conversations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final (mono, name, service, lastMsg, time, isUnread) = _conversations[i];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/customer/chat', arguments: 'sh1'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: isUnread ? AppColors.goldLight : AppColors.border, width: isUnread ? 1.5 : 1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          // Customer avatar
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(15)),
                            alignment: Alignment.center,
                            child: Text(mono, style: TextStyle(fontFamily: 'Tajawal', fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.goldLight)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(name,
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                    const Spacer(),
                                    Text(time,
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600,
                                        color: isUnread ? AppColors.goldText : AppColors.textMuted)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(service,
                                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(lastMsg,
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                                          color: isUnread ? AppColors.textPrimary : AppColors.textMuted)),
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
