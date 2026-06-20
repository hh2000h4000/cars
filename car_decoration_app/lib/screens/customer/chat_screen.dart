import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../data/mock_data.dart';
import '../../models/chat_message.dart';
import '../../providers/app_provider.dart';

class ChatScreen extends StatefulWidget {
  final String shopId;
  const ChatScreen({super.key, required this.shopId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final messages = provider.messages;
    final shop = MockData.shops.firstWhere(
      (s) => s.id == widget.shopId,
      orElse: () => MockData.shops.first,
    );
    final isRequestId = int.tryParse(widget.shopId) != null;
    final chipLabel = isRequestId
        ? 'المحادثة بخصوص الطلب #${widget.shopId}'
        : 'المحادثة بخصوص الطلب';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  // Back button (visual RIGHT in RTL)
                  const AppBackButton(),
                  const SizedBox(width: 10),
                  // Shop avatar (before name)
                  ShopAvatar(mono: shop.mono, size: 40, fontSize: 15),
                  const SizedBox(width: 10),
                  // Name + status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.name,
                        style: TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(width: 7, height: 7,
                            decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Text('متصل الآن',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.green)),
                        ],
                      ),
                    ],
                  ),
                  // Spacer pushes phone to FAR LEFT
                  const Spacer(),
                  // Phone button (visual FAR LEFT in RTL)
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.call_outlined, color: AppColors.textSecondary, size: 18),
                  ),
                ],
              ),
            ),

            // ── Messages ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: messages.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.dark.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(chipLabel,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    );
                  }
                  return _MessageBubble(msg: messages[i - 1]);
                },
              ),
            ),

            // ── Input bar ──
            Container(
              padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  // Attachment (visual RIGHT in RTL)
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.image_outlined, color: AppColors.textMuted, size: 18),
                  ),
                  const SizedBox(width: 8),
                  // Text field (pill shape)
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        decoration: const InputDecoration.collapsed(
                          hintText: 'اكتب رسالة...',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button - gold (visual LEFT in RTL)
                  GestureDetector(
                    onTap: () {
                      if (_controller.text.trim().isNotEmpty) {
                        provider.sendMessage(_controller.text.trim());
                        _controller.clear();
                      }
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Directionality(
                        textDirection: TextDirection.ltr,
                        child: Icon(Icons.send_rounded, color: AppColors.dark, size: 18),
                      ),
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

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: msg.isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: msg.isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (msg.hasImage)
                Container(
                  width: 210, height: 160,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1C14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(painter: _StripePainter()),
                      Positioned(
                        bottom: 10, right: 12, left: 12,
                        child: Text(msg.text,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxWidth: 240),
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
                  child: Text(msg.text,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: msg.isMe ? Colors.white : AppColors.textPrimary,
                      height: 1.5,
                    )),
                ),
              const SizedBox(height: 3),
              Text(msg.time,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 14;
    for (double i = -size.height; i < size.width + size.height; i += 26) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => false;
}
