import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../services/api_client.dart';
import '../../services/signalr_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  const ChatScreen({super.key, required this.chatRoomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  ChatRoom? _room;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  String _myRole = '';
  StreamSubscription<Map<String, dynamic>>? _msgSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    _myRole = await ApiClient.getRole() ?? '';
    await _loadRoom();

    // Subscribe to real-time messages for this room
    await SignalRService.instance.joinRoom(widget.chatRoomId);
    _msgSub = SignalRService.instance.onMessage.listen(_handleIncomingMessage);
  }

  void _handleIncomingMessage(Map<String, dynamic> data) {
    // Skip messages I sent — _sendMessage() already adds them via HTTP response.
    // This prevents duplicates when SignalR fires before the HTTP response arrives.
    final senderRole = data['senderRole'] as String? ?? '';
    if (senderRole.isNotEmpty && senderRole == _myRole) return;

    final incomingId = data['id']?.toString() ?? '';
    if (_messages.any((m) => m.id == incomingId)) return;
    final msg = ChatMessage.fromJson(data, '', currentRole: _myRole);
    // Yield to the event loop before calling setState to ensure
    // we're not inside a build/layout phase when SignalR fires the callback
    Future.microtask(() {
      if (!mounted) return;
      setState(() => _messages.add(msg));
      _scrollToBottom();
      _markAsRead();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _msgSub?.cancel();
    SignalRService.instance.leaveRoom(widget.chatRoomId);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
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
        _markAsRead();
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

  void _markAsRead() async {
    try {
      await ApiClient.dio.post('/api/chats/${widget.chatRoomId}/read');
    } catch (_) {}
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();
    _focusNode.requestFocus(); // stay focused after send

    try {
      final msg = await ChatService.sendMessage(widget.chatRoomId, text);
      if (mounted) {
        setState(() {
          _messages.add(msg);
          _sending = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر إرسال الرسالة', style: TextStyle(fontFamily: 'Tajawal')),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Shop sees customer name; customer sees shop name
    final isShop = _myRole == 'ShopOwner';
    final otherName = isShop
        ? (_room?.customerName ?? 'العميل')
        : (_room?.shopName ?? 'المتجر');
    final otherMono = isShop
        ? (_room?.customerMono ?? '؟')
        : (_room?.shopMono ?? '؟');

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
                  ShopAvatar(mono: otherMono, size: 40, fontSize: 15),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(otherName,
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
                  ),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!,
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14, color: AppColors.textMuted)),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _loadRoom,
                                child: const Text('إعادة المحاولة',
                                  style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: AppColors.goldText)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: _messages.length + 1,
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              final requestId = _room?.requestId ?? '';
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
                                      requestId.isNotEmpty
                                          ? 'المحادثة بخصوص الطلب'
                                          : 'المحادثة',
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
                      constraints: const BoxConstraints(minHeight: 40, maxHeight: 120),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        textInputAction: TextInputAction.send,
                        maxLines: null,
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالة...',
                          hintStyle: TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
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
    // isMe = true → رسالتي → اليمين (start في RTL)
    // isMe = false → رسالة الطرف الآخر → اليسار (end في RTL)
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for other party (shown on far left in RTL = end side)
          if (!msg.isMe) ...[
            Container(
              width: 28, height: 28,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.person, color: AppColors.goldLight, size: 14),
            ),
          ],
          Column(
            crossAxisAlignment:
                msg.isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
                  constraints: const BoxConstraints(maxWidth: 260),
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
                    boxShadow: msg.isMe ? null : [
                      BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 4, offset: const Offset(0, 2))
                    ],
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(msg.time,
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  if (msg.isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all_rounded, size: 13, color: AppColors.textMuted),
                  ],
                ],
              ),
            ],
          ),
          // Avatar for me (shown on far right in RTL = start side)
          if (msg.isMe) ...[
            Container(
              width: 28, height: 28,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.goldLight, AppColors.gold]),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.person, color: AppColors.dark, size: 14),
            ),
          ],
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
