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
}
