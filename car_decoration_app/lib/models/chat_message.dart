class ChatMessage {
  final String id;
  final bool isMe;
  final String text;
  final String time;
  final List<String> imageUrls;
  final String senderRole;

  const ChatMessage({
    required this.id,
    required this.isMe,
    required this.text,
    required this.time,
    this.imageUrls = const [],
    this.senderRole = '',
  });

  bool get hasImage => imageUrls.isNotEmpty;

  factory ChatMessage.fromJson(
    Map<String, dynamic> json,
    String currentUserId, {
    String currentRole = '',
  }) {
    final sentAt = json['sentAt'] as String?;
    String time = '';
    if (sentAt != null) {
      try {
        final dt = DateTime.parse(sentAt).toLocal();
        time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final senderId = (json['senderId'] as String? ?? '').toLowerCase();
    final senderRole = json['senderRole'] as String? ?? '';

    bool isMe;
    if (currentRole.isNotEmpty && senderRole.isNotEmpty) {
      isMe = senderRole == currentRole;
    } else {
      isMe = senderId.isNotEmpty && senderId == currentUserId.toLowerCase();
    }

    final rawAttachments = json['attachments'] as List<dynamic>? ?? [];

    return ChatMessage(
      id: json['id'] as String? ?? '',
      isMe: isMe,
      text: json['text'] as String? ?? '',
      time: time,
      imageUrls: rawAttachments.cast<String>(),
      senderRole: senderRole,
    );
  }
}
