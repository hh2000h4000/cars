import '../models/chat_message.dart';
import 'api_client.dart';

class ChatRoom {
  final String id;
  final String requestId;
  final String shopName;
  final String customerName;
  final String shopMono;
  final String customerMono;
  final String lastMessage;
  final String lastMessageTime;
  final String lastMessageAt;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.requestId,
    required this.shopName,
    required this.customerName,
    required this.shopMono,
    required this.customerMono,
    this.lastMessage = '',
    this.lastMessageTime = '',
    this.lastMessageAt = '',
    this.unreadCount = 0,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final shopName = json['shopName'] as String? ?? '';
    final customerName = json['customerName'] as String? ?? '';
    final lastMsgAt = json['lastMessageAt'] as String? ?? '';

    String timeLabel = '';
    if (lastMsgAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(lastMsgAt).toLocal();
        final now = DateTime.now();
        if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
          timeLabel = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } else {
          timeLabel = '${dt.day}/${dt.month}';
        }
      } catch (_) {}
    }

    return ChatRoom(
      id: json['id'] as String,
      requestId: json['requestId'] as String? ?? '',
      shopName: shopName,
      customerName: customerName,
      shopMono: shopName.isNotEmpty ? shopName[0] : '؟',
      customerMono: customerName.isNotEmpty ? customerName[0] : '؟',
      lastMessage: json['lastMessageText'] as String? ?? '',
      lastMessageTime: timeLabel,
      lastMessageAt: lastMsgAt,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}

class ChatRoomDetail {
  final ChatRoom room;
  final List<ChatMessage> messages;
  const ChatRoomDetail({required this.room, required this.messages});
}

class ChatService {
  // Lightweight list — unreadCount is computed server-side, no SecureStorage needed
  static Future<List<ChatRoom>> getChatRooms() async {
    final res = await ApiClient.dio.get('/api/chats');
    return (res.data as List<dynamic>)
        .map((e) => ChatRoom.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ChatRoomDetail> getRoomDetail(String roomId) async {
    final currentUserId = await ApiClient.getUserId() ?? '';
    final currentRole = await ApiClient.getRole() ?? '';
    final res = await ApiClient.dio.get('/api/chats/$roomId');
    final data = res.data as Map<String, dynamic>;
    final room = ChatRoom.fromJson(data);
    final rawMessages = data['messages'] as List<dynamic>? ?? [];
    final messages = rawMessages
        .map((e) => ChatMessage.fromJson(
              e as Map<String, dynamic>,
              currentUserId,
              currentRole: currentRole,
            ))
        .toList();
    return ChatRoomDetail(room: room, messages: messages);
  }

  static Future<ChatMessage> sendMessage(String roomId, String text) async {
    final currentUserId = await ApiClient.getUserId() ?? '';
    final currentRole = await ApiClient.getRole() ?? '';
    final res = await ApiClient.dio.post('/api/chats/send', data: {
      'chatRoomId': roomId,
      'text': text,
    });
    return ChatMessage.fromJson(
      res.data as Map<String, dynamic>,
      currentUserId,
      currentRole: currentRole,
    );
  }
}
