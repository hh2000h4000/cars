import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../services/api_client.dart';
import '../../services/signalr_service.dart';
import '../../services/upload_service.dart';

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
  final _imagePicker = ImagePicker();

  ChatRoom? _room;
  List<ChatMessage> _messages = [];
  List<XFile> _pendingImages = [];
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
    await SignalRService.instance.joinRoom(widget.chatRoomId);
    _msgSub = SignalRService.instance.onMessage.listen(_handleIncomingMessage);
  }

  void _handleIncomingMessage(Map<String, dynamic> data) {
    final senderRole = data['senderRole'] as String? ?? '';
    if (senderRole.isNotEmpty && senderRole == _myRole) return;

    final incomingId = data['id']?.toString() ?? '';
    if (_messages.any((m) => m.id == incomingId)) return;
    final msg = ChatMessage.fromJson(data, '', currentRole: _myRole);
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
        _scrollToBottom(animated: false);
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

  // ── Image picking ───────────────────────────────────────────────────────────

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              if (!kIsWeb)
                _SheetOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'الكاميرا',
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
                ),
              _SheetOption(
                icon: Icons.photo_library_rounded,
                label: 'المعرض',
                onTap: () { Navigator.pop(context); _pickFromGallery(); },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1280,
      );
      if (file != null && mounted) {
        setState(() => _pendingImages.add(file));
      }
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    try {
      final files = await _imagePicker.pickMultiImage(
        imageQuality: 75,
        maxWidth: 1280,
        limit: 5,
      );
      if (files.isNotEmpty && mounted) {
        setState(() => _pendingImages.addAll(files));
      }
    } catch (_) {}
  }

  void _removePendingImage(int index) {
    setState(() => _pendingImages.removeAt(index));
  }

  // ── Send ────────────────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _pendingImages.isEmpty) || _sending) return;

    setState(() => _sending = true);
    _controller.clear();
    _focusNode.requestFocus();

    try {
      List<String> attachmentUrls = [];

      if (_pendingImages.isNotEmpty) {
        final images = List<XFile>.from(_pendingImages);
        setState(() => _pendingImages = []);
        final bytes = await Future.wait(images.map((f) => f.readAsBytes()));
        attachmentUrls = await UploadService.uploadImages(bytes);
      }

      final msg = await ChatService.sendMessage(
        widget.chatRoomId,
        text,
        attachments: attachmentUrls.isEmpty ? null : attachmentUrls,
      );

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

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
            // ── Header ──────────────────────────────────────────────────────
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
                ],
              ),
            ),

            // ── Messages ─────────────────────────────────────────────────────
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
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.dark.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('المحادثة بخصوص الطلب',
                                      style: TextStyle(fontFamily: 'Tajawal', fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
                                  ),
                                ),
                              );
                            }
                            return _MessageBubble(
                              msg: _messages[i - 1],
                              onImageTap: (url) => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => _FullScreenImage(url: url),
                              )),
                            );
                          },
                        ),
            ),

            // ── Image preview strip ──────────────────────────────────────────
            if (_pendingImages.isNotEmpty)
              Container(
                height: 88,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pendingImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _PendingImageThumb(
                    file: _pendingImages[i],
                    onRemove: () => _removePendingImage(i),
                  ),
                ),
              ),

            // ── Input bar ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  // Image button
                  GestureDetector(
                    onTap: _sending ? null : _showImageSourceSheet,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _pendingImages.isNotEmpty
                            ? AppColors.goldBg
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        Icons.image_rounded,
                        color: _pendingImages.isNotEmpty
                            ? AppColors.goldText
                            : AppColors.textMuted,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Text field
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
                        decoration: InputDecoration(
                          hintText: _pendingImages.isNotEmpty ? 'أضف تعليقاً...' : 'اكتب رسالة...',
                          hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
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

// ── Pending image thumbnail ────────────────────────────────────────────────────

class _PendingImageThumb extends StatefulWidget {
  final XFile file;
  final VoidCallback onRemove;
  const _PendingImageThumb({required this.file, required this.onRemove});

  @override
  State<_PendingImageThumb> createState() => _PendingImageThumbState();
}

class _PendingImageThumbState extends State<_PendingImageThumb> {
  late Future<List<int>> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = widget.file.readAsBytes().then((b) => b.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FutureBuilder<List<int>>(
          future: _bytesFuture,
          builder: (_, snap) {
            if (!snap.hasData) {
              return Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText)),
              );
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                Uint8List.fromList(snap.data!),
                width: 70, height: 70,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
        Positioned(
          right: -6, top: -6,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bottom sheet option ────────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.goldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.goldText, size: 22),
          ),
          const SizedBox(width: 14),
          Text(label,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    ),
  );
}

// ── Message bubble ─────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final void Function(String url) onImageTap;
  const _MessageBubble({required this.msg, required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: msg.isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: msg.isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (msg.hasImage) _buildImageContent(context),
              if (msg.text.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxWidth: 260),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isMe ? AppColors.dark : Colors.white,
                    border: msg.isMe ? null : Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(msg.hasImage ? 0 : 16),
                      topRight: Radius.circular(msg.hasImage ? 0 : 16),
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
        ],
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    final urls = msg.imageUrls;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(msg.text.isEmpty ? (msg.isMe ? 16 : 4) : 0),
      bottomRight: Radius.circular(msg.text.isEmpty ? (msg.isMe ? 4 : 16) : 0),
    );

    if (urls.length == 1) {
      return _NetworkImage(url: urls.first, radius: radius, onTap: () => onImageTap(urls.first));
    }

    // Grid for multiple images (max 4 visible)
    final visible = urls.take(4).toList();
    final extra = urls.length - 4;
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: 220,
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: List.generate(visible.length, (i) {
            final isLast = i == visible.length - 1 && extra > 0;
            return GestureDetector(
              onTap: () => onImageTap(urls[i]),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(urls[i], fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surface,
                      child: const Icon(Icons.broken_image_rounded, color: AppColors.textMuted))),
                  if (isLast)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text('+$extra',
                        style: const TextStyle(fontFamily: 'Tajawal', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Network image with loading ─────────────────────────────────────────────────

class _NetworkImage extends StatelessWidget {
  final String url;
  final BorderRadius radius;
  final VoidCallback onTap;
  const _NetworkImage({required this.url, required this.radius, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: radius,
      child: Image.network(
        url,
        width: 220, height: 180,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                width: 220, height: 180,
                color: AppColors.surface,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldText),
              ),
        errorBuilder: (_, __, ___) => Container(
          width: 220, height: 180,
          color: AppColors.surface,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 36),
        ),
      ),
    ),
  );
}

// ── Full-screen image viewer ───────────────────────────────────────────────────

class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        Center(
          child: InteractiveViewer(
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator(color: Colors.white)),
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 60)),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
