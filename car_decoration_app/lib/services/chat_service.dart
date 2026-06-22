import '../models/chat_message.dart';
import 'api_client.dart';

class ChatRoom {
  final String id;
  final String requestId;
  final String otherPartyName;
  final String otherPartyMono;
  final String lastMessage;
  final String lastMessageTime;

  const ChatRoom({
    required this.id,
    required this.requestId,
    required this.otherPartyName,
    required this.otherPartyMono,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final name = json['otherPartyName'] as String? ?? '';
    return ChatRoom(
      id: json['id'] as String,
      requestId: json['requestId'] as String? ?? '',
      otherPartyName: name,
      otherPartyMono: name.isNotEmpty ? name[0] : '؟',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] as String? ?? '',
    );
  }
}

class ChatService {
  static Future<List<ChatRoom>> getChatRooms() async {
    final res = await ApiClient.dio.get('/api/chat/rooms');
    final list = res.data as List<dynamic>;
    return list.map((e) => ChatRoom.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<ChatMessage>> getMessages(String roomId) async {
    final currentUserId = await ApiClient.getUserId() ?? '';
    final res = await ApiClient.dio.get('/api/chat/rooms/$roomId/messages');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>, currentUserId))
        .toList();
  }

  static Future<ChatMessage> sendMessage(String roomId, String content) async {
    final currentUserId = await ApiClient.getUserId() ?? '';
    final res = await ApiClient.dio.post(
      '/api/chat/rooms/$roomId/messages',
      data: {'content': content},
    );
    return ChatMessage.fromJson(res.data as Map<String, dynamic>, currentUserId);
  }
}
