class ChatMessage {
  final String id;
  final bool isMe;
  final String text;
  final String time;
  final bool hasImage;

  const ChatMessage({
    required this.id,
    required this.isMe,
    required this.text,
    required this.time,
    this.hasImage = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    final sentAt = json['sentAt'] as String?;
    String time = '';
    if (sentAt != null) {
      try {
        final dt = DateTime.parse(sentAt).toLocal();
        time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }
    return ChatMessage(
      id: json['id'] as String,
      isMe: json['senderId'] == currentUserId,
      text: json['text'] as String? ?? '',
      time: time,
    );
  }
}
