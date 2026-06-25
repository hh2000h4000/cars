import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  const ChatScreen({super.key, required this.chatRoomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  ChatRoom? _room;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRoom() async {
    try {
      final detail = await ChatService.getRoomDetail(widget.chatRoomId);
      if (mounted) {
        setState(() {
          _room = detail.room;
          _messages = detail.messages;
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'تعذّر تحميل المحادثة';
          _loading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _controller.clear();
    try {
      final msg = await ChatService.sendMessage(widget.chatRoomId, text);
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر إرسال الرسالة', style: TextStyle(fontFamily: 'Tajawal')),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopName = _room?.shopName ?? 'المتجر';
    final shopMono = _room?.shopMono ?? '؟';
    final requestId = _room?.requestId ?? '';

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
                  const AppBackButton(),
                  const SizedBox(width: 10),
                  ShopAvatar(mono: shopMono, size: 40, fontSize: 15),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shopName,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(width: 7, height: 7,
                            decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          const Text('متصل الآن',
                            style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.green)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
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

            // ── Body ──
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.goldText))
                  : _error != null
                      ? Center(
                          child: Text(_error!,
                            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textMuted)),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: _messages.length + 1,
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
                                    child: Text(
                                      requestId.isNotEmpty ? 'المحادثة بخصوص الطلب #$requestId' : 'المحادثة',
                                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return _MessageBubble(msg: _messages[i - 1]);
                          },
                        ),
            ),

            // ── Input bar ──
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.image_outlined, color: AppColors.textMuted, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالة...',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        gradient: _sending
                            ? null
                            : const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                        color: _sending ? AppColors.border : null,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText),
                            )
                          : const Directionality(
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
