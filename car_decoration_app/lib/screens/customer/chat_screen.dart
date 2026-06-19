import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../data/mock_data.dart';
import '../../providers/app_provider.dart';

class ChatScreen extends StatelessWidget {
  final String shopId;
  const ChatScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final messages = provider.messages;
    final shop = MockData.shops.firstWhere((s) => s.id == shopId, orElse: () => MockData.shops.first);
    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Chat header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.chevron_right, color: AppColors.dark, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(shop.name, style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Row(
                        children: [
                          Text('متصل الآن', style: GoogleFonts.tajawal(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.green)),
                          const SizedBox(width: 5),
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  ShopAvatar(mono: shop.mono, size: 42, fontSize: 16),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!msg.isMe) ...[
                          ShopAvatar(mono: shop.mono, size: 28, fontSize: 11),
                          const SizedBox(width: 7),
                        ],
                        Column(
                          crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (msg.hasImage)
                              Container(
                                width: 200, height: 130,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF23211A), Color(0xFF3A3320)]),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_outlined, color: Colors.white24, size: 36),
                              ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: msg.isMe ? AppColors.dark : Colors.white,
                                border: msg.isMe ? null : Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                                  bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                                ),
                              ),
                              child: Text(
                                msg.text,
                                textAlign: msg.isMe ? TextAlign.right : TextAlign.right,
                                style: GoogleFonts.tajawal(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: msg.isMe ? Colors.white : AppColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(msg.time, style: GoogleFonts.tajawal(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                          ],
                        ),
                        if (msg.isMe) ...[
                          const SizedBox(width: 7),
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.goldBg,
                            child: Text('ع', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.goldText)),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Input bar
            Container(
              padding: EdgeInsets.fromLTRB(12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => provider.sendImageMessage(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(11)),
                      child: const Icon(Icons.image_outlined, color: AppColors.textMuted, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.centerRight,
                      child: TextField(
                        controller: controller,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.tajawal(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        decoration: InputDecoration.collapsed(
                          hintText: 'اكتب رسالة...',
                          hintStyle: GoogleFonts.tajawal(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (controller.text.trim().isNotEmpty) {
                        provider.sendMessage(controller.text.trim());
                        controller.clear();
                      }
                    },
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.send_rounded, color: AppColors.dark, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
